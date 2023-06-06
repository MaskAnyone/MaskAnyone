import os

from helpers import create_black_bg
from masking import blur, extract_skeleton, extract_face
from person_removal import remove_person_bbox, remove_person_estimate_bg, remove_person_silhoutte, remove_person_silhoutte_mp
from models import MaskingStrategy, HidingStrategy, RunParams

video_base_path = "videos"


def mask_body(video_path: str, background_video_path: str, masking_strategy: MaskingStrategy, ignore_head: bool) -> str:
    masked_video_path = None
    if masking_strategy == MaskingStrategy.BLUR:
        masked_video_path = blur(video_path, background_video_path, "body", 0.25)
    elif masking_strategy == MaskingStrategy.MEDIAPIPE:
        masked_video_path = extract_skeleton(video_path, background_video_path, "mediapipe")
    elif masking_strategy == MaskingStrategy.CHARACTER_3D:
        raise NotImplemented()
    if ignore_head:
        # remove head points because they are already there from explicit face extraction
        pass
    return masked_video_path

def mask_face(video_path: str, background_video_path: str, masking_strategy: MaskingStrategy):
    masked_video_path = None
    if masking_strategy == MaskingStrategy.BLUR:
        masked_video_path = blur(video_path, background_video_path, "face", 0.25)
    elif masking_strategy == MaskingStrategy.MEDIAPIPE:
        masked_video_path = extract_face(video_path, background_video_path, "mediapipe")
    elif masking_strategy == MaskingStrategy.CHARACTER_3D:
        raise NotImplemented()

    return masked_video_path

def hide_person(video_path: str, removal_strategy: HidingStrategy, removal_model: str = "mediapipe"):
    if removal_strategy == HidingStrategy.NONE:
        return video_path
    elif removal_strategy == HidingStrategy.BBOX:
        return remove_person_bbox(video_path, 0.25)
    elif removal_strategy == HidingStrategy.SILHOUTTE:
        if removal_model == "yolo":
            return remove_person_silhoutte(video_path)
        else:
            return remove_person_silhoutte_mp(video_path)
    elif removal_strategy == HidingStrategy.ESTIMATE:
        return remove_person_estimate_bg(video_path)

def create_person_mask(video_path: str, body_strategy: MaskingStrategy, face_strategy: MaskingStrategy, background_video_path: str):
    ignore_head = body_strategy != MaskingStrategy.NONE and face_strategy != MaskingStrategy.NONE
    masked_video_path = background_video_path
    if body_strategy != MaskingStrategy.NONE:
        masked_video_path = mask_body(video_path, masked_video_path, body_strategy, ignore_head)
    if face_strategy != MaskingStrategy.NONE:
        masked_video_path = mask_face(video_path, masked_video_path, face_strategy)
    return masked_video_path

def run_masking(run_params: RunParams):
    background_video = None
    video_path = os.path.join(video_base_path, run_params.video)
    if run_params.extract_person_only:
        background_video = create_black_bg(video_path)
    else:
        background_video = hide_person(video_path,
                                       run_params.body_hiding_strategy,
                                       run_params.body_hiding_model)      
    video_person_masked_path = create_person_mask(video_path, run_params.body_masking_strategy, run_params.face_masking_strategy, background_video)
    return video_person_masked_path