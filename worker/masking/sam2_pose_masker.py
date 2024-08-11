import cv2
import numpy as np
import mediapipe

from typing import Callable
from communication.sam2_client import Sam2Client
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2


colors = [
    (0, 0, 255),   # Red
    (0, 255, 0),   # Green
    (255, 0, 0),   # Blue
    (0, 255, 255), # Yellow
    (255, 0, 255), # Magenta
    (255, 255, 0), # Cyan
    # Add more colors if needed
]


def configure_landmarker():
    model_path = '/worker_models/pose_landmarker_heavy.task'

    options = mediapipe.tasks.vision.PoseLandmarkerOptions(
        base_options=mediapipe.tasks.BaseOptions(model_asset_path=model_path, delegate=mediapipe.tasks.BaseOptions.Delegate.CPU),
        running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
        output_segmentation_masks=True,
        num_poses=1
    )

    landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)
    return landmarker


def draw_landmarks_on_image(rgb_image, detection_result):
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


class Sam2PoseMasker:
    _sam2_client: Sam2Client
    _input_path: str
    _output_path: str
    _progress_callback: Callable[[int], None]

    def __init__(
            self,
            sam2_client: Sam2Client,
            input_path: str,
            output_path: str,
            progress_callback: Callable[[int], None]
    ):
        self._sam2_client = sam2_client
        self._input_path = input_path
        self._output_path = output_path
        self._progress_callback = progress_callback

    def mask(self, video_masking_data: dict):
        print("Starting SAM2 video masking with options", video_masking_data)

        file = open(self._input_path, "rb")
        content = file.read()
        file.close()

        masks = self._sam2_client.segment_video(
            video_masking_data['posePrompts'],
            content
        )

        video_capture = cv2.VideoCapture(self._input_path)
        frame_width = video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = video_capture.get(cv2.CAP_PROP_FPS)

        video_writer = cv2.VideoWriter(
            self._output_path,
            cv2.VideoWriter_fourcc(*'mp4v'),
            fps=sample_rate,
            frameSize=(int(frame_width), int(frame_height))
        )

        bounding_boxes = self._calculate_full_object_bounding_boxes(masks)
        estimation_input_bounding_boxes = self._calculate_estimation_input_bounding_boxes(bounding_boxes, frame_width, frame_height)

        landmarkers = {}
        previous_bbox = {}

        for object_id, bbox_dict in estimation_input_bounding_boxes.items():
            previous_bbox[object_id] = None  # Initialize previous_bbox for each object

        idx = 0
        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = video_capture.get(cv2.CAP_PROP_POS_MSEC)

            output_frame = frame.copy()
            self._render_all_masks_on_image(output_frame, frame_width, idx, masks)
            self._render_bounding_boxes(output_frame, bounding_boxes, idx, (255, 255, 255))
            self._render_bounding_boxes(output_frame, estimation_input_bounding_boxes, idx, (0, 255, 0))




            # ======================================
            crop_alpha = 0.85

            for object_id, bbox_dict in estimation_input_bounding_boxes.items():
                # Get the correct bounding box for the current frame index (idx)
                bbox = None
                for frame_idx in sorted(bbox_dict.keys()):
                    if frame_idx <= idx:
                        bbox = bbox_dict[frame_idx]
                    else:
                        break

                if bbox is not None:
                    # Check if the bounding box has changed
                    if object_id not in landmarkers or previous_bbox[object_id] != bbox:
                        # Initialize a new landmarker since the bounding box has changed
                        landmarkers[object_id] = configure_landmarker()
                        previous_bbox[object_id] = bbox  # Update the previous bbox

                    # Crop the frame using the bounding box
                    cropped_frame = frame[bbox[1]:bbox[3], bbox[0]:bbox[2]]
                    cropped_frame = cropped_frame.astype(np.uint8)
                    cropped_frame_height, cropped_frame_width, _ = cropped_frame.shape

                    # Crop the mask using the bounding box
                    mask = masks[idx][object_id][0]
                    cropped_mask = mask[bbox[1]:bbox[3], bbox[0]:bbox[2]]

                    # Create reverse mask
                    reverse_mask = ~cropped_mask
                    reverse_mask_8bit = (reverse_mask * 255).astype(np.uint8)

                    # Find contours and draw them on the reverse mask
                    cropped_contours, _ = cv2.findContours(cropped_mask.astype(np.uint8), cv2.RETR_EXTERNAL,
                                                           cv2.CHAIN_APPROX_SIMPLE)
                    cv2.drawContours(reverse_mask_8bit, cropped_contours, -1, 0, round(cropped_frame_width / 200))

                    # Create a boolean mask
                    reverse_mask_bool = reverse_mask_8bit > 0

                    # Apply the overlay using crop_alpha
                    overlay = np.zeros_like(cropped_frame)
                    cropped_frame[reverse_mask_bool] = (
                                crop_alpha * overlay[reverse_mask_bool] + (1 - crop_alpha) * cropped_frame[
                            reverse_mask_bool]).astype(np.uint8)

                    # Convert cropped_frame to mediapipe image
                    mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=cropped_frame)

                    # Detect landmarks
                    pose_landmarker_result = landmarkers[object_id].detect_for_video(mp_image, int(frame_timestamp_ms))

                    # Get the region of interest and draw landmarks on it
                    x_min, y_min, x_max, y_max = bbox
                    region_of_interest = output_frame[y_min:y_max, x_min:x_max]
                    draw_landmarks_on_image(region_of_interest, pose_landmarker_result)

                    # Place the updated region back into the output frame
                    output_frame[y_min:y_max, x_min:x_max] = region_of_interest

            # ==========================================

            output_frame = cv2.cvtColor(output_frame, cv2.COLOR_RGB2BGR)
            video_writer.write(output_frame)
            idx += 1

        video_capture.release()
        video_writer.release()

    def _calculate_full_object_bounding_boxes(self, masks, iou_threshold=0.5):
        bounding_boxes = {}
        active_bboxes = {}

        for idx in range(len(masks)):
            # Iterate over all objects in the frame
            for object_id in range(1, len(masks[idx]) + 1):
                mask = masks[idx][object_id][0]
                current_bbox = self._calculate_bounding_box_from_mask(mask)
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

    def _render_bounding_boxes(self, output_frame, bounding_boxes, current_frame_idx, color):
        for object_id, bboxes in bounding_boxes.items():
            # Find the most recent bounding box for the current frame
            relevant_bbox = None
            for frame_idx in sorted(bboxes.keys()):
                if frame_idx <= current_frame_idx:
                    relevant_bbox = bboxes[frame_idx]
                else:
                    break

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

        # Add margin (up to 10% of width or height)
        margin_width = int(0.1 * width)
        margin_height = int(0.1 * height)

        x_min = max(0, x_min - margin_width)
        y_min = max(0, y_min - margin_height)
        x_max = min(frame_width, x_max + margin_width)
        y_max = min(frame_height, y_max + margin_height)

        # Calculate new width and height
        width = x_max - x_min
        height = y_max - y_min

        # Make the bounding box square
        if width > height:
            diff = width - height
            y_min = max(0, y_min - diff // 2)
            y_max = min(frame_height, y_max + (diff - diff // 2))
        else:
            diff = height - width
            x_min = max(0, x_min - diff // 2)
            x_max = min(frame_width, x_max + (diff - diff // 2))

        return [np.int64(x_min), np.int64(y_min), np.int64(x_max), np.int64(y_max)]

    def _render_all_masks_on_image(self, image, frame_width, frame_idx, masks):
        for object_id in range(1, len(masks[frame_idx]) + 1):
            mask = masks[frame_idx][object_id][0]
            color = colors[(object_id - 1) % len(colors)]
            self._render_mask_on_image(image, frame_width, mask, color)

    def _render_mask_on_image(self, image, frame_width, mask, color):
        alpha = 0.5

        overlay = np.zeros_like(image)
        overlay[:, :, 0] = color[0]
        overlay[:, :, 1] = color[1]
        overlay[:, :, 2] = color[2]

        border_color = (0, 0, 0)
        contours, _ = cv2.findContours(mask.astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        image[mask] = (alpha * overlay[mask] + (1 - alpha) * image[mask]).astype(np.uint8)
        cv2.drawContours(image, contours, -1, border_color, round(frame_width / 600), cv2.LINE_AA)
