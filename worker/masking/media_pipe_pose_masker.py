import mediapipe
import cv2
import json
import numpy as np

from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2

from util.timeseries import (
    serialize_pose_landmarker_result,
)

BLURRING_LEVELS = {
    1: (15, 15),
    2: (20, 20),
    3: (25, 25),
    4: (35, 35),
    5: (51, 51)
}

PIXELATION_LEVELS = {
    1: 150,
    2: 100,
    3: 70,
    4: 50,
    5: 30
}

CONTOURS_LEVELS = {
    1: {
        "blur_kernel_size": 3,
        "laplacian_kernel_size": 3,
        "laplacian_scale": 1.9,
        "laplacian_delta": 20,
    },
    2: {
        "blur_kernel_size": 5,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1,
        "laplacian_delta": -20,
    },
    3: {
        "blur_kernel_size": 7,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1,
        "laplacian_delta": -10,
    },
    4: {
        "blur_kernel_size": 11,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1,
        "laplacian_delta": 0,
    },
    5: {
        "blur_kernel_size": 17,
        "laplacian_kernel_size": 5,
        "laplacian_scale": 1.2,
        "laplacian_delta": 10,
    },
}

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

# @todo interesting blur = cv.bilateralFilter(img,9,75,75)

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
                    self._apply_segmentation_mask(output_image, segmentation_mask, video_masking_data)

                if video_masking_data['options']['skeleton']:
                    self._draw_landmarks_on_image(output_image, pose_landmarker_result)

            self._video_writer.write(output_image)

        self._kinematics_timeseries_file.write(json.dumps(kinematics_data))
        self._kinematics_timeseries_file.close()

        print('Video written', flush=True)

        self._video_capture.release()
        self._video_writer.release()

    def _apply_segmentation_mask(self, rgb_image, segmentation_mask, video_masking_data: dict) -> None:
        #mask = segmentation_mask.numpy_view()
        #seg_mask = numpy.repeat(mask[:, :, numpy.newaxis], 3, axis=2)
        #rgb_image[seg_mask > 0.3] = 0

        mask = segmentation_mask.numpy_view()
        seg_mask = mask > 0.3

        if video_masking_data['strategy'] == 'solid_fill':
            if video_masking_data['options']['averageColor']:
                average_color = np.mean(rgb_image, axis=(0, 1)).astype(int)
                fill_color = average_color
            else:
                fill_color = self._hex_to_rgb(video_masking_data['options']['color'])[::-1]

            rgb_image[seg_mask] = fill_color
            # Access individual channels via rgb_image[seg_mask, 0] = ...
        elif video_masking_data['strategy'] == 'blurring':
            mask = segmentation_mask.numpy_view()
            seg_mask = mask > 0.3

            kernel_size = BLURRING_LEVELS[video_masking_data['options']['level']]
            blurred_image = cv2.GaussianBlur(rgb_image, kernel_size, 0)
            rgb_image[seg_mask] = blurred_image[seg_mask]
        elif video_masking_data['strategy'] == 'pixelation':
            height, width = rgb_image.shape[:2]
            aspect_ratio = width / height

            small_height = PIXELATION_LEVELS[video_masking_data['options']['level']]
            small_width = int(small_height * aspect_ratio)

            small_image = cv2.resize(rgb_image, (small_width, small_height), interpolation=cv2.INTER_LINEAR)
            pixelated_image = cv2.resize(small_image, (width, height), interpolation=cv2.INTER_NEAREST)
            rgb_image[seg_mask] = pixelated_image[seg_mask]
        elif video_masking_data['strategy'] == 'contours':
            level_settings = CONTOURS_LEVELS[video_masking_data['options']['level']]

            blurred_image = cv2.GaussianBlur(
                rgb_image,
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
            final_contours_image = cv2.cvtColor(edge_image, cv2.COLOR_GRAY2RGB)

            rgb_image[seg_mask] = final_contours_image[seg_mask]
        else:
            raise Exception(f'Unknown video masking strategy, got {video_masking_data["strategy"]}')

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

    def _hex_to_rgb(self, hex_color):
        hex_color = hex_color.lstrip('#')

        hex_int = int(hex_color, 16)

        r = (hex_int >> 16) & 255
        g = (hex_int >> 8) & 255
        b = hex_int & 255

        return r, g, b
