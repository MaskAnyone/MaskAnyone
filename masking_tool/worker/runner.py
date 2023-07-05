import os

from utils.drawing_utils import create_black_bg
from utils.app_utils import save_preview_image
from masking.MPMasker import MPMasker
from person_removal import blur, remove_person_bbox, remove_person_estimate_bg, remove_person_silhoutte, remove_person_silhoutte_mp
from models import MaskingStrategy, HidingStrategy, RunParams
from masking.maskers import maskers

# @todo
video_base_path = "local_data/original"


def hide_person(video_path: str, hiding_strategy: HidingStrategy, face_only: bool):
    supports_face_only = [HidingStrategy.BLUR, HidingStrategy.BBOX]
    if face_only and hiding_strategy not in supports_face_only:
        raise Exception("The hiding strategy you selected does not support face only hiding")
    
    if hiding_strategy == HidingStrategy.NONE:
        return video_path
    elif hiding_strategy == HidingStrategy.BBOX:
        return remove_person_bbox(video_path, face_only, 0.25 )
    elif hiding_strategy == HidingStrategy.SILHOUTTE_YOLO:
            return remove_person_silhoutte(video_path)
    elif hiding_strategy == HidingStrategy.SILHOUTTE_MP:
            return remove_person_silhoutte_mp(video_path)
    elif hiding_strategy == HidingStrategy.ESTIMATE:
        return remove_person_estimate_bg(video_path)
    elif hiding_strategy == HidingStrategy.BLUR:
        return blur(video_path, face_only, 0.25)


def create_person_mask(video_path: str, masking_strategy: MaskingStrategy, head_only: bool, detailed_facemesh: bool,
                       detailed_fingers: bool, background_video_path: str) -> str:
    masker = maskers[masking_strategy]()
    if head_only:
        return masker.mask(video_path, background_video_path, True, False, False)
    else:
        return masker.mask(video_path, background_video_path, detailed_facemesh, True, detailed_fingers)


def run_masking(video_id, run_params: dict) -> str:
    background_video = None
    video_path = os.path.join(video_base_path, video_id + '.mp4')
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
    save_preview_image(video_person_masked_path)
    return video_person_masked_path