import tempfile
import os
import io
import pickle
import json

from fastapi import FastAPI, APIRouter, File, Form, UploadFile, Response
from src.pose_estimation import perform_openpose_pose_estimation


app = FastAPI()

router = APIRouter(
    prefix="/openpose",
)


@router.post("/estimate-pose-on-video")
async def segment_video(
    options=Form(...),
    video: UploadFile = File(...)
):
    video_content = await video.read()
    options = json.loads(options)

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as temp_video_file:
            temp_video_file.write(video_content)
            temp_video_file_path = temp_video_file.name

            multi_person_detection = options.get("multi_person_detection", False)
            if multi_person_detection:
                pose_data = perform_openpose_pose_estimation(temp_video_file_path, options, multi_person_detection=True)
            else:
                pose_data = perform_openpose_pose_estimation(temp_video_file_path, options)  # default behaviour for maskanyone
    finally:
        os.remove(temp_video_file_path)

    buffer = io.BytesIO()
    pickle.dump(pose_data, buffer)
    buffer.seek(0)

    return Response(buffer.getvalue(), media_type="application/octet-stream")


app.include_router(router)
