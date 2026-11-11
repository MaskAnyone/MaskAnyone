import csv
import io
import logging
import os

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse

from db.job_manager import JobManager
from db.db_connection import DBConnection
from db.result_blendshapes_manager import ResultBlendshapesManager
from db.result_mp_kinematics_manager import ResultMpKinematicsManager
from db.video_manager import VideoManager
from db.result_video_manager import ResultVideoManager
from auth.jwt_bearer import JWTBearer
from config import RESULT_BASE_PATH
from models import RenameVideoParams
from utils.path_validation import validate_resource_id

logger = logging.getLogger(__name__)

db_connection = DBConnection()
job_manager = JobManager(db_connection)
result_blendshapes_manager = ResultBlendshapesManager(db_connection)
result_mp_kinematics_manager = ResultMpKinematicsManager(db_connection)
video_manager = VideoManager(db_connection)
result_video_manager = ResultVideoManager(db_connection)

router = APIRouter(
    prefix="/results",
)


@router.post("/{result_video_id}/rename")
def rename_result(result_video_id: str, params: RenameVideoParams, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]

    result_video = result_video_manager.get_result_video(result_video_id)
    video_manager.assert_user_has_video(result_video.video_id, user_id)

    if result_video_manager.has_result_video_with_name(result_video.video_id, params.name):
        raise HTTPException(status_code=409, detail="A result with this name already exists")

    result_video_manager.rename_result_video(result_video_id, params.name)
    return {"status": "ok"}


@router.post("/{result_video_id}/delete")
def delete_result(result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]

    result_video = result_video_manager.get_result_video(result_video_id)
    video_manager.assert_user_has_video(result_video.video_id, user_id)

    result_video_manager.delete_result_video(result_video_id)

    result_video_path = os.path.join(RESULT_BASE_PATH, result_video.video_id, f"{result_video_id}.mp4")
    if os.path.exists(result_video_path):
        os.remove(result_video_path)

    result_preview_path = os.path.join(RESULT_BASE_PATH, result_video.video_id, f"{result_video_id}.png")
    if os.path.exists(result_preview_path):
        os.remove(result_preview_path)


@router.get("/{result_video_id}/blendshapes")
def get_blendshapes(result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(result_video_id)

    try:
        result_blendshapes = (
            result_blendshapes_manager.fetch_result_blendshapes_entry_by_resvid_id(
                result_video_id
            )
        )
        return result_blendshapes.data
    except Exception:
        logger.warning(f"No blendshapes found for result video {result_video_id}")
        return None


@router.get("/{result_video_id}/mp-kinematics")
def get_mp_kinematics(result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(result_video_id)

    try:
        result_mp_kinematics = (
            result_mp_kinematics_manager.fetch_result_mp_kinematics_entry_by_resvid_id(
                result_video_id
            )
        )
        return result_mp_kinematics.data
    except Exception:
        logger.warning(f"No mp kinematics found for result video {result_video_id}")
        return None


@router.get("/{result_video_id}/mp-kinematics/csv")
def get_mp_kinematics_csv(result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(result_video_id)

    try:
        result_mp_kinematics = (
            result_mp_kinematics_manager.fetch_result_mp_kinematics_entry_by_resvid_id(
                result_video_id
            )
        )

        json_data = result_mp_kinematics.data
        max_landmarks = max(len(entry['data']['landmarks']) for entry in json_data)
        max_world_landmarks = max(len(entry['data']['world_landmarks']) for entry in json_data)

        columns = ['timestamp']
        for i in range(max_landmarks):
            columns += [f'landmark_{i}_x', f'landmark_{i}_y', f'landmark_{i}_z', f'landmark_{i}_presence', f'landmark_{i}_visibility']
        for i in range(max_world_landmarks):
            columns += [f'world_landmark_{i}_x', f'world_landmark_{i}_y', f'world_landmark_{i}_z', f'world_landmark_{i}_presence', f'world_landmark_{i}_visibility']

        def iterfile():
            buffer = io.StringIO()
            writer = csv.writer(buffer)
            writer.writerow(columns)
            buffer.seek(0)
            yield buffer.getvalue()
            buffer.truncate(0)
            buffer.seek(0)

            for entry in json_data:
                row = [entry['timestamp']]
                for lm in entry['data']['landmarks']:
                    row += [lm['x'], lm['y'], lm['z'], lm.get('presence', ''), lm.get('visibility', '')]
                row += [''] * (max_landmarks - len(entry['data']['landmarks'])) * 5
                for lm in entry['data']['world_landmarks']:
                    row += [lm['x'], lm['y'], lm['z'], lm.get('presence', ''), lm.get('visibility', '')]
                row += [''] * (max_world_landmarks - len(entry['data']['world_landmarks'])) * 5

                writer.writerow(row)
                buffer.seek(0)
                yield buffer.getvalue()
                buffer.truncate(0)
                buffer.seek(0)

        return StreamingResponse(iterfile(), media_type="text/csv", headers={"Content-Disposition": "attachment; filename=kinematics_data.csv"})
    except Exception:
        logger.exception(f"Failed to generate CSV for result video {result_video_id}")
        raise HTTPException(status_code=404, detail="No kinematics data found")
