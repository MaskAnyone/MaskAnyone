from typing import List, Literal

from pipeline.PipelineTypes import DetectionResult, DetectionType, PartDetectionMethods, PartToDetect
import numpy as np


class  BaseDetector:
    def __init__(self, parts_to_detect: List[PartToDetect]):
        self.silhouette_methods: PartDetectionMethods = {} # the specific models for each part (e.g head_model etc)
        self.boundingbox_methods: PartDetectionMethods = {}
        self.parts_to_detect: List[PartToDetect] = self.init_parts_to_detect(parts_to_detect) # the order in which
        self.current_results: List[DetectionResult] = []

    def detect(self, frame: np.ndarray, timestamp_ms: int) -> List[DetectionResult]:
        # Runs the adequate detection method for each body part.
        # During part processing results from other parts can be used via self.current_results
        # (e.g use the detection of the body silhouette, to find the background, without re_computing this silhouette)

        self.current_results= []
        for part_to_detect in self.parts_to_detect:
            part_result: np.ndarray = self.detect_part(frame, part_to_detect.part_name, part_to_detect.detection_type, timestamp_ms)
            self.current_results.append({"part_name": part_to_detect.part_name, "detection_type": part_to_detect.detection_type, "mask": part_result})
        return self.current_results

    def detect_part(self, frame: np.ndarray, part_name: str, type: DetectionType, timestamp_ms: int) -> np.ndarray:
        if type == "silhouette":
            return self.detect_silhouette(frame, part_name, timestamp_ms)
        elif type == "boundingbox":
            return self.detect_boundingbox(frame, part_name, timestamp_ms)  
        else:
            raise Exception(f"Invalid detection type given: {type}")

    def detect_silhouette(self, frame: np.ndarray, part_name: str,timestamp_ms: int) -> np.ndarray:
        # Detects the Silhouette of a certain video_part (e.g head, body...)
        if part_name not in self.silhouette_methods:
            raise Exception(f"Detection model does not support silhouette detection for video_part: {part_name}")
        return self.silhouette_methods[part_name](frame, timestamp_ms)

    def detect_boundingbox(self, frame: np.ndarray, part_name: str, timestamp_ms: int) -> np.ndarray:
        # Detects the Boundingbox of a certain video_part (e.g head, body...)
        if part_name not in self.boundingbox_methods:
            raise Exception(f"Detection model does not support bounding-box detection for video_part: {part_name}")
        return self.boundingbox_methods[part_name](frame, timestamp_ms)