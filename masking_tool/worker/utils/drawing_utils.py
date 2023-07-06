from typing import List

import numpy as np


def overlay_frames(base_image: np.ndarray, mask_images: List[np.ndarray]):
    for mask_image in mask_images:
        base_image += mask_image
    return base_image
