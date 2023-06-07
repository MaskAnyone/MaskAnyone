import os

from utils.drawing_utils import create_black_bg
from masking.MPMasker import MPMasker
from person_removal import blur, remove_person_bbox, remove_person_estimate_bg, remove_person_silhoutte, remove_person_silhoutte_mp
from models import MaskingStrategy, HidingStrategy, RunParams
from masking.maskers import maskers

video_base_path = "videos"

def hide_person(video_path: str, removal_strategy: HidingStrategy, face_only: bool, removal_model: str = "mediapipe"):
    if removal_strategy == HidingStrategy.NONE:
        return video_path
    elif removal_strategy == HidingStrategy.BBOX:
        return remove_person_bbox(video_path, face_only, 0.25 )
    elif removal_strategy == HidingStrategy.SILHOUTTE:
        if removal_model == "yolo":
            return remove_person_silhoutte(video_path)
        else:
            return remove_person_silhoutte_mp(video_path)
    elif removal_strategy == HidingStrategy.ESTIMATE:
        return remove_person_estimate_bg(video_path)
    elif removal_strategy == HidingStrategy.BLUR:
        return blur(video_path, face_only, 0.25)

def create_person_mask(video_path: str, masking_strategy: MaskingStrategy, head_only: bool, detailed_facemesh: bool,
                       detailed_fingers: bool, background_video_path: str) -> str:
    masker = maskers[masking_strategy]()
    if head_only:
        return masker.mask(video_path, background_video_path, True, False, False)
    else:
        return masker.mask(video_path, background_video_path, detailed_facemesh, True, detailed_fingers)

def run_masking(run_params: RunParams) -> str:
    background_video = None
    video_path = os.path.join(video_base_path, run_params.video)
    if run_params.extract_person_only:
        background_video = create_black_bg(video_path)
    else:
        background_video = hide_person(video_path,
                                       run_params.hiding_strategy,
                                       run_params.head_only_hiding)      
    video_person_masked_path = create_person_mask(video_path,
                                                  run_params.mask_creation_strategy,
                                                  run_params.head_only_masking, 
                                                  run_params.detailed_facemesh,
                                                  run_params.detailed_fingers,
                                                  background_video)
    return video_person_masked_path