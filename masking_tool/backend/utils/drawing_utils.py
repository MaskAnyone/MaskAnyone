import os

import numpy as np
import cv2


def create_black_bg(video_path: str) -> str:
    cap = cv2.VideoCapture(video_path)
    vid_out_path = os.path.join("results", "temp.mp4")
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(vid_out_path, fourcc, fps, (width, height), isColor=False)

    for _ in range(frame_count):
        frame = np.zeros((height, width), dtype=np.uint8)
        out.write(frame)

    cap.release()
    out.release()
    return vid_out_path


def overlay(image, mask, color, alpha, resize=None):
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

def draw_segment_mask(image, mask):
    h, w, c = image.shape
    original_image = np.concatenate([image, np.full((h, w, 1), 255, dtype=np.uint8)], axis=-1)
    mask_img = np.zeros_like(image, dtype=np.uint8) #set up basic mask image
    mask_img[:, :] = (255,255,255) #set up basic mask image
    segm_2class = 0.2 + 0.8 * mask #set up a segmentation of the results of mediapipe
    segm_2class = np.repeat(segm_2class[..., np.newaxis], 3, axis=2) #set up a segmentation of the results of mediapipe
    annotated_image = mask_img * segm_2class * (1 - segm_2class) #take the basic mask image and make a sillhouette mask
    # append Alpha channel to sillhouetted mask so that we can overlay it to the original image
    mask = np.concatenate([annotated_image, np.full((h, w, 1), 255, dtype=np.uint8)], axis=-1)
    # Zero background where we want to overlay
    original_image[mask==0]=0 #for the original image we are going to set everything at zero for places where the mask has to go
    original_image = cv2.cvtColor(original_image, cv2.COLOR_RGB2BGR)
    return original_image