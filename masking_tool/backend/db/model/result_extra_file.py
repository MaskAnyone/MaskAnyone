from dataclasses import dataclass


@dataclass
class ResultExtraFile:
    id: str
    result_video_id: str
    video_id: str
    job_id: str
    ending: str
    data: bytes
