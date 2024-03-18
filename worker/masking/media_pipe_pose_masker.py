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
    num_poses=12
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

    def mask(self):
        # Forward pass
        landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)

        masked_frames = []
        video_output_frames = []
        kinematics_data = []

        frame_counter = 0
        while self._video_capture.isOpened():
            ret, frame = self._video_capture.read()

            if ret:
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                #frame = self._preprocess_test(frame)
                frame_timestamp_ms = self._video_capture.get(cv2.CAP_PROP_POS_MSEC)

                mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)

                pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

                # @todo make this nice
                kinematics_data.append(serialize_pose_landmarker_result(pose_landmarker_result, frame_timestamp_ms))

                output_image = cv2.cvtColor(mp_image.numpy_view(), cv2.COLOR_RGB2BGR)

                if pose_landmarker_result.segmentation_masks:
                    for segmentation_mask in pose_landmarker_result.segmentation_masks:
                        mask = segmentation_mask.numpy_view()
                        seg_mask = numpy.repeat(mask[:, :, numpy.newaxis], 3, axis=2)

                        output_image[seg_mask > 0.3] = 0

                    output_image = self._draw_landmarks_on_image(output_image, pose_landmarker_result)
                    masked_frames.append(frame_counter)

                #self._video_writer.write(output_image)
                video_output_frames.append(output_image)
            else:
                break

            frame_counter += 1

        print('Forward pass finished, starting backwards pass', flush=True)

        # Backwards pass
        landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)

        total_frames = int(self._video_capture.get(cv2.CAP_PROP_FRAME_COUNT))
        fps = self._video_capture.get(cv2.CAP_PROP_FPS)
        total_duration_ms = (total_frames / fps) * 1000

        for i in range(total_frames - 1, -1, -1):
            if i in masked_frames and i - 1 in masked_frames and i - 2 in masked_frames and i - 3 in masked_frames:
                continue

            self._video_capture.set(cv2.CAP_PROP_POS_FRAMES, i)
            ret, frame = self._video_capture.read()

            if ret:
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame = self._preprocess_test(frame)
                frame_timestamp_ms = total_duration_ms - self._video_capture.get(cv2.CAP_PROP_POS_MSEC)

                mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)

                pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

                output_image = cv2.cvtColor(mp_image.numpy_view(), cv2.COLOR_RGB2BGR)

                if pose_landmarker_result.segmentation_masks:
                    for segmentation_mask in pose_landmarker_result.segmentation_masks:
                        mask = segmentation_mask.numpy_view()
                        seg_mask = mask > 0.3  # Create a boolean mask where the condition is met

                        # Assign red color to the masked areas by setting the appropriate channels
                        output_image[seg_mask, 0] = 255  # Red channel
                        output_image[seg_mask, 1] = 0    # Green channel
                        output_image[seg_mask, 2] = 0    # Blue channel

                    output_image = self._draw_landmarks_on_image(output_image, pose_landmarker_result)

                    print("Override output frame", i, flush=True)
                    video_output_frames[i] = output_image
                    kinematics_data[i] = serialize_pose_landmarker_result(pose_landmarker_result, frame_timestamp_ms)

                #self._video_writer.set(cv2.CAP_PROP_POS_FRAMES, i)
                #self._video_writer.write(output_image)
            else:
                break

        print('Backward pass finished, writing video', flush=True)

        self._kinematics_timeseries_file.write(json.dumps(kinematics_data))
        self._kinematics_timeseries_file.close()

        for frame in video_output_frames:
            self._video_writer.write(frame)

        print('Video written', flush=True)

        self._video_capture.release()
        self._video_writer.release()

    def _draw_landmarks_on_image(self, rgb_image, detection_result):
        pose_landmarks_list = detection_result.pose_landmarks
        annotated_image = numpy.copy(rgb_image)

        # Loop through the detected poses to visualize.
        for idx in range(len(pose_landmarks_list)):
            pose_landmarks = pose_landmarks_list[idx]

            # Draw the pose landmarks.
            pose_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            pose_landmarks_proto.landmark.extend([
                landmark_pb2.NormalizedLandmark(x=landmark.x, y=landmark.y, z=landmark.z) for landmark in pose_landmarks
            ])

            solutions.drawing_utils.draw_landmarks(
                annotated_image,
                pose_landmarks_proto,
                solutions.pose.POSE_CONNECTIONS,
                solutions.drawing_styles.get_default_pose_landmarks_style()
            )

        return annotated_image

    # @todo properly integrate this or remove it
    def _preprocess_test(self, image):
        # Apply a slight Gaussian blur to smooth out transitions and reduce artifacts
        blurred_image = cv2.GaussianBlur(image, (5, 5), 0)

        # Calculate the 10th percentile value per channel on the blurred image
        p10_val_per_channel = numpy.percentile(blurred_image, 10, axis=(0, 1))

        # Subtract the 10th percentile value from each channel of the original image
        normalized_image = image - p10_val_per_channel

        # Clip to ensure no negative values
        normalized_image = numpy.clip(normalized_image, 0, None)

        # Find the maximum value per channel after normalization
        max_val_per_channel = numpy.max(normalized_image, axis=(0, 1))

        # Add a small epsilon to avoid division by zero
        epsilon = 1e-10
        max_val_per_channel = numpy.where(max_val_per_channel == 0, 1,
                                       max_val_per_channel)  # Replace 0s with 1s to avoid division by 0

        # Scale the values to the 0-255 range, adding epsilon to avoid division by zero
        scaled_image = (normalized_image / (max_val_per_channel + epsilon)) * 255

        # Convert the scaled values to unsigned 8-bit integers, as this is the standard format for images
        final_image = scaled_image.astype(numpy.uint8)
        return final_image

