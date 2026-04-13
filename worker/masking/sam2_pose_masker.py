import cv2
import numpy as np
import os
import shutil
import json
import time

from typing import Callable
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from communication.rtmpose_client import RtmposeClient
from masking.mask_renderer import MaskRenderer
from masking.pose_renderer import PoseRenderer
from masking.media_pipe_landmarker import MediaPipeLandmarker
from masking.pose_postprocessor import PosePostprocessor

DEBUG = False
APPLY_CLAHE = False


class Sam2PoseMasker:
    _sam2_client: Sam2Client
    _openpose_client: OpenposeClient
    _rtmpose_client: RtmposeClient
    _input_path: str
    _output_path: str
    _sam2_masks_path: str
    _poses_path: str
    _progress_callback: Callable[[int], None]
    _media_pipe_landmarker: MediaPipeLandmarker
    _pose_postprocessor: PosePostprocessor

    def __init__(
            self,
            sam2_client: Sam2Client,
            openpose_client: OpenposeClient,
            rtmpose_client: RtmposeClient,
            input_path: str,
            output_path: str,
            sam2_masks_path: str,
            poses_path: str,
            progress_callback: Callable[[int], None]
    ):
        self._sam2_client = sam2_client
        self._openpose_client = openpose_client
        self._rtmpose_client = rtmpose_client
        self._input_path = input_path
        self._output_path = output_path
        self._sam2_masks_path = sam2_masks_path
        self._poses_path = poses_path
        self._progress_callback = progress_callback
        self._media_pipe_landmarker = MediaPipeLandmarker()
        self._pose_postprocessor = PosePostprocessor()

    def mask(self, video_masking_data: dict):
        start = time.time()
        self._progress_callback(1)

        content = self._read_video_content()
        self._progress_callback(5)
        model_variant = video_masking_data.get('samModel', 'sam2.1_hiera_small')
        self._progress_callback(10)  # SAM2 running — stays here until segmentation completes
        raw_mask_content = self._sam2_client.segment_video(video_masking_data['posePrompts'], content, model_variant)
        del content
        self._progress_callback(30)

        sam2_masks_file = open(self._sam2_masks_path, "wb")
        sam2_masks_file.write(raw_mask_content)
        sam2_masks_file.close()

        masks = self._sam2_client.decode_mask_npz_content(raw_mask_content)
        del raw_mask_content
        self._progress_callback(35)

        t_sam2 = time.time()
        print(f"[timing] sam2_segmentation: {t_sam2 - start:.1f}s")

        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        total_frames = int(video_capture.get(cv2.CAP_PROP_FRAME_COUNT))
        print(f"[timing] video: {total_frames} frames at {sample_rate:.1f}fps")

        bounding_boxes = self._calculate_full_object_bounding_boxes(masks)
        estimation_input_bounding_boxes = self._calculate_estimation_input_bounding_boxes(bounding_boxes, frame_width, frame_height)
        self._progress_callback(38)

        subvideo_output_dir = '/app/subvideos'
        t_subvideo_start = time.time()
        sub_videos = self._create_sub_videos(video_capture, estimation_input_bounding_boxes, masks, subvideo_output_dir)
        print(f"[timing] sub_video_creation: {time.time() - t_subvideo_start:.1f}s")
        self._progress_callback(45)

        t_pose_start = time.time()
        pose_data_dict = self._compute_pose_data(video_masking_data, sub_videos, total_frames)
        self._pose_postprocessor.postprocess(pose_data_dict, video_masking_data['overlayStrategies'], total_frames, sample_rate, estimation_input_bounding_boxes)
        print(f"[timing] pose_estimation: {time.time() - t_pose_start:.1f}s")
        self._progress_callback(55)

        shutil.rmtree(subvideo_output_dir, ignore_errors=True)



        def convert_numpy_to_native(obj):
            if isinstance(obj, np.ndarray):
                return obj.tolist()  # Convert numpy arrays to lists
            elif isinstance(obj, np.float64):
                return float(obj)  # Convert np.float64 to Python float
            elif isinstance(obj, dict):
                return {convert_numpy_to_native(k): convert_numpy_to_native(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                return [convert_numpy_to_native(i) for i in obj]
            else:
                return obj

        poses_file = open(self._poses_path, "w")
        data_converted = convert_numpy_to_native(pose_data_dict)
        json_data = json.dumps(data_converted)
        poses_file.write(json_data)
        poses_file.close()




        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        video_writer = self._initialize_video_writer(frame_width, frame_height, sample_rate)

        mask_renderers = {
            obj_id: MaskRenderer(
                video_masking_data['hidingStrategies'][obj_id - 1],
                {'level': 4, 'object_borders': True, 'averageColor': True}
            )
            for obj_id in pose_data_dict.keys()
        }

        pose_renderers = {
            obj_id: PoseRenderer(video_masking_data['overlayStrategies'][obj_id - 1])
            for obj_id in pose_data_dict.keys()
        }

        idx = 0
        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            output_frame = frame.copy()
            self._render_all_masks_on_image(output_frame, mask_renderers, idx, masks)

            if DEBUG:
                self._render_bounding_boxes(output_frame, bounding_boxes, idx, (255, 255, 255))
                self._render_bounding_boxes(output_frame, estimation_input_bounding_boxes, idx, (0, 255, 0))

            for obj_id, poses in pose_data_dict.items():
                if poses[idx] is not None:
                    current_pose = poses[idx]
                    pose_renderers[obj_id].render_keypoint_overlay(output_frame, current_pose)

            output_frame = cv2.cvtColor(output_frame, cv2.COLOR_RGB2BGR)
            video_writer.write(output_frame)
            idx += 1

            if total_frames > 0:
                render_progress = 55 + round((idx / total_frames) * 44)
                self._progress_callback(min(render_progress, 99))

        video_capture.release()
        video_writer.release()

        t_total = time.time() - start
        t_render = t_total - (t_pose_start - start) - (t_sam2 - start)
        print(f"[timing] render: {t_render:.1f}s")
        print(f"[timing] total: {t_total:.1f}s")

    def _open_video(self):
        video_capture = cv2.VideoCapture(self._input_path)
        frame_width = video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = video_capture.get(cv2.CAP_PROP_FPS)

        return video_capture, frame_width, frame_height, sample_rate

    def _initialize_video_writer(self, frame_width, frame_height, sample_rate):
        return cv2.VideoWriter(
            self._output_path,
            cv2.VideoWriter_fourcc(*'mp4v'),
            fps=sample_rate,
            frameSize=(int(frame_width), int(frame_height))
        )

    def _read_video_content(self):
        with open(self._input_path, "rb") as file:
            return file.read()

    def _select_bounding_box(self, bbox_dict, idx):
        bbox = None
        for frame_idx in sorted(bbox_dict.keys()):
            if frame_idx <= idx:
                bbox = bbox_dict[frame_idx]
            else:
                break
        return bbox

    def _prepare_estimation_input_frame(self, frame, mask, bbox):
        crop_alpha = 1.0

        # Crop the frame using the bounding box
        cropped_frame = frame[bbox[1]:bbox[3], bbox[0]:bbox[2]]
        cropped_frame = cropped_frame.astype(np.uint8)
        cropped_frame_height, cropped_frame_width, _ = cropped_frame.shape

        # Crop the mask using the bounding box
        cropped_mask = mask[bbox[1]:bbox[3], bbox[0]:bbox[2]]

        # Create reverse mask
        reverse_mask = ~cropped_mask
        reverse_mask_8bit = (reverse_mask * 255).astype(np.uint8)

        # Find contours and draw them on the reverse mask
        cropped_contours, _ = cv2.findContours(cropped_mask.astype(np.uint8), cv2.RETR_EXTERNAL,
                                               cv2.CHAIN_APPROX_SIMPLE)
        cv2.drawContours(reverse_mask_8bit, cropped_contours, -1, 0, round(cropped_frame_width / 100))

        # Create a boolean mask
        reverse_mask_bool = reverse_mask_8bit > 0

        # Apply the overlay using crop_alpha
        overlay = np.zeros_like(cropped_frame)
        cropped_frame[reverse_mask_bool] = (crop_alpha * overlay[reverse_mask_bool] + (1 - crop_alpha) * cropped_frame[reverse_mask_bool]).astype(np.uint8)

        return cropped_frame

    def _calculate_full_object_bounding_boxes(self, masks, iou_threshold=0.25):
        bounding_boxes = {}
        active_bboxes = {}
        for idx in masks.keys():
            # Iterate over all objects in the frame
            idx = int(idx)
            for object_id in range(1, len(masks[idx]) + 1):
                mask = masks[idx][object_id][0]
                current_bbox = self._calculate_bounding_box_from_mask(mask)
                if current_bbox is None:
                    continue

                start_point = current_bbox[0], current_bbox[1]
                end_point = current_bbox[2], current_bbox[3]

                if object_id not in active_bboxes:
                    # Initialize the first bounding box for the object
                    active_bboxes[object_id] = current_bbox
                    bounding_boxes[object_id] = {idx: current_bbox}
                else:
                    # Calculate IoU between the current frame's bbox and the active bbox
                    iou = self._calculate_iou(active_bboxes[object_id], current_bbox)

                    if iou < iou_threshold:
                        # If IoU is below the threshold, create a new bounding box entry
                        bounding_boxes[object_id][idx] = current_bbox
                        active_bboxes[object_id] = current_bbox
                    else:
                        # Update the active bounding box
                        active_bboxes[object_id][0] = min(active_bboxes[object_id][0], start_point[0])
                        active_bboxes[object_id][1] = min(active_bboxes[object_id][1], start_point[1])
                        active_bboxes[object_id][2] = max(active_bboxes[object_id][2], end_point[0])
                        active_bboxes[object_id][3] = max(active_bboxes[object_id][3], end_point[1])

        return bounding_boxes

    def _calculate_bounding_box_from_mask(self, segmentation_mask):
        # Find the coordinates of the non-zero values in the mask
        y_indices, x_indices = np.where(segmentation_mask > 0)

        if len(y_indices) == 0 or len(x_indices) == 0:
            # No object detected in the mask
            return None

        # Calculate the bounding box coordinates
        x_min = np.min(x_indices)
        x_max = np.max(x_indices)
        y_min = np.min(y_indices)
        y_max = np.max(y_indices)

        return [x_min, y_min, x_max, y_max]

    def _calculate_iou(self, bbox1, bbox2):
        # Calculate intersection
        x_left = max(bbox1[0], bbox2[0])
        y_top = max(bbox1[1], bbox2[1])
        x_right = min(bbox1[2], bbox2[2])
        y_bottom = min(bbox1[3], bbox2[3])

        if x_right < x_left or y_bottom < y_top:
            return 0.0

        intersection_area = (x_right - x_left) * (y_bottom - y_top)

        # Calculate union
        bbox1_area = (bbox1[2] - bbox1[0]) * (bbox1[3] - bbox1[1])
        bbox2_area = (bbox2[2] - bbox2[0]) * (bbox2[3] - bbox2[1])
        union_area = bbox1_area + bbox2_area - intersection_area

        iou = intersection_area / union_area
        return iou

    def _create_sub_videos(self, video_capture, estimation_input_bounding_boxes, masks, subvideo_output_dir):
        """Returns list of (obj_id, start_frame, path, content_bytes) tuples.

        content_bytes is the encoded mp4 in memory — no disk read needed for RTMPose/OpenPose.
        path is written to disk only so MediaPipe (which requires a file path) can read it.
        """
        sub_videos = []

        fps = video_capture.get(cv2.CAP_PROP_FPS)
        total_frames = int(video_capture.get(cv2.CAP_PROP_FRAME_COUNT))

        for obj_id, bbox_dict in estimation_input_bounding_boxes.items():
            sorted_frames = sorted(bbox_dict.keys())

            for i, start_frame in enumerate(sorted_frames):
                bbox = bbox_dict[start_frame]
                width = bbox[2] - bbox[0]
                height = bbox[3] - bbox[1]

                end_frame = sorted_frames[i + 1] - 1 if i < len(sorted_frames) - 1 else total_frames - 1

                os.makedirs(subvideo_output_dir, exist_ok=True)
                output_filename = f"{subvideo_output_dir}/object_{obj_id}_frame_{start_frame}.mp4"

                out = cv2.VideoWriter(output_filename, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))

                video_capture.set(cv2.CAP_PROP_POS_FRAMES, start_frame)
                clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))

                for frame_num in range(start_frame, end_frame + 1):
                    ret, frame = video_capture.read()
                    if not ret:
                        break

                    mask = masks[frame_num][obj_id][0]
                    cropped_frame = self._prepare_estimation_input_frame(frame, mask, bbox)

                    if APPLY_CLAHE:
                        lab_frame = cv2.cvtColor(cropped_frame, cv2.COLOR_BGR2LAB)
                        l_channel, a_channel, b_channel = cv2.split(lab_frame)
                        l_channel = clahe.apply(l_channel)
                        merged_frame = cv2.merge((l_channel, a_channel, b_channel))
                        cropped_frame = cv2.cvtColor(merged_frame, cv2.COLOR_LAB2BGR)

                    out.write(cropped_frame)

                out.release()

                # Read back into memory once — callers that need bytes (RTMPose, OpenPose) use
                # content directly; MediaPipe uses the path. No second disk read needed.
                with open(output_filename, 'rb') as f:
                    content = f.read()

                sub_videos.append((obj_id, start_frame, output_filename, content))

        video_capture.release()
        return sub_videos

    def _render_bounding_boxes(self, output_frame, bounding_boxes, current_frame_idx, color):
        for object_id, bboxes in bounding_boxes.items():
            # Find the most recent bounding box for the current frame
            relevant_bbox = self._select_bounding_box(bboxes, current_frame_idx)

            if relevant_bbox is not None:
                start_point = (relevant_bbox[0], relevant_bbox[1])
                end_point = (relevant_bbox[2], relevant_bbox[3])
                cv2.rectangle(output_frame, start_point, end_point, color, 2)

    def _calculate_estimation_input_bounding_boxes(self, bounding_boxes, frame_width, frame_height):
        estimation_input_bounding_boxes = {}

        for object_id, bboxes in bounding_boxes.items():
            estimation_input_bounding_boxes[object_id] = {}

            for frame_idx, bbox in bboxes.items():
                # Apply fine-tuning to each bounding box for the object
                fine_tuned_bbox = self._fine_tune_bounding_box(bbox, frame_width, frame_height)
                estimation_input_bounding_boxes[object_id][frame_idx] = fine_tuned_bbox

        return estimation_input_bounding_boxes

    def _fine_tune_bounding_box(self, bbox, frame_width, frame_height):
        x_min, y_min, x_max, y_max = bbox
        width = x_max - x_min
        height = y_max - y_min

        # Add safety margin (up to 5% of width or height)
        margin_width = int(0.05 * width)
        margin_height = int(0.05 * height)

        x_min = max(0, x_min - margin_width)
        y_min = max(0, y_min - margin_height)
        x_max = min(frame_width, x_max + margin_width)
        y_max = min(frame_height, y_max + margin_height)

        # Previously we would have squared the bounding box here. However, since we would black out this
        # additional area MediaPipe pads it anyway it shouldn't make a difference. Openpose, however,
        # takes flexible input ratios and thus benefits from smaller frame sizes in many cases

        return [np.int64(x_min), np.int64(y_min), np.int64(x_max), np.int64(y_max)]

    def _render_all_masks_on_image(self, image, mask_renderers, frame_idx, masks):
        if frame_idx not in masks: # If the 1st prompt is not on the 1st frame, there won't be any masks until the 1st promp
            return
        for object_id in range(1, len(masks[frame_idx]) + 1):
            mask = masks[frame_idx][object_id][0]
            mask_renderers[object_id].apply_to_image(image, mask, object_id)

    def _compute_pose_data(self, video_masking_data, sub_videos, frame_count):
        pose_data_dict = {}

        for obj_id, start_frame, path, content in sub_videos:
            strategy = video_masking_data['overlayStrategies'][obj_id - 1]

            if strategy == 'none':
                pose_data_dict[obj_id] = [None] * frame_count
                continue

            if obj_id not in pose_data_dict:
                pose_data_dict[obj_id] = [None] * frame_count

            if strategy == 'mp_pose':
                data = self._compute_mp_pose_data(path)
            elif strategy == 'mp_face':
                data = self._compute_mp_face_data(path)
            elif strategy == 'mp_hand':
                data = self._compute_mp_hand_data(path)
            elif strategy.startswith('openpose'):
                data = self._compute_openpose_pose_data(strategy, content)
            elif strategy.startswith('rtmpose'):
                data = self._compute_rtmpose_pose_data(strategy, content)
            else:
                raise Exception(f'Unknown overlay strategy, got {strategy}')

            pose_data_dict[obj_id][start_frame:start_frame + len(data)] = data

        return pose_data_dict

    def _compute_rtmpose_pose_data(self, overlay_strategy, content):
        model_map = {
            'rtmpose_s': 'rtmpose-s_8xb256-420e_coco-256x192',
            'rtmpose_m': 'rtmpose-m_8xb256-420e_coco-256x192',
            'rtmpose_l': 'rtmpose-l_8xb256-420e_coco-256x192',
            'rtmpose_ap10k': 'td-hm_hrnet-w32_8xb64-210e_ap10k-256x256',
        }
        model = model_map.get(overlay_strategy, 'rtmpose-m_8xb256-420e_coco-256x192')
        options = {'model': model}
        return self._rtmpose_client.estimate_pose_on_video(content, options)

    def _compute_openpose_pose_data(self, overlay_strategy, content):
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

        return self._openpose_client.estimate_pose_on_video(content, options)

    def _compute_mp_pose_data(self, sub_video_path):
        return self._media_pipe_landmarker.compute_pose_data(sub_video_path)

    def _compute_mp_face_data(self, sub_video_path):
        return self._media_pipe_landmarker.compute_face_data(sub_video_path)

    def _compute_mp_hand_data(self, sub_video_path):
        return self._media_pipe_landmarker.compute_hand_data(sub_video_path)

