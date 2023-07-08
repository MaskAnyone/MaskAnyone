from typing import List
from pipeline.PipelineTypes import MaskExtractionResult, PartToMask

import numpy as np


class BaseMaskExtractor:
    def __init__(self, parts_to_mask: List[PartToMask]):
        self.parts_to_mask: List[PartToMask] = parts_to_mask
        self.part_methods = {}

    def extract_mask(
        self, frame: np.ndarray, timestamp_ms: int
    ) -> List[MaskExtractionResult]:
        results = []
        for part in self.parts_to_mask:
            part_result = self.part_methods[part["part_name"]](frame, timestamp_ms)
            results.append(part_result)
        return results
