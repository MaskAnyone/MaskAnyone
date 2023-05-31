from pydantic import BaseModel
from enum import IntEnum

class RemovalStrategy(IntEnum):
    NONE = 0 # keeps original video
    BBOX = 1 # Blacks-out the boundingbox
    SILHOUTTE = 2 # Blacks-out the silhoutte
    ESTIMATE = 3 # Estimates the background for the silhoutte

class MaskingStrategy(IntEnum):
    NONE = 0
    BLUR = 1
    MEDIAPIPE = 2
    CHARACTER_3D = 3

class RunParams(BaseModel):
    video: str
    extract_person_only: bool # if set to true, the masked person will not be placed back into the scene
    person_removal_strategy: RemovalStrategy
    body_masking_strategy: MaskingStrategy
    face_masking_strategy: MaskingStrategy