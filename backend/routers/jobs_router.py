from fastapi import APIRouter, Request, Depends

from models import RunParams
from db.job_manager import JobManager
from db.db_connection import DBConnection
from auth.jwt_bearer import JWTBearer

job_manager = JobManager(DBConnection())

router = APIRouter(
    prefix="/jobs",
)


@router.get("")
def fetch_jobs(token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    jobs = job_manager.fetch_jobs(user_id)

    return {"jobs": jobs}


@router.post("/{job_id}/delete")
def delete_job(job_id, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    job = job_manager.get_job(job_id)

    if job.user_id != user_id:
        raise Exception(f'Job {job_id} does not belong to user {user_id}')

    job_manager.delete_job(job_id)


@router.post("/create")
def create_job(run_params: RunParams, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    job_manager.create_new_jobs(
        run_params.id,
        run_params.video_ids,
        run_params.result_video_id,
        run_params.run_data,
        "basic_masking",
        user_id,
    )
