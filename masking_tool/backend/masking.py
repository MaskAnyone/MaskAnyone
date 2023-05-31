from masking_tool.backend.helpers import merge_videos, save_video
from masking_tool.backend.models import MaskingStrategy, RunParams


def remove_person(video_path: str):
    pass

def mask_person(video_path: str):
    pass

def run_masking(run_params: RunParams):
    video_person_removed = remove_person(run_params.video)
    video_person_masked = mask_person(virun_params.videodeo)
    out_video = merge_videos(video_person_removed, video_person_masked)
    save_video(out_video)