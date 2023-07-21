from dataclasses import dataclass


@dataclass
class ResultVideo:
    id: str
    video_id: str
    job_id: str
    video_info: dict
    created_at: str
