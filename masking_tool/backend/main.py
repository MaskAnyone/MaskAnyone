from contextlib import asynccontextmanager
import os
import cv2

from fastapi import FastAPI, Request
from utils.request_utils import range_requests_response
from utils.app_utils import clear_temp_dir, init_directories

from runner import run_masking
from models import RunParams

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_directories()
    yield
    clear_temp_dir()

app = FastAPI(lifespan=lifespan)

@app.get("/videos")
def get_videos():
    videos = []

    videos_path = "videos"
    for video_name in os.listdir(videos_path):
        capture = cv2.VideoCapture(videos_path + '/' + video_name)

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
    video_path = 'videos/' + video_name

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )

@app.get('/results/{video_name}')
def get_result_video_stream(video_name, request: Request):
    video_path = 'results/' + video_name

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )

@app.get("/results")
def results():
    results_path = "results"
    if not os.path.exists(results_path):
        os.mkdir(results_path)
    return {"results": os.path.listdir(results_path)}

@app.post("/run")
def run(run_params: RunParams):
    result_path = run_masking(run_params)
    return {"result_video_path": result_path}