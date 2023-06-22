from pydantic import BaseModel
from enum import IntEnum

class HidingStrategy(IntEnum):
    NONE = 0 # keeps original video
    BBOX = 1 # Blacks-out the boundingbox
    SILHOUTTE_YOLO = 2 # Blacks-out the silhoutte with yolo
    SILHOUTTE_MP = 3 # Black-out the silhouette with mediapipe
    ESTIMATE = 4 # Estimates the background for the silhoutte
    BLUR = 5

class MaskingStrategy(IntEnum):
    NONE = 0
    MEDIAPIPE = 1
    OPENPOSE = 2
    CHARACTER_3D = 3

class RunParams(BaseModel):
    video: str
    extract_person_only: bool
    head_only_hiding: bool
    hiding_strategy: HidingStrategy
    head_only_masking: bool
    mask_creation_strategy: MaskingStrategy
    detailed_fingers: bool
    detailed_facemesh: bool

class RequestVideoUploadParams(BaseModel):
    video_id: str
    video_name: str

class FinalizeVideoUploadParams(BaseModel):
    video_id: str

