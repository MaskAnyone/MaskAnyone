import os
import cv2

from fastapi import APIRouter, Request, Response, HTTPException

from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from utils.request_utils import range_requests_response
from utils.preview_image_utils import aspect_preserving_resize_and_crop
from utils.video_utils import extract_codec_from_capture
from models import RunParams, RequestVideoUploadParams, FinalizeVideoUploadParams
from db.video_manager import VideoManager
from db.result_video_manager import ResultVideoManager
from db.db_connection import DBConnection


db_connection = DBConnection()
video_manager = VideoManager(db_connection)
result_video_manager = ResultVideoManager(db_connection)

router = APIRouter(
    prefix='/videos',
)


@router.get('')
def get_videos():
    videos = video_manager.fetch_videos()

    return {"videos": videos}


@router.get('/{video_id}')
def get_video_stream(video_id, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.get("/{video_id}/preview")
def get_preview_for_video(video_id: str):
    image_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".jpg")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()
        f.close()

    return Response(content=image_content, media_type="image/jpeg")


@router.post('/upload/request')
def request_video_upload(params: RequestVideoUploadParams):
    if video_manager.has_video_with_name(params.video_name):
        raise HTTPException(
            status_code=400, detail="A video with this name exists already"
        )

    video_manager.add_pending_video(params.video_id, params.video_name)

    return {}


@router.post("/upload/finalize")
def finalize_video_upload(params: FinalizeVideoUploadParams):
    video_path = os.path.join(VIDEOS_BASE_PATH, params.video_id + ".mp4")

    if not os.path.exists(video_path):
        raise HTTPException(
            status_code=400, detail="A video with this name does not exist"
        )

    capture = cv2.VideoCapture(video_path)

    frame_width = round(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = round(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = capture.get(cv2.CAP_PROP_FPS)
    frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
    duration = frame_count / fps

    codec = extract_codec_from_capture(capture)

    video_preview_image_path = os.path.join(VIDEOS_BASE_PATH, params.video_id + '.jpg')
    capture.set(cv2.CAP_PROP_POS_FRAMES, int(frame_count / 2))
    _, frame = capture.read()
    preview_image = aspect_preserving_resize_and_crop(frame, 80, 60)
    cv2.imwrite(video_preview_image_path, preview_image)

    capture.release()

    video_manager.set_video_to_valid(
        params.video_id,
        {
            "frame_width": frame_width,
            "frame_height": frame_height,
            "fps": round(fps),
            "frame_count": round(frame_count),
            "duration": duration,
            "codec": codec,
        },
    )

    return {}


@router.post("/upload/{video_id}")
async def upload_video(video_id, request: Request):
    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")

    video_content = await request.body()
    file = open(video_path, "wb")
    file.write(video_content)
    file.close()


@router.get("/{video_id}/results")
def get_results_for_video(video_id: str):
    result_videos = result_video_manager.fetch_result_videos(video_id)

    return {
        'result_videos': result_videos
    }


@router.get("/{video_id}/results/{result_video_id}")
def get_result_video_stream(video_id: str, result_video_id: str, request: Request):
    video_path = os.path.join(RESULT_BASE_PATH, video_id, result_video_id + ".mp4")

    if not os.path.exists(video_path):
        raise HTTPException(status_code=404, detail="Requested result video not found.")

    print(video_path)

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )


@router.get("/{video_id}/results/{result_video_id}/preview")
def get_result_preview_for_video(video_id: str, result_video_id: str):
    image_path = os.path.join(RESULT_BASE_PATH, video_id, result_video_id + ".png")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()
        f.close()

    return Response(content=image_content, media_type="image/png")

