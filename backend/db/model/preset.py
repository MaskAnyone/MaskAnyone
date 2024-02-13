from dataclasses import dataclass


@dataclass
class Preset:
    id: str
    name: str
    description: str
    data: dict
    user_id: str
