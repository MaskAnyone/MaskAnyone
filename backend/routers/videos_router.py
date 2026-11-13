import json
import logging
import os

import cv2
from fastapi import APIRouter, Request, Response, HTTPException, Depends
from fastapi.responses import FileResponse, StreamingResponse
from starlette.background import BackgroundTask

from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.path_validation import validate_resource_id
from utils.request_utils import range_requests_response
from utils.preview_image_utils import aspect_preserving_resize_and_crop
from utils.video_utils import extract_video_info_from_capture
from utils.ffmpeg_converter import FFmpegConverter
from utils.video_compatibility_checker import VideoCompatibilityChecker
from utils.result_naming import (
    content_disposition,
    extra_file_name,
    resolve_names_for_video,
    result_stem,
    video_stem,
)
from utils.result_archive import (
    build_result_archive,
    build_video_results_archive,
    mp_kinematics_csv_chunks,
)
from models import (
    RunParams,
    RequestVideoUploadParams,
    FinalizeVideoUploadParams,
    TrimVideoParams,
    RenameVideoParams,
    ConvertFpsParams,
    MpKinematicsType,
)
from db.video_manager import VideoManager
from db.result_video_manager import ResultVideoManager
from db.result_mp_kinematics_manager import ResultMpKinematicsManager
from db.result_blendshapes_manager import ResultBlendshapesManager
from db.result_audio_files_manager import ResultAudioFilesManager
from db.result_extra_files_manager import ResultExtraFilesManager
from db.job_manager import JobManager
from db.db_connection import DBConnection
from auth.jwt_bearer import JWTBearer

logger = logging.getLogger(__name__)

db_connection = DBConnection()
video_manager = VideoManager(db_connection)
result_video_manager = ResultVideoManager(db_connection)
result_mp_kinematics_manager = ResultMpKinematicsManager(db_connection)
result_blendshapes_manager = ResultBlendshapesManager(db_connection)
result_audio_files_manager = ResultAudioFilesManager(db_connection)
result_extra_files_manager = ResultExtraFilesManager(db_connection)
job_manager = JobManager(db_connection)
ffmpeg_converter = FFmpegConverter()

router = APIRouter(
    prefix="/videos",
)


@router.get("")
def get_videos(token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    videos = video_manager.fetch_videos(user_id)

    return {"videos": videos}


@router.get("/{video_id}")
def get_video_stream(video_id: str, request: Request, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.get("/{video_id}/download")
def download_video(video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    video = video_manager.get_video(video_id)
    return FileResponse(path=video_path, filename=f"{video_stem(video.name)}.mp4", media_type="video/mp4")


@router.get("/{video_id}/preview")
def get_video_preview(video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    image_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.jpg")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()

    return Response(content=image_content, media_type="image/jpeg")


@router.get("/{video_id}/frames/{frame_index}")
def get_video_frame(video_id: str, frame_index: int, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    if frame_index < 0:
        raise HTTPException(status_code=400, detail="Frame index must be non-negative")

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    capture = cv2.VideoCapture(video_path)
    capture.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
    success, frame = capture.read()
    capture.release()

    if not success or frame is None:
        raise HTTPException(status_code=404, detail="Could not retrieve frame")

    success, encoded_image = cv2.imencode('.jpg', frame)
    if not success:
        raise HTTPException(status_code=500, detail="Could not encode frame")

    return Response(content=encoded_image.tobytes(), media_type="image/jpeg")


@router.post("/upload/request")
def request_video_upload(params: RequestVideoUploadParams, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(params.video_id)
    user_id = token_payload["sub"]

    if video_manager.has_video_with_name(params.video_name, user_id):
        raise HTTPException(
            status_code=400, detail="A video with this name exists already"
        )

    video_manager.add_pending_video(params.video_id, params.video_name, user_id)

    return {}


@router.post("/upload/finalize")
def finalize_video_upload(params: FinalizeVideoUploadParams, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(params.video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(params.video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{params.video_id}.mp4")

    if not os.path.exists(video_path):
        raise HTTPException(
            status_code=400, detail="A video with this name does not exist"
        )

    if not VideoCompatibilityChecker.is_browser_compatible(video_path):
        ffmpeg_converter.convert_video_in_place(video_path)

    capture = cv2.VideoCapture(video_path)

    frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
    video_preview_image_path = os.path.join(VIDEOS_BASE_PATH, f"{params.video_id}.jpg")
    capture.set(cv2.CAP_PROP_POS_FRAMES, int(frame_count / 2))
    _, frame = capture.read()
    preview_image = aspect_preserving_resize_and_crop(frame, 80, 60)
    cv2.imwrite(video_preview_image_path, preview_image)

    video_info = extract_video_info_from_capture(video_path, capture)

    capture.release()

    video_manager.set_video_to_valid(
        params.video_id,
        video_info,
    )

    return {}


@router.post("/upload/{video_id}")
async def upload_video(video_id: str, request: Request, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")

    video_content = await request.body()
    with open(video_path, "wb") as f:
        f.write(video_content)


@router.post("/{video_id}/delete")
async def delete_video(video_id: str, request: Request, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_manager.delete_video(video_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    if os.path.exists(video_path):
        os.remove(video_path)

    preview_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.jpg")
    if os.path.exists(preview_path):
        os.remove(preview_path)


@router.post("/{video_id}/rename")
def rename_video(video_id: str, params: RenameVideoParams, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    if video_manager.has_video_with_name(params.name, user_id):
        raise HTTPException(status_code=409, detail="A video with this name already exists")

    video_manager.rename_video(video_id, params.name)
    return {"status": "ok"}


@router.post("/{video_id}/trim")
def trim_video(video_id: str, params: TrimVideoParams, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(params.new_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    source_video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    if not os.path.exists(source_video_path):
        raise HTTPException(status_code=404, detail="Source video file not found")

    if params.start_time < 0 or params.end_time <= params.start_time:
        raise HTTPException(status_code=400, detail="Invalid time range")

    if video_manager.has_video_with_name(params.new_video_name, user_id):
        raise HTTPException(status_code=400, detail="A video with this name exists already")

    video_manager.add_pending_video(params.new_video_id, params.new_video_name, user_id)

    new_video_path = os.path.join(VIDEOS_BASE_PATH, f"{params.new_video_id}.mp4")

    try:
        ffmpeg_converter.trim_video(source_video_path, new_video_path, params.start_time, params.end_time)

        if not VideoCompatibilityChecker.is_browser_compatible(new_video_path):
            ffmpeg_converter.convert_video_in_place(new_video_path)

        capture = cv2.VideoCapture(new_video_path)

        frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
        preview_path = os.path.join(VIDEOS_BASE_PATH, f"{params.new_video_id}.jpg")
        capture.set(cv2.CAP_PROP_POS_FRAMES, int(frame_count / 2))
        _, frame = capture.read()
        preview_image = aspect_preserving_resize_and_crop(frame, 80, 60)
        cv2.imwrite(preview_path, preview_image)

        video_info = extract_video_info_from_capture(new_video_path, capture)
        capture.release()

        video_manager.set_video_to_valid(params.new_video_id, video_info)

        return {"video_id": params.new_video_id, "video_info": video_info}

    except Exception as e:
        if os.path.exists(new_video_path):
            os.remove(new_video_path)
        video_manager.delete_video(params.new_video_id)
        logger.error(f"Failed to trim video: {e}")
        raise HTTPException(status_code=500, detail="Failed to trim video")


@router.post("/{video_id}/convert-fps")
def convert_video_fps(video_id: str, params: ConvertFpsParams, token_payload: dict = Depends(JWTBearer())):
    """Convert video to a different frame rate (e.g., 60fps -> 30fps)."""
    validate_resource_id(video_id)
    validate_resource_id(params.new_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    source_video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    if not os.path.exists(source_video_path):
        raise HTTPException(status_code=404, detail="Source video file not found")

    if params.target_fps < 1 or params.target_fps > 120:
        raise HTTPException(status_code=400, detail="Target FPS must be between 1 and 120")

    if video_manager.has_video_with_name(params.new_video_name, user_id):
        raise HTTPException(status_code=400, detail="A video with this name exists already")

    video_manager.add_pending_video(params.new_video_id, params.new_video_name, user_id)

    new_video_path = os.path.join(VIDEOS_BASE_PATH, f"{params.new_video_id}.mp4")

    try:
        ffmpeg_converter.convert_fps(source_video_path, new_video_path, params.target_fps)

        if not VideoCompatibilityChecker.is_browser_compatible(new_video_path):
            ffmpeg_converter.convert_video_in_place(new_video_path)

        capture = cv2.VideoCapture(new_video_path)

        frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
        preview_path = os.path.join(VIDEOS_BASE_PATH, f"{params.new_video_id}.jpg")
        capture.set(cv2.CAP_PROP_POS_FRAMES, int(frame_count / 2))
        _, frame = capture.read()
        preview_image = aspect_preserving_resize_and_crop(frame, 80, 60)
        cv2.imwrite(preview_path, preview_image)

        video_info = extract_video_info_from_capture(new_video_path, capture)
        capture.release()

        video_manager.set_video_to_valid(params.new_video_id, video_info)

        return {"video_id": params.new_video_id, "video_info": video_info}

    except Exception as e:
        if os.path.exists(new_video_path):
            os.remove(new_video_path)
        video_manager.delete_video(params.new_video_id)
        logger.error(f"Failed to convert video FPS: {e}")
        raise HTTPException(status_code=500, detail="Failed to convert video frame rate")


@router.get("/{video_id}/results")
def get_results_for_video(video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    result_videos = result_video_manager.fetch_result_videos(video_id)
    names = resolve_names_for_video(video_id, result_video_manager, job_manager)
    for result_video in result_videos:
        result_video.name = names.get(str(result_video.id), result_video.name)

    return {"result_videos": result_videos}


def _result_file_stem(video_id: str, result_video_id: str) -> str:
    """Download file stem for a result; 404 if the result is not on this video."""
    names = resolve_names_for_video(video_id, result_video_manager, job_manager)
    if result_video_id not in names:
        raise HTTPException(status_code=404, detail="Result not found for this video")
    video = video_manager.get_video(video_id)
    return result_stem(video.name, names[result_video_id])


@router.get("/{video_id}/results/{result_video_id}")
def get_result_video_stream(video_id: str, result_video_id: str, request: Request, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(RESULT_BASE_PATH, video_id, f"{result_video_id}.mp4")

    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.get("/{video_id}/results/{result_video_id}/download")
def download_result_video(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(RESULT_BASE_PATH, video_id, f"{result_video_id}.mp4")

    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.")

    stem = _result_file_stem(video_id, result_video_id)
    return FileResponse(path=video_path, filename=f"{stem}.mp4", media_type="video/mp4")


@router.get("/{video_id}/results/{result_video_id}/preview")
def get_result_preview_for_video(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    image_path = os.path.join(RESULT_BASE_PATH, video_id, f"{result_video_id}.png")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()

    return Response(content=image_content, media_type="image/png")


@router.get("/{video_id}/results/{result_video_id}/qa")
def get_result_qa(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    """Return the per-frame mask-coverage QA report for a result, or 404 if absent.

    QA is stored as an extra file with type='qa' (JSON-serialised dict).
    Older results predating the QA collector won't have one — that's fine,
    callers should treat a 404 as "no report available" and degrade gracefully.
    """
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    entries = result_extra_files_manager.find_entries(result_video_id)
    qa_entry = next((e for e in entries if e["type"] == "qa"), None)
    if qa_entry is None:
        raise HTTPException(status_code=404, detail="No QA report for this result")

    extra_file = result_extra_files_manager.fetch_result_extra_files_entry(qa_entry["id"])
    try:
        return json.loads(bytes(extra_file.data))
    except (ValueError, TypeError) as e:
        raise HTTPException(status_code=500, detail=f"QA report is corrupted: {e}")


@router.get("/{video_id}/results/{result_video_id}/result-files")
def get_downloadable_result_files(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    files = []

    blendshapes_entries = result_blendshapes_manager.find_entries(result_video_id)
    mp_kinematics_entries = result_mp_kinematics_manager.find_entries(result_video_id)
    audio_file_entries = result_audio_files_manager.find_entries(result_video_id)
    extra_file_entries = result_extra_files_manager.find_entries(result_video_id)

    for blendshapes_id in blendshapes_entries:
        files.append({
            "id": blendshapes_id,
            "title": "Blendshapes",
            "url": f"/videos/{video_id}/results/{result_video_id}/blendshapes/{blendshapes_id}/download",
        })

    for mp_kinematics_id, mp_kinematics_type in mp_kinematics_entries:
        url = f"/videos/{video_id}/results/{result_video_id}/mp-kinematics/{mp_kinematics_id}/download"
        files.append({
            "id": mp_kinematics_id,
            "title": f"MP Kinematics {mp_kinematics_type}",
            "url": url,
        })
        files.append({
            "id": mp_kinematics_id,
            "title": f"MP Kinematics {mp_kinematics_type}",
            "url": f"{url}/csv",
        })

    for audio_file_id in audio_file_entries:
        files.append({
            "id": audio_file_id,
            "title": "Masked Voice (mp3)",
            "url": f"/videos/{video_id}/results/{result_video_id}/audio_files/{audio_file_id}/download",
        })

    for extra_file in extra_file_entries:
        files.append({
            "id": extra_file["id"],
            "title": f"Additional output (.{extra_file['type']})",
            "url": f"/videos/{video_id}/results/{result_video_id}/extra_files/{extra_file['id']}/download",
        })

    return {"files": files}


@router.get("/{video_id}/results/{result_video_id}/mp-kinematics/{mp_kinematics_id}/download")
def download_mp_kinematics_json(video_id: str, result_video_id: str, mp_kinematics_id: str, response: Response, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    validate_resource_id(mp_kinematics_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    result_mp_kinematics = (
        result_mp_kinematics_manager.fetch_result_mp_kinematics_entry(mp_kinematics_id)
    )
    stem = _result_file_stem(video_id, result_video_id)
    file_name = f"{stem}_kinematics-{result_mp_kinematics.type}.json"

    response.headers["Content-Disposition"] = f'attachment; filename="{file_name}"'
    return result_mp_kinematics.data


@router.get("/{video_id}/results/{result_video_id}/mp-kinematics/{mp_kinematics_id}/download/csv")
def download_mp_kinematics_csv(video_id: str, result_video_id: str, mp_kinematics_id: str, response: Response, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    validate_resource_id(mp_kinematics_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    result_mp_kinematics = (
        result_mp_kinematics_manager.fetch_result_mp_kinematics_entry(mp_kinematics_id)
    )

    stem = _result_file_stem(video_id, result_video_id)
    file_name = f"{stem}_kinematics-{result_mp_kinematics.type}.csv"

    return StreamingResponse(
        mp_kinematics_csv_chunks(result_mp_kinematics.data),
        media_type="text/csv",
        headers={"Content-Disposition": content_disposition(file_name)},
    )


@router.get("/{video_id}/results/{result_video_id}/blendshapes/{blendshapes_id}/download")
def download_blendshapes(video_id: str, result_video_id: str, blendshapes_id: str, response: Response, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    validate_resource_id(blendshapes_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    file_name = f"{_result_file_stem(video_id, result_video_id)}_blendshapes.json"

    result_blendshapes = result_blendshapes_manager.fetch_result_blendshapes_entry(
        blendshapes_id
    )

    response.headers["Content-Disposition"] = f'attachment; filename="{file_name}"'
    return result_blendshapes.data


@router.get("/{video_id}/results/{result_video_id}/audio_files/{audio_file_id}/download")
def download_audio_file(video_id: str, result_video_id: str, audio_file_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    validate_resource_id(audio_file_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    file_name = f"{_result_file_stem(video_id, result_video_id)}_voice.mp3"

    result_audio_file = result_audio_files_manager.fetch_result_audio_files_entry(
        audio_file_id
    )

    response = Response(content=bytes(result_audio_file.data), media_type="audio/mp3")
    response.headers["Content-Disposition"] = f'attachment; filename="{file_name}"'

    return response


@router.get("/{video_id}/results/{result_video_id}/extra_files/{extra_file_id}/download")
def download_extra_file(video_id: str, result_video_id: str, extra_file_id: str, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    validate_resource_id(extra_file_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    result_extra_file = result_extra_files_manager.fetch_result_extra_files_entry(
        extra_file_id
    )

    file_name = extra_file_name(_result_file_stem(video_id, result_video_id), result_extra_file.ending)

    response = Response(content=bytes(result_extra_file.data))
    response.headers["Content-Disposition"] = f'attachment; filename="{file_name}"'

    return response


@router.get("/{video_id}/results/{result_video_id}/download/zip")
def download_result_archive(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    """One result as a zip: masked video, data files, masking config, README."""
    validate_resource_id(video_id)
    validate_resource_id(result_video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    _result_file_stem(video_id, result_video_id)  # 404 if not on this video
    archive_path, file_name = build_result_archive(video_id, result_video_id, _archive_sources())
    return _archive_response(archive_path, file_name)


@router.get("/{video_id}/results-zip")
def download_video_results_archive(video_id: str, token_payload: dict = Depends(JWTBearer())):
    """All results of a video as one zip, one folder per result."""
    validate_resource_id(video_id)
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    archive_path, file_name = build_video_results_archive(video_id, _archive_sources())
    return _archive_response(archive_path, file_name)


def _archive_sources() -> dict:
    return {
        "video_manager": video_manager,
        "result_video_manager": result_video_manager,
        "job_manager": job_manager,
        "result_mp_kinematics_manager": result_mp_kinematics_manager,
        "result_blendshapes_manager": result_blendshapes_manager,
        "result_audio_files_manager": result_audio_files_manager,
        "result_extra_files_manager": result_extra_files_manager,
    }


def _archive_response(archive_path: str, file_name: str) -> FileResponse:
    return FileResponse(
        path=archive_path,
        filename=file_name,
        media_type="application/zip",
        background=BackgroundTask(_remove_file, archive_path),
    )


def _remove_file(path: str) -> None:
    try:
        os.remove(path)
    except OSError as e:
        logger.warning(f"Could not remove temporary archive {path}: {e}")
