import os
import mediapipe as mp
import cv2
import numpy as np

from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2


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
    num_poses=2)

_mask_colors = [
    [0, 0, 128],
    [0, 128, 0],
    [128, 0, 0]
]

def video_to_images(video_path, output_folder):
    # Create output folder if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    with PoseLandmarker.create_from_options(options) as landmarker:
        # Open the video file
        cap = cv2.VideoCapture(video_path)

        frame_count = 0
        while True:
            ret, frame = cap.read()
            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = cap.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)

            pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            output_image = cv2.cvtColor(mp_image.numpy_view(), cv2.COLOR_RGB2BGR)
            output_image[True] = 0

            if pose_landmarker_result.segmentation_masks:
                mask_index = 0
                for segmentation_mask in pose_landmarker_result.segmentation_masks:
                    mask = segmentation_mask.numpy_view()

                    output_image[mask > 0.1] = _mask_colors[mask_index]
                    mask_index += 1

            # Save the frame as a PNG image
            image_path = os.path.join(output_folder, f"{frame_count:05d}.png")
            cv2.imwrite(image_path, output_image, [cv2.IMWRITE_PNG_COMPRESSION, 0])  # Use PNG format

            frame_count += 1

        # Release the video capture object
        cap.release()


if __name__ == "__main__":
    video_path = "Test_TED_432_240_short2.mp4"  # Path to your input video file
    output_folder = "Test_TED_432_240_short2_masked"  # Path to the output folder

    video_to_images(video_path, output_folder)
    print("Video frames converted to PNG images successfully.")