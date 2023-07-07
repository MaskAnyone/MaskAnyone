import os

from fastapi import APIRouter, Request

from models import RunParams
from db.job_manager import JobManager
from db.video_manager import VideoManager
from db.result_video_manager import ResultVideoManager
from db.db_connection import DBConnection
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.request_utils import range_requests_response


db_connection = DBConnection()
video_manager = VideoManager(db_connection)
result_video_manager = ResultVideoManager(db_connection)
job_manager = JobManager(db_connection)

router = APIRouter(
    prefix='/worker',
)


@router.get("/jobs/next")
def fetch_next_job():
    job = job_manager.fetch_next_job()

    return {"job": job}


@router.post("/jobs/{job_id}/finish")
def finish_job(job_id: str):
    job_manager.mark_job_as_finished(job_id)


@router.post("/jobs/{job_id}/fail")
def fail_job(job_id: str):
    job_manager.mark_job_as_failed(job_id)


@router.get('/videos/{video_id}')
def get_video_stream(video_id, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.post("/videos/{video_id}/results/{result_video_id}")
async def upload_result_video(video_id: str, result_video_id: str, request: Request):
    result_dir = os.path.join(RESULT_BASE_PATH, video_id)
    if not os.path.exists(result_dir):
        os.mkdir(result_dir)

    video_path = os.path.join(result_dir, result_video_id + ".mp4")

    video_content = await request.body()

    file = open(video_path, "wb")
    file.write(video_content)
    file.close()

    job = job_manager.fetch_job_by_result_video_id(result_video_id)

    result_video_manager.create_result_video(result_video_id, video_id, job.id)


@router.post("/videos/{video_id}/results/{result_video_id}/preview")
async def upload_result_video_preview_image(video_id: str, result_video_id: str, request: Request):
    result_dir = os.path.join(RESULT_BASE_PATH, video_id)
    if not os.path.exists(result_dir):
        os.mkdir(result_dir)

    image_path = os.path.join(result_dir, result_video_id + ".png")

    image_content = await request.body()

    file = open(image_path, "wb")
    file.write(image_content)
    file.close()
