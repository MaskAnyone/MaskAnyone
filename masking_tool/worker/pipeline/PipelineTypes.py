from typing import Any, Callable, Literal, TypedDict
import numpy as np

DetectionType = Literal["silhouette", "boundingbox"]

class DetectionResult(TypedDict):
    part_name: str
    detection_type: DetectionType
    mask: np.ndarray

class PartDetectionMethods(TypedDict):
    part_name: Callable[...]

class PartToDetect(TypedDict):
    part_name: str
    detection_type: DetectionType