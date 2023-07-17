from fastapi import APIRouter, Request

from models import RunParams
from db.job_manager import JobManager
from db.db_connection import DBConnection
from db.result_blendshapes_manager import ResultBlendshapesManager

job_manager = JobManager(DBConnection())
result_blendshapes_manager = ResultBlendshapesManager(DBConnection())

router = APIRouter(
    prefix="/jobs",
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
        run_params.run_data,
    )


@router.get("/{job_id}/results/blendshapes")
def get_blendshapes(job_id: str):
    result_blendshapes = (
        result_blendshapes_manager.fetch_result_blendshapes_entry_by_jobid(job_id)
    )

    return result_blendshapes.data
