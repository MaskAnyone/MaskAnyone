from dataclasses import dataclass


@dataclass
class Video:
    id: str
    name: str
    status: str
    video_info: dict
    user_id: str
