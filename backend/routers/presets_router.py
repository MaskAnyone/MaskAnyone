import os
import cv2

from fastapi import APIRouter, Request, Response
from models import CreatePresetParams
from db.preset_manager import PresetManager
from db.db_connection import DBConnection
from config import PRESETS_BASE_PATH, RESULT_BASE_PATH
from utils.preview_image_utils import aspect_preserving_resize_and_crop

preset_manager = PresetManager(DBConnection())

router = APIRouter(
    prefix="/presets",
)


@router.get("")
def fetch_presets(token_payload: dict = Depends(JWTBearer()))):
    user_id = token_payload["sub"]
    presets = preset_manager.fetch_presets(user_id)

    return {"presets": presets}


@router.post("/create")
def create_preset(params: CreatePresetParams, token_payload: dict = Depends(JWTBearer()))):
    user_id = token_payload["sub"]

    preset_manager.create_new_preset(
        params.id,
        params.name,
        params.description,
        params.data,
        user_id
    )

    video_path = os.path.join(RESULT_BASE_PATH, params.video_id, params.result_video_id + ".mp4")

    if not os.path.exists(video_path):
        raise HTTPException(
            status_code=400, detail="A result video with this name does not exist"
        )

    capture = cv2.VideoCapture(video_path)

    frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
    capture.set(cv2.CAP_PROP_POS_FRAMES, int(frame_count / 2))
    _, frame = capture.read()
    preview_image = aspect_preserving_resize_and_crop(frame, 300, 300)

    preview_image_path = os.path.join(PRESETS_BASE_PATH, params.id + ".jpg")
    cv2.imwrite(preview_image_path, preview_image)


@router.post("/{preset_id}/delete")
def delete_preset(preset_id: str, token_payload: dict = Depends(JWTBearer()))):
    user_id = token_payload["sub"]
    preset_manager.assert_user_has_preset(preset_id, user_id)

    preset_manager.delete_preset(preset_id)

    preview_image_path = os.path.join(PRESETS_BASE_PATH, preset_id + ".jpg")
    if os.path.exists(preview_image_path):
        os.remove(preview_image_path)


@router.get("/{preset_id}/preview")
def get_preview_for_preset(preset_id: str, token_payload: dict = Depends(JWTBearer()))):
    user_id = token_payload["sub"]
    preset_manager.assert_user_has_preset(preset_id, user_id)

    image_path = os.path.join(PRESETS_BASE_PATH, preset_id + ".jpg")

    if not os.path.exists(image_path):
        raise HTTPException(status_code=404, detail="Preview Image not found")

    with open(image_path, "rb") as f:
        image_content = f.read()
        f.close()

    return Response(content=image_content, media_type="image/jpeg")
