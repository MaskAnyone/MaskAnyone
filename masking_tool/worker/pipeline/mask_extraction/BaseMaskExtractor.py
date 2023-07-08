from typing import List
from pipeline.PipelineTypes import MaskExtractionResult, MaskingResult, PartToMask

import numpy as np


class BaseMaskExtractor:
    def __init__(self, parts_to_mask: List[PartToMask]):
        self.parts_to_mask: List[PartToMask] = parts_to_mask
        self.part_methods = {}
        self.current_results: List[MaskingResult] = []

    def extract_mask(
        self, frame: np.ndarray, timestamp_ms: int
    ) -> List[MaskExtractionResult]:
        results = []
        for part in self.parts_to_mask:
            part_result = self.part_methods[part["part_name"]](frame, timestamp_ms)
            if not part_result is None:
                results.append(part_result)
        return results

    def get_part_to_mask(self, part_name: str) -> PartToMask:
        return next(
            (part for part in self.parts_to_mask if part["part_name"] == part_name),
            None,
        )
