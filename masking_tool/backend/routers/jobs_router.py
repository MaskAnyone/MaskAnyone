from fastapi import APIRouter, Request

from models import RunParams
from db.job_manager import JobManager
from db.db_connection import DBConnection

job_manager = JobManager(DBConnection())

router = APIRouter(
    prefix="/jobs",
)


@router.get("")
def fetch_jobs():
    jobs = job_manager.fetch_jobs()

    return {"jobs": jobs}


@router.post("/create")
def create_job(run_params: RunParams):
    job_manager.create_new_jobs(
        run_params.id,
        run_params.video_ids,
        run_params.result_video_id,
        run_params.run_data,
        "basic_masking",
    )
