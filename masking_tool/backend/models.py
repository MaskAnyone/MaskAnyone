from pydantic import BaseModel
from enum import IntEnum

class HidingStrategy(IntEnum):
    NONE = 0 # keeps original video
    BBOX = 1 # Blacks-out the boundingbox
    SILHOUTTE = 2 # Blacks-out the silhoutte
    ESTIMATE = 3 # Estimates the background for the silhoutte

class MaskingStrategy(IntEnum):
    NONE = 0
    BLUR = 1
    SKELETON = 2
    CHARACTER_3D = 3

class RunParams(BaseModel):
    video: str
    extract_person_only: bool # if set to true, the masked person will not be placed back into the scene
    body_hiding_strategy: HidingStrategy
    body_hiding_model: str
    face_hiding_strategy: HidingStrategy
    face_hiding_model: str
    body_mask_creation_strategy: MaskingStrategy
    body_masking_model: str
    face_mask_creation_strategy: MaskingStrategy
    face_masking_model: str