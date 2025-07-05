import tempfile
import os
import io
import pickle
import json
import numpy as np
import cv2

from fastapi import FastAPI, APIRouter, File, Form, UploadFile, Response
from src.pose_estimation import perform_openpose_pose_estimation


app = FastAPI()

router = APIRouter(
    prefix="/openpose",
)


@router.post("/estimate-pose-on-video")
async def estimate_pose_on_video(
    options=Form(...),
    video: UploadFile = File(...)
):
    video_content = await video.read()
    options = json.loads(options)

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as temp_video_file:
            temp_video_file.write(video_content)
            temp_video_file_path = temp_video_file.name

            pose_data = perform_openpose_pose_estimation(temp_video_file_path, options)
    finally:
        os.remove(temp_video_file_path)

    buffer = io.BytesIO()
    pickle.dump(pose_data, buffer)
    buffer.seek(0)

    return Response(buffer.getvalue(), media_type="application/octet-stream")



@router.post("/estimate-pose-on-image")
async def estimate_pose_on_image(
    options=Form(...),
    image: UploadFile = File(...)
):
    image_content = await image.read()
    options = json.loads(options)

    np_arr = np.frombuffer(image_content, np.uint8)
    image_np = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if image_np is None:
        return Response("Invalid image format", status_code=400)

    pose_data = perform_openpose_pose_estimation_on_image(image_np, options)

    buffer = io.BytesIO()
    pickle.dump(pose_data, buffer)
    buffer.seek(0)

    return Response(buffer.getvalue(), media_type="application/octet-stream")


app.include_router(router)
