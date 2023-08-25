import os
import mediapipe as mp
import cv2
import numpy as np

from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
from config import (
    BLENDSHAPES_BASE_PATH,
    RESULT_BASE_PATH,
    TS_BASE_PATH,
    VIDEOS_BASE_PATH,
)


model_path = os.getcwd() + '/models/pose_landmarker_heavy.task'

BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode

# Create a pose landmarker instance with the video mode:
options = PoseLandmarkerOptions(
    base_options=BaseOptions(model_asset_path=model_path),
    running_mode=VisionRunningMode.VIDEO,
    output_segmentation_masks=True,
    num_poses=1)


class STTNMaskCreator:
    _mask_colors = [
        [0, 0, 128],
        [0, 128, 0],
        [128, 0, 0]
    ]

    def run(self, video_id: str):
        video_in_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
        mask_out_dir = os.path.join(VIDEOS_BASE_PATH, video_id + "_inpainted")

        if not os.path.exists(mask_out_dir):
            os.makedirs(mask_out_dir)

        frame_count = 0
        with PoseLandmarker.create_from_options(options) as landmarker:
            video_cap = cv2.VideoCapture(video_in_path)

            while True:
                ret, frame = video_cap.read()
                if not ret:
                    break

                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame_timestamp_ms = video_cap.get(cv2.CAP_PROP_POS_MSEC)

                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)

                pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

                output_image = cv2.cvtColor(mp_image.numpy_view(), cv2.COLOR_RGB2BGR)
                output_image[True] = 0

                if pose_landmarker_result.segmentation_masks:
                    mask_index = 0
                    for segmentation_mask in pose_landmarker_result.segmentation_masks:
                        mask = segmentation_mask.numpy_view()

                        output_image[mask > 0.1] = self._mask_colors[mask_index]
                        mask_index += 1

                # Save the frame as a PNG image
                image_path = os.path.join(mask_out_dir, f"{frame_count:05d}.png")
                cv2.imwrite(image_path, output_image, [cv2.IMWRITE_PNG_COMPRESSION, 0])  # Use PNG format

                frame_count += 1

            # Release the video capture object
            video_cap.release()

        return mask_out_dir
