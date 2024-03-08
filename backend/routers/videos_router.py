import os
import cv2
import io
import csv

from fastapi import APIRouter, Request, Response, HTTPException, Depends
from fastapi.responses import FileResponse, StreamingResponse

from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.request_utils import range_requests_response
from utils.preview_image_utils import aspect_preserving_resize_and_crop
from utils.video_utils import extract_video_info_from_capture
from models import (
    RunParams,
    RequestVideoUploadParams,
    FinalizeVideoUploadParams,
    MpKinematicsType,
)
from db.video_manager import VideoManager
from db.result_video_manager import ResultVideoManager
from db.result_mp_kinematics_manager import ResultMpKinematicsManager
from db.result_blendshapes_manager import ResultBlendshapesManager
from db.result_audio_files_manager import ResultAudioFilesManager
from db.result_extra_files_manager import ResultExtraFilesManager
from db.db_connection import DBConnection
from auth.jwt_bearer import JWTBearer


db_connection = DBConnection()
video_manager = VideoManager(db_connection)
result_video_manager = ResultVideoManager(db_connection)
result_mp_kinematics_manager = ResultMpKinematicsManager(db_connection)
result_blendshapes_manager = ResultBlendshapesManager(db_connection)
result_audio_files_manager = ResultAudioFilesManager(db_connection)
result_extra_files_manager = ResultExtraFilesManager(db_connection)

router = APIRouter(
    prefix="/videos",
)


@router.get("")
def get_videos(token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    videos = video_manager.fetch_videos(user_id)

    return {"videos": videos}


@router.get("/{video_id}")
def get_video_stream(video_id, request: Request, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.get("/{video_id}/download")
def download_video(video_id, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
    return FileResponse(path=video_path, filename=video_path, media_type="video/mp4")


@router.get("/{video_id}/preview")
def get_preview_for_video(video_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    image_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".jpg")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()
        f.close()

    return Response(content=image_content, media_type="image/jpeg")


@router.post("/upload/request")
def request_video_upload(params: RequestVideoUploadParams, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    if video_manager.has_video_with_name(params.video_name, user_id):
        raise HTTPException(
            status_code=400, detail="A video with this name exists already"
        )

    video_manager.add_pending_video(params.video_id, params.video_name, user_id)

    return {}


@router.post("/upload/finalize")
def finalize_video_upload(params: FinalizeVideoUploadParams, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(params.video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, params.video_id + ".mp4")

    if not os.path.exists(video_path):
        raise HTTPException(
            status_code=400, detail="A video with this name does not exist"
        )

    capture = cv2.VideoCapture(video_path)

    frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
    video_preview_image_path = os.path.join(VIDEOS_BASE_PATH, params.video_id + ".jpg")
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
async def upload_video(video_id, request: Request, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")

    video_content = await request.body()
    file = open(video_path, "wb")
    file.write(video_content)
    file.close()


@router.get("/{video_id}/results")
def get_results_for_video(video_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    result_videos = result_video_manager.fetch_result_videos(video_id)

    return {"result_videos": result_videos}


@router.get("/{video_id}/results/{result_video_id}")
def get_result_video_stream(video_id: str, result_video_id: str, request: Request, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(RESULT_BASE_PATH, video_id, result_video_id + ".mp4")

    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.get("/{video_id}/results/{result_video_id}/download")
def download_result_video(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    video_path = os.path.join(RESULT_BASE_PATH, video_id, result_video_id + ".mp4")

    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.")

    return FileResponse(path=video_path, filename=video_path, media_type="video/mp4")


@router.get("/{video_id}/results/{result_video_id}/preview")
def get_result_preview_for_video(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    image_path = os.path.join(RESULT_BASE_PATH, video_id, result_video_id + ".png")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()
        f.close()

    return Response(content=image_content, media_type="image/png")


@router.get("/{video_id}/results/{result_video_id}/result-files")
def get_downloadable_result_files(video_id: str, result_video_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)

    files = []

    blendshapes_entries = result_blendshapes_manager.find_entries(result_video_id)
    mp_kinematics_entries = result_mp_kinematics_manager.find_entries(result_video_id)
    audio_file_entries = result_audio_files_manager.find_entries(result_video_id)
    extra_file_entries = result_extra_files_manager.find_entries(
        result_video_id
    )  # List[{id, ending}]

    for blendshapes_id in blendshapes_entries:
        files.append(
            {
                "id": blendshapes_id,
                "title": "Blendshapes",
                "url": "/videos/"
                + video_id
                + "/results/"
                + result_video_id
                + "/blendshapes/"
                + blendshapes_id
                + "/download",
            }
        )

    for mp_kinematics_id, mp_kinematics_type in mp_kinematics_entries:
        url = "/videos/" + video_id + "/results/" + result_video_id + "/mp-kinematics/" + mp_kinematics_id + "/download"

        files.append(
            {
                "id": mp_kinematics_id,
                "title": "MP Kinematics " + mp_kinematics_type,
                "url": url,
            }
        )

        files.append(
            {
                "id": mp_kinematics_id,
                "title": "MP Kinematics " + mp_kinematics_type,
                "url": url + "/csv",
            }
        )

    for audio_file_id in audio_file_entries:
        files.append(
            {
                "id": audio_file_id,
                "title": "Masked Voice (mp3)",
                "url": "/videos/"
                + video_id
                + "/results/"
                + result_video_id
                + "/audio_files/"
                + audio_file_id
                + "/download",
            }
        )

    for extra_file in extra_file_entries:
        files.append(
            {
                "id": extra_file["id"],
                "title": "Additional output (." + extra_file["ending"] + ")",
                "url": "/videos/"
                + video_id
                + "/results/"
                + result_video_id
                + "/extra_files/"
                + extra_file["id"]
                + "/download",
            }
        )

    return {"files": files}


@router.get("/{video_id}/results/{result_video_id}/mp-kinematics/{mp_kinematics_id}/download")
def download_mp_kinematics(video_id: str, result_video_id: str, mp_kinematics_id: str, response: Response, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)
    # @todo check result videoid matches given video id

    file_name = result_video_id + "_mp-kinematics.json"

    result_mp_kinematics = (
        result_mp_kinematics_manager.fetch_result_mp_kinematics_entry(mp_kinematics_id)
    )

    response.headers["Content-Disposition"] = 'attachment; filename="' + file_name + '"'
    return result_mp_kinematics.data


@router.get("/{video_id}/results/{result_video_id}/mp-kinematics/{mp_kinematics_id}/download/csv")
def download_mp_kinematics(video_id: str, result_video_id: str, mp_kinematics_id: str, response: Response, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)
    # @todo check result videoid matches given video id

    file_name = result_video_id + "_mp-kinematics.json"

    result_mp_kinematics = (
        result_mp_kinematics_manager.fetch_result_mp_kinematics_entry(mp_kinematics_id)
    )

    json_data = result_mp_kinematics.data

    # Pre-calculate the maximum number of poses and landmarks per pose for both landmarks and world_landmarks
    max_poses = max((len(entry['data']['landmarks']) for entry in json_data if entry['data']['landmarks']), default=0)
    max_landmarks_per_pose = max((max((len(pose) for pose in entry['data']['landmarks'])) for entry in json_data if entry['data']['landmarks']), default=0)
    max_world_landmarks_per_pose = max((max((len(pose) for pose in entry['data']['world_landmarks'])) for entry in json_data if entry['data']['world_landmarks']), default=0)

    print(max_poses, max_landmarks_per_pose, max_world_landmarks_per_pose)

    columns = ['timestamp']
    for pose in range(max_poses):
        for lm in range(max_landmarks_per_pose):
            columns += [f'pose_{pose}_landmark_{lm}_x', f'pose_{pose}_landmark_{lm}_y', f'pose_{pose}_landmark_{lm}_z', f'pose_{pose}_landmark_{lm}_visibility', f'pose_{pose}_landmark_{lm}_presence']
        for wlm in range(max_world_landmarks_per_pose):
            columns += [f'pose_{pose}_world_landmark_{wlm}_x', f'pose_{pose}_world_landmark_{wlm}_y', f'pose_{pose}_world_landmark_{wlm}_z', f'pose_{pose}_world_landmark_{wlm}_visibility', f'pose_{pose}_world_landmark_{wlm}_presence']

    def iterfile():
        buffer = io.StringIO()
        writer = csv.writer(buffer)
        writer.writerow(columns)

        for entry in json_data:
            row = [entry['timestamp']]
            for pose in entry['data']['landmarks']:
                for lm in pose:
                    row += [lm.get('x', ''), lm.get('y', ''), lm.get('z', ''), lm.get('visibility', ''), lm.get('presence', '')]
                # Fill missing landmarks for this pose
                row += [''] * (max_landmarks_per_pose - len(pose)) * 5
            # Fill missing poses
            row += [''] * ((max_poses - len(entry['data']['landmarks'])) * max_landmarks_per_pose * 5)

            for pose in entry['data']['world_landmarks']:
                for wlm in pose:
                    row += [wlm.get('x', ''), wlm.get('y', ''), wlm.get('z', ''), wlm.get('visibility', ''), wlm.get('presence', '')]
                # Fill missing world landmarks for this pose
                row += [''] * (max_world_landmarks_per_pose - len(pose)) * 5
            # Fill missing world poses
            row += [''] * ((max_poses - len(entry['data']['world_landmarks'])) * max_world_landmarks_per_pose * 5)

            writer.writerow(row)
            buffer.seek(0)
            yield buffer.getvalue()
            buffer.truncate(0)
            buffer.seek(0)

    return StreamingResponse(iterfile(), media_type="text/csv", headers={"Content-Disposition": "attachment; filename=kinematics_data.csv"})


@router.get("/{video_id}/results/{result_video_id}/blendshapes/{blendshapes_id}/download")
def download_blendshapes(video_id: str, result_video_id: str, blendshapes_id: str, response: Response, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)
    # @todo check result videoid matches given video id

    file_name = result_video_id + "_blendshapes.json"

    result_blendshapes = result_blendshapes_manager.fetch_result_blendshapes_entry(
        blendshapes_id
    )

    response.headers["Content-Disposition"] = 'attachment; filename="' + file_name + '"'
    return result_blendshapes.data


@router.get("/{video_id}/results/{result_video_id}/audio_files/{audio_file_id}/download")
def download_audio_file(video_id: str, result_video_id: str, audio_file_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)
    # @todo check result videoid matches given video id

    file_name = result_video_id + "_masked_voice.mp3"

    result_audio_file = result_audio_files_manager.fetch_result_audio_files_entry(
        audio_file_id
    )

    response = Response(content=bytes(result_audio_file.data), media_type="audio/mp3")
    response.headers["Content-Disposition"] = 'attachment; filename="' + file_name + '"'

    return response


@router.get("/{video_id}/results/{result_video_id}/extra_files/{extra_file_id}/download")
def download_extra_file(video_id: str, result_video_id: str, extra_file_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]
    video_manager.assert_user_has_video(video_id, user_id)
    # @todo check result videoid matches given video id

    result_extra_file = result_extra_files_manager.fetch_result_extra_files_entry(
        extra_file_id
    )

    file_name = result_video_id + "_extrafile." + result_extra_file.ending

    response = Response(content=bytes(result_extra_file.data))
    response.headers["Content-Disposition"] = 'attachment; filename="' + file_name + '"'

    return response
