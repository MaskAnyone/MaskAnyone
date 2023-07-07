from typing import List
import numpy as np
from pipeline.mask_extraction.BaseMaskExtractor import BaseMaskExtractor

from pipeline.PipelineTypes import PartToMask


class MediaPipeMaskExtractor(BaseMaskExtractor):
    def __init__(self, parts_to_mask: List[PartToMask]):
        super.__init__(parts_to_mask)
        self.part_methods = {"body": self.mask_body, "face": self.mask_face}
        self.models = {}
        self.init_models()

    def init_models(self):
        pass

    def mask_body(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pass

    def mask_face(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        face_part = self.parts_to
        if face_part["masking_method"] == "skeleton":
            return self.mask_face_simple(frame, timestamp_ms)
        elif face_part["masking_method"] == "faceMesh":
            return self.mask_face_mash(frame, timestamp_ms)
        else:
            raise Exception("Invalid face masking method specified")

    def mask_face_simple(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pass

    def mask_face_detail(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pass
