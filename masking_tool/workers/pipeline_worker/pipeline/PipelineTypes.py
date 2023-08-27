from typing import Any, Callable, Literal, Optional, TypedDict
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
    detection_params: dict


class HidingStrategy(TypedDict):
    key: HidingStrategyKeys
    params: dict


class HidingStategies(TypedDict):
    part_name: HidingStrategy


class PartToMask(TypedDict):
    part_name: str
    masking_method: str
    params: dict
    save_timeseries: bool


class PartMaskingMethods(TypedDict):
    part_name: Any  # callable


class MaskingResult(TypedDict):
    part_name: str
    mask: np.ndarray


class Params3D(TypedDict):
    blender: bool
    blenderParams: dict
    blendshapes: bool
    blendshapesParams: dict
    skeleton: bool
    skeletonParams: dict
