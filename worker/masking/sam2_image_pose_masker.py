import time
import io
import cv2
import json
import base64

import numpy as np
from typing import Callable
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.mask_renderer import MaskRenderer
from masking.pose_renderer import PoseRenderer
from masking.image_masker.media_pipe_image_landmarker import MediaPipeImageLandmarker
from masking.image_masker.async_video_writer import AsyncVideoWriter
from OneEuroFilter import OneEuroFilter

DEBUG = True
MIN_ALLOWED_OBJECT_SCALE = 0.01 # 1% of frame height or width

ONE_EURO_CONFIG = {
    'freq': 30.0,       # Default frame rate, will be replaced by video FPS if known
    'mincutoff': 1.0,   # Base smoothing
    'beta': 0.2,        # Responsiveness to motion
    'dcutoff': 1.0      # Derivative smoothing
}

class Sam2ImagePoseMasker:
    _sam2_client: Sam2Client
    _openpose_client: OpenposeClient
    _input_path: str
    _output_path: str
    _sam2_masks_path: str
    _poses_path: str
    _progress_callback: Callable[[int], None]
    _media_pipe_image_landmarker: MediaPipeImageLandmarker

    def __init__(
            self,
            sam2_client: Sam2Client,
            openpose_client: OpenposeClient,
            input_path: str,
            output_path: str,
            sam2_masks_path: str,
            poses_path: str,
            progress_callback: Callable[[int], None]
    ):
        self._sam2_client = sam2_client
        self._openpose_client = openpose_client
        self._input_path = input_path
        self._output_path = output_path
        self._sam2_masks_path = sam2_masks_path
        self._poses_path = poses_path
        self._progress_callback = progress_callback
        self._media_pipe_image_landmarker = MediaPipeImageLandmarker()

    def mask(self, video_masking_data: dict):
        start = time.time()

        print(video_masking_data, flush=True)
        chunk_generator = self._trigger_mask_generation(video_masking_data)
        mask_renderers = self._initialize_mask_renderers(video_masking_data)
        pose_renderers = self._initialize_pose_renderers(video_masking_data)

        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        async_video_writer = AsyncVideoWriter(self._output_path, (int(frame_width), int(frame_height)), sample_rate)

        keypoint_filters = self._initialize_keypoint_filters(video_masking_data, sample_rate)

        sam2_masks_file = open(self._sam2_masks_path, "w")
        poses_file = open(self._poses_path, "w")
        for frame_idx, npz_chunk in enumerate(chunk_generator):
            # The chunks *should* always come in incremental order, so we can just read the next frame here and they should match
            success, frame = video_capture.read()
            if not success:
                raise RuntimeError("Failed to read next video frame")

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            output_frame = frame.copy()
            timestamp = frame_idx / (sample_rate if sample_rate else ONE_EURO_CONFIG['freq'])

            masks = np.load(io.BytesIO(npz_chunk))
            for name in masks.files:
                mask = masks[name][0]
                obj_id = int(name.split("_mask")[-1])

                mask_renderer = mask_renderers[obj_id]
                mask_renderer.apply_to_image(output_frame, mask, obj_id)

                current_bbox = self._calculate_bounding_box_from_mask(mask, frame_width, frame_height)
                if current_bbox is None:
                    continue

                if DEBUG:
                    self._render_bounding_box(output_frame, current_bbox)

                cropped_sub_image = self._prepare_estimation_input_frame(frame, mask, current_bbox)

                pose_data = None
                if video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_pose':
                    pose_data = self._media_pipe_image_landmarker.compute_pose_data(cropped_sub_image)
                elif video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_face':
                    pose_data = self._media_pipe_image_landmarker.compute_face_data(cropped_sub_image)
                elif video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_hand':
                    pose_data = self._media_pipe_image_landmarker.compute_hand_data(cropped_sub_image)
                elif video_masking_data['overlayStrategies'][obj_id - 1].startswith('openpose'):
                    pose_data = self._compute_openpose_pose_data(video_masking_data['overlayStrategies'][obj_id - 1], cropped_sub_image)
                    #print(pose_data, flush=True)
                else:
                    raise Exception(f'Unknown overlay strategy, got {video_masking_data["overlayStrategies"][obj_id - 1]}')

                if pose_data is None:
                    continue

                xmin, ymin, xmax, ymax = current_bbox
                obj_scale = max(xmax - xmin, ymax - ymin) / max(frame_width, frame_height)
                adjusted_pose = self._adjust_and_filter_pose(
                    video_masking_data['overlayStrategies'][obj_id - 1],
                    pose_data, current_bbox, keypoint_filters[obj_id], obj_scale, timestamp
                )
                #print(adjusted_pose, flush=True)

                pose_renderers[obj_id].render_keypoint_overlay(output_frame, adjusted_pose)
                poses_file.write(json.dumps({ "frame": frame_idx, "object_id": obj_id, "keypoints": adjusted_pose }) + "\n")

            output_frame = cv2.cvtColor(output_frame, cv2.COLOR_RGB2BGR)
            async_video_writer.write(output_frame)

            sam2_masks_file.write(json.dumps({
                "frame": frame_idx,
                "npz_base64": base64.b64encode(npz_chunk).decode("utf-8")
            }) + "\n")

        video_capture.release()
        async_video_writer.close()
        sam2_masks_file.close()
        poses_file.close()

        print("Elapsed time (total):", time.time() - start)

    def _compute_openpose_pose_data(self, overlay_strategy, cropped_sub_image):
        options = {
            'model_pose': 'BODY_25',
            'face': False,
            'hand': False
        }

        if overlay_strategy == 'openpose_body25b':
            options['model_pose'] = 'BODY_25B'
        elif overlay_strategy == 'openpose_face':
            options['face'] = True
        elif overlay_strategy == 'openpose_body_135':
            options['model_pose'] = 'BODY_135'

        _, encoded_img = cv2.imencode(".jpg", cropped_sub_image)
        return self._openpose_client.estimate_pose_on_image(encoded_img.tobytes(), options)

    def _read_video_content(self):
        with open(self._input_path, "rb") as file:
            return file.read()

    def _open_video(self):
        video_capture = cv2.VideoCapture(self._input_path)
        frame_width = video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = video_capture.get(cv2.CAP_PROP_FPS)

        return video_capture, frame_width, frame_height, sample_rate

    def _initialize_mask_renderers(self, video_masking_data: dict):
        return {
            int(obj_id_0) + 1: MaskRenderer(
                video_masking_data['hidingStrategies'][int(obj_id_0)],
                {'level': 4, 'object_borders': True, 'averageColor': True}
            )
            for obj_id_0 in range(len(video_masking_data['hidingStrategies']))
        }

    def _initialize_pose_renderers(self, video_masking_data: dict):
        return {
            int(obj_id_0) + 1: PoseRenderer(video_masking_data['overlayStrategies'][int(obj_id_0)])
            for obj_id_0 in range(len(video_masking_data['overlayStrategies']))
        }

    def _initialize_keypoint_filters(self, video_masking_data: dict, sample_rate: float):
        config = {
            **ONE_EURO_CONFIG,
            'freq': sample_rate if sample_rate else ONE_EURO_CONFIG['freq'],
        }

        strategy_to_kp_count = {
            'mp_pose': MediaPipeImageLandmarker.POSE_KEYPOINT_COUNT,
            'mp_face': MediaPipeImageLandmarker.FACE_KEYPOINT_COUNT,
            'mp_hand': MediaPipeImageLandmarker.HAND_KEYPOINT_COUNT,
            'openpose': 25,
            'openpose_body25b': 25,
            'openpose_face': 25 + 70,
            'openpose_body_135': 135,
        }

        result = {}

        for obj_id_0, strategy in enumerate(video_masking_data['overlayStrategies']):
            if strategy not in strategy_to_kp_count:
                raise ValueError(f"Unknown overlay strategy: '{strategy}' for object {obj_id_0 + 1}")

            keypoint_count = strategy_to_kp_count[strategy]
            result[int(obj_id_0) + 1] = [
                (OneEuroFilter(**config), OneEuroFilter(**config))
                for _ in range(keypoint_count)
            ]

        return result

    def _trigger_mask_generation(self, video_masking_data: dict):
        content = self._read_video_content()
        chunk_generator = self._sam2_client.stream_segment_video(video_masking_data['posePrompts'], content)
        del content
        return chunk_generator

    def _calculate_bounding_box_from_mask(self, segmentation_mask, frame_width: int, frame_height: int):
        # Find the coordinates of the non-zero values in the mask
        y_indices, x_indices = np.where(segmentation_mask > 0)

        if len(y_indices) == 0 or len(x_indices) == 0:
            # No object detected in the mask
            return None

        x_min = np.min(x_indices)
        x_max = np.max(x_indices)
        y_min = np.min(y_indices)
        y_max = np.max(y_indices)

        bbox_width = x_max - x_min
        bbox_height = y_max - y_min

        x_margin = max(10, int(0.05 * bbox_width))
        y_margin = max(10, int(0.05 * bbox_height))

        x_min = max(0, x_min - x_margin)
        y_min = max(0, y_min - y_margin)
        x_max = min(frame_width - 1, x_max + x_margin)
        y_max = min(frame_height - 1, y_max + y_margin)

        return [x_min, y_min, x_max, y_max]

    def _prepare_estimation_input_frame(self, frame, mask, bbox):
        crop_alpha = 1.0

        cropped_frame = frame[bbox[1]:bbox[3], bbox[0]:bbox[2]]
        cropped_frame = cropped_frame.astype(np.uint8)
        cropped_frame_height, cropped_frame_width, _ = cropped_frame.shape

        cropped_mask = mask[bbox[1]:bbox[3], bbox[0]:bbox[2]]

        reverse_mask = ~cropped_mask
        reverse_mask_8bit = (reverse_mask * 255).astype(np.uint8)

        cropped_contours, _ = cv2.findContours(cropped_mask.astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(reverse_mask_8bit, cropped_contours, -1, 0, round(cropped_frame_width / 100))

        reverse_mask_bool = reverse_mask_8bit > 0

        overlay = np.zeros_like(cropped_frame)
        cropped_frame[reverse_mask_bool] = (crop_alpha * overlay[reverse_mask_bool] + (1 - crop_alpha) * cropped_frame[reverse_mask_bool]).astype(np.uint8)

        return cropped_frame

    def _render_bounding_box(self, output_frame, current_bbox):
        start_point = (current_bbox[0], current_bbox[1])
        end_point = (current_bbox[2], current_bbox[3])
        cv2.rectangle(output_frame, start_point, end_point, (255, 0, 0), 2)

    def _adjust_and_filter_pose(self, overlay_strategy, pose_data, bbox, filters, obj_scale, timestamp):
        xmin, ymin, xmax, ymax = bbox

        if overlay_strategy.startswith('openpose'):
            confidence_threshold = 0.005  # 0.05
            adjusted_pose = {
                'pose_keypoints': [],
                'face_keypoints': None,
                'left_hand_keypoints': None,
                'right_hand_keypoints': None
            }

            filter_index = 0  # To keep track of the filter per keypoint

            def process_keypoints(keypoints):
                nonlocal filter_index
                adjusted = []
                for keypoint in keypoints:
                    if keypoint is not None and (keypoint[0] > 0 or keypoint[1] > 0) and keypoint[2] > confidence_threshold:
                        x = keypoint[0] + xmin
                        y = keypoint[1] + ymin
                        x_filt, y_filt = filters[filter_index]
                        if obj_scale < MIN_ALLOWED_OBJECT_SCALE:
                            x_filt(x, timestamp)
                            y_filt(y, timestamp)
                            adjusted.append((x, y))
                        else:
                            x_smooth = x_filt(x, timestamp)
                            y_smooth = y_filt(y, timestamp)
                            adjusted.append((x_smooth, y_smooth))
                    else:
                        adjusted.append(None)
                    filter_index += 1
                return adjusted

            adjusted_pose['pose_keypoints'] = process_keypoints(pose_data['pose_keypoints'])

            if pose_data['face_keypoints'] is not None:
                adjusted_pose['face_keypoints'] = process_keypoints(pose_data['face_keypoints'])

            if pose_data['left_hand_keypoints'] is not None:
                adjusted_pose['left_hand_keypoints'] = process_keypoints(pose_data['left_hand_keypoints'])

            if pose_data['right_hand_keypoints'] is not None:
                adjusted_pose['right_hand_keypoints'] = process_keypoints(pose_data['right_hand_keypoints'])
        else:
            adjusted_pose = []
            for i, keypoint in enumerate(pose_data):
                # TODO: and keypoint.visibility > 0.05 but only exists for pose, not face and hand
                if keypoint is not None and (keypoint.x > 0 or keypoint.y > 0):
                    x = keypoint.x * (xmax - xmin) + xmin
                    y = keypoint.y * (ymax - ymin) + ymin
                    x_filt, y_filt = filters[i]
                    if obj_scale < MIN_ALLOWED_OBJECT_SCALE:
                        x_filt(x, timestamp)
                        y_filt(y, timestamp)
                        adjusted_pose.append((x, y))
                    else:
                        x_smooth = x_filt(x, timestamp)
                        y_smooth = y_filt(y, timestamp)
                        adjusted_pose.append((x_smooth, y_smooth))
                else:
                    adjusted_pose.append(None)

        return adjusted_pose
