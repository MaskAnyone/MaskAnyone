import os
import uuid
import cv2

from fastapi import APIRouter, Request

from models import RunParams, MpKinematicsType, UpdateJobProgressParams
from db.job_manager import JobManager
from db.worker_manager import WorkerManager
from db.video_manager import VideoManager
from db.result_video_manager import ResultVideoManager
from db.result_mp_kinematics_manager import ResultMpKinematicsManager
from db.result_blendshapes_manager import ResultBlendshapesManager
from db.db_connection import DBConnection
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.request_utils import range_requests_response
from utils.video_utils import extract_video_info_from_capture

db_connection = DBConnection()
video_manager = VideoManager(db_connection)
result_video_manager = ResultVideoManager(db_connection)
result_mp_kinematics_manager = ResultMpKinematicsManager(db_connection)
result_blendshapes_manager = ResultBlendshapesManager(db_connection)
job_manager = JobManager(db_connection)
worker_manager = WorkerManager(db_connection)

router = APIRouter(
    prefix="/_worker/{worker_id}",
)


@router.post("/register")
def register_worker(worker_id: str):
    worker_manager.register_worker(worker_id)


@router.get("/jobs/next")
def fetch_next_job(worker_id: str):
    worker_manager.update_worker_activity(worker_id)
    job = job_manager.fetch_next_job()

    return {"job": job}


@router.post("/jobs/{job_id}/progress")
def update_job_progress(worker_id: str, job_id: str, params: UpdateJobProgressParams):
    worker_manager.update_worker_activity(worker_id)
    job_manager.update_job_progress(params.progress)


@router.post("/jobs/{job_id}/finish")
def finish_job(worker_id: str, job_id: str):
    worker_manager.update_worker_activity(worker_id)
    job_manager.mark_job_as_finished(job_id)


@router.post("/jobs/{job_id}/fail")
def fail_job(worker_id: str, job_id: str):
    worker_manager.update_worker_activity(worker_id)
    job_manager.mark_job_as_failed(job_id)


@router.get("/videos/{video_id}")
def get_video_stream(worker_id: str, video_id: str, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.post("/videos/{video_id}/results/{result_video_id}")
async def upload_result_video(
    worker_id: str, video_id: str, result_video_id: str, request: Request
):
    result_dir = os.path.join(RESULT_BASE_PATH, video_id)
    if not os.path.exists(result_dir):
        os.mkdir(result_dir)

    video_path = os.path.join(result_dir, result_video_id + ".mp4")

    video_content = await request.body()

    file = open(video_path, "wb")
    file.write(video_content)
    file.close()

    job = job_manager.fetch_job_by_result_video_id(result_video_id)

    capture = cv2.VideoCapture(video_path)
    video_info = extract_video_info_from_capture(video_path, capture)
    capture.release()

    result_video_manager.create_result_video(
        result_video_id, video_id, job.id, video_info
    )


@router.post("/videos/{video_id}/results/{result_video_id}/preview")
async def upload_result_video_preview_image(
    worker_id: str, video_id: str, result_video_id: str, request: Request
):
    result_dir = os.path.join(RESULT_BASE_PATH, video_id)
    if not os.path.exists(result_dir):
        os.mkdir(result_dir)

    image_path = os.path.join(result_dir, result_video_id + ".png")

    image_content = await request.body()

    file = open(image_path, "wb")
    file.write(image_content)
    file.close()


@router.post("/videos/{video_id}/results/{result_video_id}/mp_kinematics/{type}")
async def upload_result_mp_kinematics(
    worker_id: str,
    video_id: str,
    result_video_id: str,
    type: MpKinematicsType,
    request: Request,
):
    job = job_manager.fetch_job_by_result_video_id(result_video_id)

    result_mp_kinematics_manager.create_result_mp_kinematics_entry(
        str(uuid.uuid4()), result_video_id, video_id, job.id, type, await request.json()
    )


@router.post("/videos/{video_id}/results/{result_video_id}/blendshapes")
async def upload_result_blendshapes(
    worker_id: str, video_id: str, result_video_id: str, request: Request
):
    job = job_manager.fetch_job_by_result_video_id(result_video_id)

    result_blendshapes_manager.create_result_mp_kinematics_entry(
        str(uuid.uuid4()), result_video_id, video_id, job.id, await request.json()
    )
