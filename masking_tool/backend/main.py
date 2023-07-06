import base64
from contextlib import asynccontextmanager
import os

from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import FileResponse
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.request_utils import range_requests_response

import routers.jobs_router as jobs_router
import routers.videos_router as videos_router


app = FastAPI()

app.include_router(videos_router.router)
app.include_router(jobs_router.router)


@app.get("/results/result/{original_video_name}/{result_video_name}")
def get_result_video_stream(
    original_video_name: str, result_video_name: str, request: Request
):
    video_path = os.path.join(RESULT_BASE_PATH, original_video_name, result_video_name)
    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@app.get("/results/{original_video_name}")
def get_results_for_video(original_video_name: str):
    results_path = os.path.join(RESULT_BASE_PATH, original_video_name)
    if not os.path.exists(results_path):
        result_videos = []
    else:
        result_videos = [
            p for p in os.listdir(results_path) if os.path.splitext(p)[1] != ".png"
        ]
    return {"results": result_videos}


@app.get("/results/preview/{original_video_name}/{result_video_name}")
def get_result_preview_for_video(original_video_name: str, result_video_name: str):
    preview_file = os.path.splitext(result_video_name)[0] + ".png"
    image_path = os.path.join(RESULT_BASE_PATH, original_video_name, preview_file)
    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")
    with open(image_path, "rb") as f:
        base64image = base64.b64encode(f.read())
    return {"image": base64image}

