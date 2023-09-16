from dataclasses import dataclass


@dataclass
class ResultBlendshapes:
    id: str
    result_video_id: str
    video_id: str
    job_id: str
    data: dict
