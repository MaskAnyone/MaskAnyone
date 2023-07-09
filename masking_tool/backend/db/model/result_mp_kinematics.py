from dataclasses import dataclass


@dataclass
class ResultMpKinematics:
    id: str
    result_video_id: str
    job_id: str
    data: dict
