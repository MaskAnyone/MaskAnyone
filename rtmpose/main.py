import tempfile
import os
import io
import pickle
import json

from fastapi import FastAPI, APIRouter, File, Form, UploadFile, Response
from src.pose_estimation import perform_rtmpose_estimation


app = FastAPI()

router = APIRouter(
    prefix="/rtmpose",
)


@router.post("/estimate-pose-on-video")
async def estimate_pose_on_video(
    options=Form(...),
    video: UploadFile = File(...)
):
    video_content = await video.read()
    options = json.loads(options)

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp:
            tmp.write(video_content)
            tmp_path = tmp.name

        pose_data = perform_rtmpose_estimation(tmp_path, options)
    finally:
        os.remove(tmp_path)

    buffer = io.BytesIO()
    pickle.dump(pose_data, buffer)
    buffer.seek(0)

    return Response(buffer.getvalue(), media_type="application/octet-stream")


app.include_router(router)
