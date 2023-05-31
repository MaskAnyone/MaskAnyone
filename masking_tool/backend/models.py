from pydantic import BaseModel

class RemovalStrategy:
    BBOX = 0 # Blacks-out the boundingbox
    SILHOUTTE = 1 # Blacks-out the silhoutte
    ESTIMATE = 2 # Estimates the background for the silhoutte

class MaskingStrategy:
    NONE = 0
    BLUR = 1
    MEDIAPIPE_SKELETON = 2
    CHARACTER_3D = 3

class RunParams(BaseModel):
    video: str
    extract_person_only: bool # if set to true, the masked person will not be placed back into the scene
    person_removal_strategy: RemovalStrategy
    body_masking_strategy: MaskingStrategy
    face_masking_strategy: MaskingStrategy