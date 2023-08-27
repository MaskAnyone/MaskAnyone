from dataclasses import dataclass


@dataclass
class Result:
    video_result_id: str
    original_video_id: str
    job_id: str
    name: str
    created_at: str
    video_info: dict
    job_info: dict
    video_result_exists: bool
    kinematic_results_exists: bool
    audio_results_exists: bool
    blendshape_results_exists: bool
    extra_file_results_exists: bool
