import time
import io
import cv2

import numpy as np
from typing import Callable
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.mask_renderer import MaskRenderer
from masking.pose_renderer import PoseRenderer
from masking.media_pipe_image_landmarker import MediaPipeImageLandmarker

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

        chunk_generator = self._trigger_mask_generation(video_masking_data)
        mask_renderers = self._initialize_mask_renderers(video_masking_data)
        pose_renderers = self._initialize_pose_renderers(video_masking_data)

        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        video_writer = self._initialize_video_writer(frame_width, frame_height, sample_rate)

        sam2_masks_file = open(self._sam2_masks_path, "wb")
        sam2_masks_file.close()

        for npz_chunk in chunk_generator:
            # The chunks *should* always come in incremental order, so we can just read the next frame here and they should match
            success, frame = video_capture.read()
            if not success:
                raise RuntimeError("Failed to read next video frame")

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            output_frame = frame.copy()

            masks = np.load(io.BytesIO(npz_chunk))
            for name in masks.files:
                mask = masks[name][0]
                obj_id = int(name.split("_mask")[-1])
                print(name, obj_id, mask.shape, flush=True)

                mask_renderer = mask_renderers[obj_id]
                mask_renderer.apply_to_image(output_frame, mask, obj_id)

                current_bbox = self._calculate_bounding_box_from_mask(mask)
                if current_bbox is None:
                    continue

                # TODO: We need to add safety margin around bbox

                print("Calculated bbox", obj_id, current_bbox)
                cropped_sub_image = self._prepare_estimation_input_frame(frame, mask, current_bbox)
                pose_data = self._media_pipe_image_landmarker.compute_pose_data(cropped_sub_image)

                if pose_data is None:
                    continue

                xmin, ymin, xmax, ymax = current_bbox
                adjusted_pose = []
                for keypoint in pose_data:
                    if keypoint is not None and (
                            keypoint.x > 0 or keypoint.y > 0) and keypoint.visibility > 0.05:
                        # Translate the keypoint back to the original frame coordinates
                        adjusted_keypoint = (keypoint.x * (xmax - xmin) + xmin, keypoint.y * (ymax - ymin) + ymin)
                        adjusted_pose.append(adjusted_keypoint)
                    else:
                        adjusted_pose.append(None)

                pose_renderers[obj_id].render_keypoint_overlay(output_frame, adjusted_pose)

            output_frame = cv2.cvtColor(output_frame, cv2.COLOR_RGB2BGR)
            video_writer.write(output_frame)

        video_capture.release()
        video_writer.release()

        poses_file = open(self._poses_path, "w")
        poses_file.write("{}")
        poses_file.close()

        print("Elapsed time (total):", time.time() - start)

    def _read_video_content(self):
        with open(self._input_path, "rb") as file:
            return file.read()

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

    def _initialize_mask_renderers(self, video_masking_data: dict):
        return {
            int(obj_id_0) + 1: MaskRenderer(
                video_masking_data['hidingStrategies'][int(obj_id_0)],
                {'level': 4, 'object_borders': True, 'averageColor': True}
            )
            for obj_id_0 in video_masking_data['posePrompts'].keys()
        }

    def _initialize_pose_renderers(self, video_masking_data: dict):
        return {
            int(obj_id_0) + 1: PoseRenderer(video_masking_data['overlayStrategies'][int(obj_id_0)])
            for obj_id_0 in video_masking_data['posePrompts'].keys()
        }

    def _trigger_mask_generation(self, video_masking_data: dict):
        content = self._read_video_content()
        chunk_generator = self._sam2_client.stream_segment_video(video_masking_data['posePrompts'], content)
        del content
        return chunk_generator

    def _calculate_bounding_box_from_mask(self, segmentation_mask):
        # Find the coordinates of the non-zero values in the mask
        y_indices, x_indices = np.where(segmentation_mask > 0)

        if len(y_indices) == 0 or len(x_indices) == 0:
            # No object detected in the mask
            return None

        x_min = np.min(x_indices)
        x_max = np.max(x_indices)
        y_min = np.min(y_indices)
        y_max = np.max(y_indices)

        return [x_min, y_min, x_max, y_max]

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
