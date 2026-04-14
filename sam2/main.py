import numpy as np
import os
import json
import cv2
import io
import tempfile
import shutil
import gc
import time

from fastapi import FastAPI, APIRouter, File, Form, UploadFile, HTTPException, Response
from src.segmentation import perform_sam2_segmentation, MODEL_CONFIGS

app = FastAPI()

router = APIRouter(
    prefix="/sam2",
)


colors = [
    (0, 0, 255),   # Red
    (0, 255, 0),   # Green
    (255, 0, 0),   # Blue
    (0, 255, 255), # Yellow
    (255, 0, 255), # Magenta
    (255, 255, 0), # Cyan
    # Add more colors if needed
]


@router.post("/segment-image")
async def segment_image(
    pose_prompts = Form(...),
    image: UploadFile = File(...),
    model_variant: str = Form("sam2.1_hiera_small"),
):
    if model_variant not in MODEL_CONFIGS:
        raise HTTPException(status_code=400, detail=f"Unknown model_variant '{model_variant}'. Valid options: {list(MODEL_CONFIGS.keys())}")

    image_content = await image.read()

    pose_prompts = json.loads(pose_prompts)

    temp_dir = tempfile.mkdtemp()
    frame_file_path = os.path.join(temp_dir, '000000.jpg')

    try:
        # Save the image if needed
        with open(frame_file_path, "wb") as f:
            f.write(image_content)

        video_pose_prompts = { 0: pose_prompts }
        masks = perform_sam2_segmentation(temp_dir, video_pose_prompts, model_variant)[0]

        output_image = cv2.imread(frame_file_path)
        for object_id, mask in masks.items():
            mask = np.squeeze(mask)

            color = colors[(object_id - 1) % len(colors)]
            overlay = np.zeros_like(output_image)
            overlay[:, :, 0] = color[0]
            overlay[:, :, 1] = color[1]
            overlay[:, :, 2] = color[2]
            alpha = 0.5
            output_image[mask] = (alpha * overlay[mask] + (1 - alpha) * output_image[mask]).astype(np.uint8)

        _, output_buffer = cv2.imencode('.jpg', output_image)
        return Response(content=output_buffer.tobytes(), media_type="image/jpeg")
    finally:
        shutil.rmtree(temp_dir)
        gc.collect()


@router.post("/segment-video")
async def segment_video(
    pose_prompts = Form(...),
    video: UploadFile = File(...),
    model_variant: str = Form("sam2.1_hiera_small"),
    initial_masks: UploadFile = File(None),
):
    """Segment a video with SAM2.

    initial_masks is an optional .npz file encoding {str(obj_id): bool_array} —
    when present, mask prompts are used instead of point prompts (chunk continuation).
    """
    if model_variant not in MODEL_CONFIGS:
        raise HTTPException(status_code=400, detail=f"Unknown model_variant '{model_variant}'. Valid options: {list(MODEL_CONFIGS.keys())}")

    try:
        video_content = await video.read()
        pose_prompts = json.loads(pose_prompts)

        decoded_initial_masks = None
        if initial_masks is not None:
            masks_content = await initial_masks.read()
            if masks_content:
                buf = io.BytesIO(masks_content)
                loaded = np.load(buf)
                decoded_initial_masks = {
                    int(key): loaded[key].astype(bool)
                    for key in loaded.files
                }

        temp_dir = tempfile.mkdtemp()
        video_path = os.path.join(temp_dir, f"video_{int(time.time())}.mp4")
        file = open(video_path, "wb")
        file.write(video_content)
        file.close()

        masks = perform_sam2_segmentation(video_path, pose_prompts, model_variant, initial_masks=decoded_initial_masks)

        flattened_masks = {
            f"frame{frame}_mask{mask}": mask_array
            for frame, masks in masks.items()
            for mask, mask_array in masks.items()
        }

        buffer = io.BytesIO()
        np.savez_compressed(buffer, **flattened_masks)
        buffer.seek(0)

        return Response(buffer.getvalue(), media_type="application/octet-stream")
    finally:
        shutil.rmtree(temp_dir)
        gc.collect()


# This is no longer needed, in SAM2.0 there was no support for using videos directly; leaving this for reference
"""
def unpack_video_for_sam2(video_content) -> str:
    temp_dir = tempfile.mkdtemp()

    video_path = os.path.join(temp_dir, 'video.mp4')
    file = open(video_path, "wb")
    file.write(video_content)
    file.close()

    try:
        output_pattern = os.path.join(temp_dir, '%06d.jpg')

        ffmpeg_command = [
            'ffmpeg',
            '-i', video_path,
            '-q:v', '2',
            '-start_number', '0',
            output_pattern
        ]

        subprocess.run(ffmpeg_command, check=True)

        return temp_dir

    except Exception as e:
        shutil.rmtree(temp_dir)
        raise e
"""


app.include_router(router)
