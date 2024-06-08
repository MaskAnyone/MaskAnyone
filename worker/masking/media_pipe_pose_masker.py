import mediapipe
import cv2
import numpy
import json
import os

from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2

from util.timeseries import (
    serialize_pose_landmarker_result,
)

# @todo check this
# https://github.com/google/mediapipe/issues/5120
# I0000 00:00:1709055327.274616       1 task_runner.cc:85] GPU suport is not available: INTERNAL: ; RET_CHECK failure (mediapipe/gpu/gl_context_egl.cc:77) display != EGL_NO_DISPLAYeglGetDisplay() returned error 0x300c

MODEL_PATH = '/worker_models/pose_landmarker_heavy.task'

PoseLandmarker = mediapipe.tasks.vision.PoseLandmarker

options = mediapipe.tasks.vision.PoseLandmarkerOptions(
    base_options=mediapipe.tasks.BaseOptions(model_asset_path=MODEL_PATH, delegate=mediapipe.tasks.BaseOptions.Delegate.CPU),
    running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
    output_segmentation_masks=True,
    num_poses=3
)

class MediaPipePoseMasker:
    _video_capture: cv2.VideoCapture
    _video_writer: cv2.VideoWriter

    def __init__(self, input_path: str, output_path: str):
        self._video_capture = cv2.VideoCapture(input_path)

        frame_width = self._video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = self._video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = self._video_capture.get(cv2.CAP_PROP_FPS)

        self._video_writer = cv2.VideoWriter(
            output_path,
            cv2.VideoWriter_fourcc(*'vp09'),
            #cv2.VideoWriter_fourcc(*'avc1'),
            fps = sample_rate,
            frameSize = (int(frame_width), int(frame_height))
        )

        # @todo remove duplication
        kinematics_timeseries_file_path = output_path.replace('.mp4', '.json')
        self._kinematics_timeseries_file = open(kinematics_timeseries_file_path, "w")

    def mask(self, video_masking_data: dict):
        print("Starting video masking with options", video_masking_data)

        landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)

        kinematics_data = []

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
                    self._apply_segmentation_mask(output_image, segmentation_mask)

                if video_masking_data['options']['skeleton']:
                    self._draw_landmarks_on_image(output_image, pose_landmarker_result)

            self._video_writer.write(output_image)

        self._kinematics_timeseries_file.write(json.dumps(kinematics_data))
        self._kinematics_timeseries_file.close()

        print('Video written', flush=True)

        self._video_capture.release()
        self._video_writer.release()

    def _apply_segmentation_mask(self, rgb_image, segmentation_mask) -> None:
        #mask = segmentation_mask.numpy_view()
        #seg_mask = numpy.repeat(mask[:, :, numpy.newaxis], 3, axis=2)
        #rgb_image[seg_mask > 0.3] = 0

        mask = segmentation_mask.numpy_view()
        seg_mask = mask > 0.3

        rgb_image[seg_mask, 0] = 0
        rgb_image[seg_mask, 1] = 0
        rgb_image[seg_mask, 2] = 0

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
