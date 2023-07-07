import numpy as np
import cv2

from pipeline.PipelineTypes import DetectionResult, HidingStategies, HidingStrategy


class Hider:
    def __init__(self, hiding_strategies):
        self.hiding_strategies: HidingStategies = hiding_strategies

    def hide_frame_part(
        self, base_image: np.ndarray, detection_result: DetectionResult
    ) -> np.ndarray:
        hiding_strategy = self.hiding_strategies[detection_result["part_name"]]
        if hiding_strategy["key"] == "blur":
            result = self.hide_blur(
                base_image, detection_result["mask"], hiding_strategy["params"]
            )
        elif hiding_strategy["key"] == "blackout":
            result = self.hide_blackout(
                base_image, detection_result["mask"], hiding_strategy["params"]
            )
        else:
            raise Exception(
                f"Invalid hiding strategy specified for {detection_result['part_name']}"
            )
        return result

    def hide_blur(
        self, base_image: np.ndarray, mask: np.ndarray, params: dict
    ) -> np.ndarray:
        # ToDo use params, maybe also specify them as a specifiy type
        blurred_image = cv2.GaussianBlur(base_image, (23, 23), 30)
        base_image[mask == 0] = blurred_image[mask == 0]
        return base_image

    def hide_blackout(
        self, base_image: np.ndarray, mask: np.ndarray, params: dict
    ) -> np.ndarray:
        # ToDo use params, maybe also specify them as a specifiy type
        base_image[mask == 0] = 0
        return base_image
