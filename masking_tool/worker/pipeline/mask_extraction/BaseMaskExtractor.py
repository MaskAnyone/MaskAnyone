from typing import List
from pipeline.PipelineTypes import MaskingResult, PartToMask

import numpy as np


class BaseMaskExtractor:
    def __init__(self, parts_to_mask: List[PartToMask]):
        self.parts_to_mask: List[PartToMask] = parts_to_mask
        self.part_methods = {}
        self.current_results: List[MaskingResult] = []
        self.current_blendshapes = {}
        self.timeseries = {}
        self.ts_headers = {}

    def extract_mask(self, frame: np.ndarray, timestamp_ms: int) -> List[MaskingResult]:
        results: List[MaskingResult] = []
        for part in self.parts_to_mask:
            part_name = part["part_name"]
            mask = self.part_methods[part_name](frame, timestamp_ms)
            if not mask is None:
                part_result: MaskingResult = {"part_name": part_name, "mask": mask}
                if part["save_timeseries"]:
                    part_result["timeseries"] = self.timeseries[part_name]
                self.timeseries[part_name] = []
                results.append(part_result)
        return results

    def get_ts_header(self, part_name: str):
        return self.ts_headers[part_name]

    def get_newest_blendshapes(self):
        return self.current_blendshapes

    def get_part_to_mask(self, part_name: str) -> PartToMask:
        return next(
            (part for part in self.parts_to_mask if part["part_name"] == part_name),
            None,
        )
