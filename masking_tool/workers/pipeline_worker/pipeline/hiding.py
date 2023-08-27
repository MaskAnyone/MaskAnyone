import numpy as np
import cv2

from pipeline_worker.pipeline.PipelineTypes import (
    DetectionResult,
    HidingStategies,
    HidingStrategy,
)


class Hider:
    _contour_laplacian_level_settings = {
        1: {
            "blur_kernel_size": 17,
            "laplacian_kernel_size": 5,
            "laplacian_scale": 1.2,
            "laplacian_delta": 10,
        },
        2: {
            "blur_kernel_size": 11,
            "laplacian_kernel_size": 5,
            "laplacian_scale": 1,
            "laplacian_delta": 0,
        },
        3: {
            "blur_kernel_size": 7,
            "laplacian_kernel_size": 5,
            "laplacian_scale": 1,
            "laplacian_delta": -10,
        },
        4: {
            "blur_kernel_size": 5,
            "laplacian_kernel_size": 5,
            "laplacian_scale": 1,
            "laplacian_delta": -20,
        },
        5: {
            "blur_kernel_size": 3,
            "laplacian_kernel_size": 3,
            "laplacian_scale": 1.9,
            "laplacian_delta": 20,
        },
    }

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
        elif hiding_strategy["key"] == "contour":
            result = self.hide_contour_laplacian(
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
        blurred_image = cv2.GaussianBlur(
            base_image, (int(params["kernelSize"]), int(params["kernelSize"])), 30
        )
        base_image[mask != 0] = blurred_image[mask != 0]
        return base_image

    def hide_blackout(
        self, base_image: np.ndarray, mask: np.ndarray, params: dict
    ) -> np.ndarray:
        base_image[mask != 0] = int(params["color"])
        return base_image

    def hide_contour_laplacian(
        self, base_image: np.ndarray, mask: np.ndarray, params: dict
    ) -> np.ndarray:
        level_settings = self._contour_laplacian_level_settings[params["level"]]

        blurred_image = cv2.GaussianBlur(
            base_image,
            (level_settings["blur_kernel_size"], level_settings["blur_kernel_size"]),
            0,
        )

        gray_image = cv2.cvtColor(blurred_image, cv2.COLOR_RGB2GRAY)
        edge_image = cv2.Laplacian(
            gray_image,
            -1,
            ksize=level_settings["laplacian_kernel_size"],
            scale=level_settings["laplacian_scale"],
            delta=level_settings["laplacian_delta"],
            borderType=cv2.BORDER_DEFAULT,
        )
        final_image = cv2.cvtColor(edge_image, cv2.COLOR_GRAY2RGB)

        base_image[mask != 0] = final_image[mask != 0]
        return base_image
