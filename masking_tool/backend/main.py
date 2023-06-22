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
from models import RunParams, RequestVideoUploadParams, FinalizeVideoUploadParams

from db.video_manager import VideoManager
from db.job_manager import JobManager
from db.db_connection import DBConnection


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_directories()
    yield
    clear_temp_dir()

app = FastAPI(lifespan=lifespan)

video_manager = VideoManager(DBConnection())
job_manager = JobManager(DBConnection())


@app.get("/videos")
def get_videos():
    videos = video_manager.fetch_videos()

    return {
        'videos': videos
    }


@app.get('/videos/{video_id}')
def get_video_stream(video_id, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + '.mp4')

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@app.post('/jobs/create')
def create_job(run_params: RunParams):
    job_manager.create_new_job(
        run_params.id,
        run_params.video_id,
        {
            'extract_person_only': run_params.extract_person_only,
            'head_only_hiding': run_params.head_only_hiding,
            'hiding_strategy': run_params.hiding_strategy,
            'head_only_masking': run_params.head_only_masking,
            'mask_creation_strategy': run_params.mask_creation_strategy,
            'detailed_fingers': run_params.detailed_fingers,
            'detailed_facemesh': run_params.detailed_facemesh
        }
    )

@app.get('/jobs/next')
def fetch_next_job():
    job = job_manager.fetch_next_job()

    return {
        'job': job
    }




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

# Not really needed right now but for future extension
@app.post("/videos/upload/request")
def request_video_upload(params: RequestVideoUploadParams):
    if video_manager.has_video_with_name(params.video_name):
        raise HTTPException(status_code=400, detail="A video with this name exists already")

    video_manager.add_pending_video(
        params.video_id,
        params.video_name
    )
    #video_path = os.path.join(VIDEOS_BASE_PATH, params.video_id + '.mp4')

    return {}

# Not really needed right now but for future extension
@app.post("/videos/upload/finalize")
def finalize_video_upload(params: FinalizeVideoUploadParams):
    video_path = os.path.join(VIDEOS_BASE_PATH, params.video_id + '.mp4')

    if not os.path.exists(video_path):
        raise HTTPException(status_code=400, detail="A video with this name does not exist")

    capture = cv2.VideoCapture(video_path)

    frame_width = round(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = round(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = capture.get(cv2.CAP_PROP_FPS)
    frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
    duration = frame_count / fps

    h = int(capture.get(cv2.CAP_PROP_FOURCC))
    codec = chr(h & 0xff) + chr((h >> 8) & 0xff) + chr((h >> 16) & 0xff) + chr((h >> 24) & 0xff)

    video_manager.set_video_to_valid(
        params.video_id,
        {
            'frame_width': frame_width,
            'frame_height': frame_height,
            'fps': round(fps),
            'frame_count': round(frame_count),
            'duration': duration,
            'codec': codec,
        }
    )

    return {}

@app.post("/videos/upload/{video_id}")
async def upload_video(video_id, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + '.mp4')

    video_content = await request.body()

    file = open(video_path, 'wb')
    file.write(video_content)
    file.close()

    return {}
