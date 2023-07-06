from typing import Any, Callable, Literal, TypedDict
import numpy as np

DetectorModels = Literal["mediapipe", "yolo"]
DetectionType = Literal["silhouette", "boundingbox"]
HidingStrategyKeys = Literal["blur", "blackout"]


class DetectionResult(TypedDict):
    part_name: str
    detection_type: DetectionType
    mask: np.ndarray


class PartDetectionMethods(TypedDict):
    part_name: Any  # callable


class PartToDetect(TypedDict):
    part_name: str
    detection_type: DetectionType


class HidingStrategy(TypedDict):
    key: HidingStrategyKeys
    params: dict


class HidingStategies(TypedDict):
    part_name: HidingStrategy
