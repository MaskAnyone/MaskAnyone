from pydantic import BaseModel
from enum import IntEnum, Enum
from typing import Optional


class HidingStrategy(IntEnum):
    NONE = 0  # keeps original video
    BBOX = 1  # Blacks-out the boundingbox
    SILHOUTTE_YOLO = 2  # Blacks-out the silhoutte with yolo
    SILHOUTTE_MP = 3  # Black-out the silhouette with mediapipe
    ESTIMATE = 4  # Estimates the background for the silhoutte
    BLUR = 5


class MaskingStrategy(IntEnum):
    NONE = 0
    MEDIAPIPE = 1
    OPENPOSE = 2
    CHARACTER_3D = 3


class RunParams(BaseModel):
    id: str
    type: str
    video_ids: list[str]
    result_video_id: str
    run_data: dict


class RequestVideoUploadParams(BaseModel):
    video_id: str
    video_name: str


class FinalizeVideoUploadParams(BaseModel):
    video_id: str


class UpdateJobProgressParams(BaseModel):
    progress: int
    phase: Optional[str] = None


class CreatePresetParams(BaseModel):
    id: str
    name: str
    description: str
    data: dict
    video_id: str
    result_video_id: str


class MpKinematicsType(str, Enum):
    body = "body"
    face = "face"


class RegisterWorkerParams(BaseModel):
    capabilities: list[str]

class ResultDataType(str, Enum):
    sam2_masks = "sam2_masks"
    poses = "poses"
    qa = "qa"


class TrimVideoParams(BaseModel):
    new_video_id: str
    new_video_name: str
    start_time: float
    end_time: float


class RenameVideoParams(BaseModel):
    name: str


class ConvertFpsParams(BaseModel):
    new_video_id: str
    new_video_name: str
    target_fps: int
