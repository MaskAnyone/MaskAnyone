from dataclasses import dataclass


@dataclass
class Job:
    id: str
    video_id: str
    result_video_id: str
    type: str
    status: str
    data: dict
    created_at: str
    started_at: str
    finished_at: str
    progress: int
