from typing import List

import numpy as np
import cv2
import torch


def overlay_frames(base_image: np.ndarray, mask_images: List[np.ndarray]):
    for mask_image in mask_images:
        mask = cv2.cvtColor(mask_image, cv2.COLOR_BGR2GRAY)
        mask = cv2.threshold(mask, 1, 255, cv2.THRESH_BINARY)[1]
        masked_actual_image = cv2.bitwise_and(base_image, base_image, mask=255 - mask)
        base_image = cv2.bitwise_or(masked_actual_image, mask_image)
    return base_image


def draw_rectangle(array, x_min, y_min, x_max, y_max, value):
    array[y_min:y_max, x_min:x_max] = value
    return array


def yolo_draw_segmask(yolo_results):
    combined_mask = None
    for result in yolo_results:
        masks = result.masks.masks
        boxes = result.boxes.boxes
        clss = boxes[:, 5]
        people_indices = torch.where(clss == 0)
        people_masks = masks[people_indices]
        people_mask = torch.any(people_masks, dim=0)
        if not combined_mask:
            combined_mask = people_mask
        combined_mask = torch.logical_or(combined_mask, people_mask)
    combined_mask_np = combined_mask.cpu().numpy().astype(int)

    return combined_mask_np


def overlay_segmask(image, mask, color, alpha, resize=None):
    """Combines image and its segmentation mask into a single image.

    Params:
        image: Training image. np.ndarray,
        mask: Segmentation mask. np.ndarray,
        color: Color for segmentation mask rendering.  tuple[int, int, int] = (255, 0, 0)
        alpha: Segmentation mask's transparency. float = 0.5,
        resize: If provided, both image and its mask are resized before blending them together.
        tuple[int, int] = (1024, 1024))

    Returns:
        image_combined: The combined image. np.ndarray

    """
    # color = color[::-1]
    colored_mask = np.expand_dims(mask, 0).repeat(3, axis=0)
    colored_mask = np.moveaxis(colored_mask, 0, -1)
    masked = np.ma.MaskedArray(image, mask=colored_mask, fill_value=color)
    image_overlay = masked.filled()

    if resize is not None:
        image = cv2.resize(image.transpose(1, 2, 0), resize)
        image_overlay = cv2.resize(image_overlay.transpose(1, 2, 0), resize)

    image_combined = cv2.addWeighted(image, 1 - alpha, image_overlay, alpha, 0)

    return image_combined
