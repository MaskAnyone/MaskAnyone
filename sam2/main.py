import numpy as np
import os
import json
import cv2
import io
import tempfile
import shutil
import subprocess

from fastapi import FastAPI, APIRouter, File, Form, UploadFile, HTTPException, Response
from src.segmentation import perform_sam2_segmentation

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
    image: UploadFile = File(...)
):
    image_content = await image.read()

    pose_prompts = json.loads(pose_prompts)

    temp_dir = tempfile.mkdtemp()
    frame_file_path = os.path.join(temp_dir, '000000.jpg')

    try:
        # Save the image if needed
        with open(frame_file_path, "wb") as f:
            f.write(image_content)

        masks = perform_sam2_segmentation(temp_dir, pose_prompts)[0]

        output_image = cv2.imread(frame_file_path)
        for object_id in range(1, len(masks) + 1):
            mask = masks[object_id]
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


@router.post("/segment-video")
async def segment_video(
    pose_prompts = Form(...),
    video: UploadFile = File(...)
):
    video_content = await video.read()
    pose_prompts = json.loads(pose_prompts)

    video_dir = unpack_video_for_sam2(video_content)

    masks = perform_sam2_segmentation(video_dir, pose_prompts)

    flattened_masks = {
        f"frame{frame}_mask{mask}": mask_array
        for frame, masks in masks.items()
        for mask, mask_array in masks.items()
    }

    buffer = io.BytesIO()
    np.savez_compressed(buffer, **flattened_masks)
    buffer.seek(0)

    return Response(buffer.getvalue(), media_type="application/octet-stream")


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


app.include_router(router)
