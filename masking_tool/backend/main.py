import base64
from contextlib import asynccontextmanager
import os
import cv2

from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import FileResponse
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.request_utils import range_requests_response
from utils.app_utils import clear_temp_dir, init_directories

from runner import run_masking
from models import RunParams, RequestVideoUploadParams

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_directories()
    yield
    clear_temp_dir()

app = FastAPI(lifespan=lifespan)

@app.get("/videos")
def get_videos():
    videos = []

    for video_name in os.listdir(VIDEOS_BASE_PATH):
        video_path = os.path.join(VIDEOS_BASE_PATH, video_name)
        capture = cv2.VideoCapture(video_path)

        frame_width = round(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = round(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = capture.get(cv2.CAP_PROP_FPS)
        frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
        duration = frame_count / fps

        videos.append({
            'name': video_name,
            'frameWidth': frame_width,
            'frameHeight': frame_height,
            'fps': round(fps),
            'duration': duration,
        })

    return {
        "videos": videos,
    }

@app.get('/videos/{video_name}')
def get_video_stream(video_name, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_name)

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )

@app.get('/results/result/{original_video_name}/{result_video_name}')
def get_result_video_stream(original_video_name: str, result_video_name: str, request: Request):
    video_path = os.path.join(RESULT_BASE_PATH, original_video_name, result_video_name)
    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.") 

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )

@app.get('/results/{original_video_name}')
def get_results_for_video(original_video_name: str):
    results_path = os.path.join(RESULT_BASE_PATH, original_video_name)
    if not os.path.exists(results_path):
        result_videos = []
    else:
        result_videos = [p for p in os.listdir(results_path) if os.path.splitext(p)[1] != ".png"]
    return {"results": result_videos}

@app.get('/results/preview/{original_video_name}/{result_video_name}')
def get_result_preview_for_video(original_video_name: str, result_video_name: str):
    preview_file = os.path.splitext(result_video_name)[0] + ".png"
    image_path = os.path.join(RESULT_BASE_PATH, original_video_name, preview_file)
    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found") 
    with open(image_path, 'rb') as f:
        base64image = base64.b64encode(f.read())
    return {"image": base64image}

@app.post("/run")
def run(run_params: RunParams):
    result_path = run_masking(run_params)
    return {"result_video_path": result_path}

@app.post("/videos/upload/request")
def request_video_upload(params: RequestVideoUploadParams):
    video_path = os.path.join(VIDEOS_BASE_PATH, params.video_name)

    if os.path.exists(video_path):
        raise HTTPException(status_code=400, detail="A video with this name exists already")

    return {}

@app.post("/videos/upload/{video_name}")
async def upload_video(video_name, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_name)

    if os.path.exists(video_path):
        raise HTTPException(status_code=400, detail="A video with this name exists already")

    video_content = await request.body()

    file = open(video_path, 'wb')
    file.write(video_content)
    file.close()

    return {}
