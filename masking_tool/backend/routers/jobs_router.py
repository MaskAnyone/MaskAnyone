from fastapi import APIRouter, Request

from models import RunParams
from db.job_manager import JobManager
from db.db_connection import DBConnection

job_manager = JobManager(DBConnection())

router = APIRouter(
    prefix='/jobs',
)


@router.get("")
def fetch_jobs():
    jobs = job_manager.fetch_jobs()

    return {"jobs": jobs}


@router.post("/create")
def create_job(run_params: RunParams):
    job_manager.create_new_job(
        run_params.id,
        run_params.video_id,
        run_params.result_video_id,
        run_params.run_data
    )


@router.get("/next")
def fetch_next_job():
    job = job_manager.fetch_next_job()

    return {"job": job}


@router.post("/{job_id}/finish")
def finish_job(job_id: str):
    job_manager.mark_job_as_finished(job_id)

@router.post("/{job_id}/fail")
def fail_job(job_id: str):
    job_manager.mark_job_as_failed(job_id)


