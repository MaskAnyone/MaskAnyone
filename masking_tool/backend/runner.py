from helpers import create_black_bg
from masking import blur, extract_skeleton
from person_removal import remove_person_bbox, remove_person_silhoutte
from models import MaskingStrategy, RemovalStrategy, RunParams


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
        pass
    elif masking_strategy == MaskingStrategy.CHARACTER_3D:
        raise NotImplemented()

    return masked_video_path

def remove_person(video_path: str, removal_strategy: RemovalStrategy):
    if removal_strategy == RemovalStrategy.NONE:
        return video_path
    elif removal_strategy == RemovalStrategy.BBOX:
        return remove_person_bbox(video_path, 0.25)
    elif removal_strategy == RemovalStrategy.SILHOUTTE:
        return remove_person_silhoutte(video_path)

def mask_person(video_path: str, body_strategy: MaskingStrategy, face_strategy: MaskingStrategy, background_video_path: str):
    ignore_head = body_strategy != MaskingStrategy.NONE and face_strategy != MaskingStrategy.NONE
    masked_video_path = background_video_path
    if body_strategy != MaskingStrategy.NONE:
        masked_video_path = mask_body(video_path, masked_video_path, body_strategy, ignore_head)
    if face_strategy != MaskingStrategy.NONE:
        masked_video_path = mask_face(video_path, masked_video_path, face_strategy)
    return masked_video_path

def run_masking(run_params: RunParams):
    background_video = None
    if not run_params.extract_person_only:
        background_video = remove_person(run_params.video, run_params.person_removal_strategy)
    else:
        background_video = create_black_bg(run_params.video)
    video_person_masked_path = mask_person(run_params.video, run_params.body_masking_strategy, run_params.face_masking_strategy, background_video)
    return video_person_masked_path