from dataclasses import dataclass


@dataclass
class ResultMpKinematics:
    id: str
    result_video_id: str
    video_id: str
    job_id: str
    type: str
    data: dict
