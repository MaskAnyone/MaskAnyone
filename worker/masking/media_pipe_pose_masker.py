import mediapipe
import cv2
import json

from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
from typing import Callable
from masking.mask_renderer import MaskRenderer

from util.timeseries import (
    serialize_pose_landmarker_result,
)

MODEL_PATH = '/worker_models/pose_landmarker_heavy.task'

PoseLandmarker = mediapipe.tasks.vision.PoseLandmarker

options = mediapipe.tasks.vision.PoseLandmarkerOptions(
    base_options=mediapipe.tasks.BaseOptions(model_asset_path=MODEL_PATH, delegate=mediapipe.tasks.BaseOptions.Delegate.CPU),
    running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
    output_segmentation_masks=True,
    num_poses=3
)

# @todo interesting blur = cv.bilateralFilter(img,9,75,75)

class MediaPipePoseMasker:
    _video_capture: cv2.VideoCapture
    _video_writer: cv2.VideoWriter
    _progress_callback: Callable[[int], None]

    def __init__(self, input_path: str, output_path: str, progress_callback: Callable[[int], None]):
        self._video_capture = cv2.VideoCapture(input_path)
        self._progress_callback = progress_callback

        frame_width = self._video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = self._video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = self._video_capture.get(cv2.CAP_PROP_FPS)

        self._video_writer = cv2.VideoWriter(
            output_path,
            cv2.VideoWriter_fourcc(*'mp4v'),
            fps=sample_rate,
            frameSize=(int(frame_width), int(frame_height))
        )

        # @todo remove duplication
        kinematics_timeseries_file_path = output_path.replace('.mp4', '.json')
        self._kinematics_timeseries_file = open(kinematics_timeseries_file_path, "w")

    def mask(self, video_masking_data: dict):
        print("Starting video masking with options", video_masking_data)

        landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)

        total_frame_count = int(self._video_capture.get(cv2.CAP_PROP_FRAME_COUNT))
        current_frame = 0
        kinematics_data = []

        mask_renderer = MaskRenderer(video_masking_data['strategy'], video_masking_data['options'])

        while self._video_capture.isOpened():
            ret, frame = self._video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = self._video_capture.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)

            pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            # @todo make this nice
            kinematics_data.append(serialize_pose_landmarker_result(pose_landmarker_result, frame_timestamp_ms))

            output_image = cv2.cvtColor(mp_image.numpy_view(), cv2.COLOR_RGB2BGR)

            if pose_landmarker_result.segmentation_masks:
                for segmentation_mask in pose_landmarker_result.segmentation_masks:
                    mask = segmentation_mask.numpy_view()
                    mask_renderer.apply_to_image(output_image, mask > 0.3)

                if video_masking_data['options']['skeleton']:
                    self._draw_landmarks_on_image(output_image, pose_landmarker_result)

            self._video_writer.write(output_image)

            current_frame += 1
            self._progress_callback(round(current_frame / total_frame_count * 100))

        self._kinematics_timeseries_file.write(json.dumps(kinematics_data))
        self._kinematics_timeseries_file.close()

        print('Video written', flush=True)

        self._video_capture.release()
        self._video_writer.release()

    def _draw_landmarks_on_image(self, rgb_image, detection_result) -> None:
        pose_landmarks_list = detection_result.pose_landmarks

        # Loop through the detected poses to visualize.
        for idx in range(len(pose_landmarks_list)):
            pose_landmarks = pose_landmarks_list[idx]

            # Draw the pose landmarks.
            pose_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            pose_landmarks_proto.landmark.extend([
                landmark_pb2.NormalizedLandmark(x=landmark.x, y=landmark.y, z=landmark.z) for landmark in pose_landmarks
            ])

            solutions.drawing_utils.draw_landmarks(
                rgb_image,
                pose_landmarks_proto,
                solutions.pose.POSE_CONNECTIONS,
                solutions.drawing_styles.get_default_pose_landmarks_style()
            )
