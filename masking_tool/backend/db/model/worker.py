from dataclasses import dataclass


@dataclass
class Worker:
    id: str
    job_id: str
    last_activity: str
