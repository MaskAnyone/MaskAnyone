from fastapi import APIRouter

from db.job_manager import JobManager
from db.db_connection import DBConnection
from db.result_blendshapes_manager import ResultBlendshapesManager

job_manager = JobManager(DBConnection())
result_blendshapes_manager = ResultBlendshapesManager(DBConnection())

router = APIRouter(
    prefix="/results",
)


@router.get("/{result_video_id}/blendshapes")
def get_blendshapes(result_video_id: str):
    result_blendshapes = (
        result_blendshapes_manager.fetch_result_blendshapes_entry_by_resvid_id(
            result_video_id
        )
    )

    return result_blendshapes.data
