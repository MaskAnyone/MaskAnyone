import cv2
import numpy as np
import mediapipe
import supervision as sv
import os
import shutil

from typing import Callable
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
from masking.smoothing import smooth_pose


colors = [
    (0, 0, 255),   # Red
    (0, 255, 0),   # Green
    (255, 0, 0),   # Blue
    (0, 255, 255), # Yellow
    (255, 0, 255), # Magenta
    (255, 255, 0), # Cyan
    # Add more colors if needed
]

DEBUG = False
SMOOTHING = True


def configure_landmarker():
    model_path = '/worker_models/pose_landmarker_heavy.task'

    options = mediapipe.tasks.vision.PoseLandmarkerOptions(
        base_options=mediapipe.tasks.BaseOptions(model_asset_path=model_path, delegate=mediapipe.tasks.BaseOptions.Delegate.CPU),
        running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
        num_poses=1,
    )

    landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)
    return landmarker


def configure_face_landmarker():
    model_path = '/worker_models/face_landmarker.task'

    options = mediapipe.tasks.vision.FaceLandmarkerOptions(
        base_options=mediapipe.tasks.BaseOptions(model_asset_path=model_path, delegate=mediapipe.tasks.BaseOptions.Delegate.CPU),
        running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
        output_face_blendshapes=True,
        output_facial_transformation_matrixes=True,
        num_faces=1
    )

    landmarker = mediapipe.tasks.vision.FaceLandmarker.create_from_options(options)
    return landmarker


def draw_face_landmarks_on_image(rgb_image, face_landmarks):
    image_height, image_width, _ = rgb_image.shape

    face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
    face_landmarks_proto.landmark.extend([
      landmark_pb2.NormalizedLandmark(x=landmark[0] / image_width, y=landmark[1] / image_height, z=0.5) for landmark in face_landmarks
    ])

    solutions.drawing_utils.draw_landmarks(
        image=rgb_image,
        landmark_list=face_landmarks_proto,
        connections=mediapipe.solutions.face_mesh.FACEMESH_TESSELATION,
        landmark_drawing_spec=None,
        connection_drawing_spec=mediapipe.solutions.drawing_styles
        .get_default_face_mesh_tesselation_style())
    solutions.drawing_utils.draw_landmarks(
        image=rgb_image,
        landmark_list=face_landmarks_proto,
        connections=mediapipe.solutions.face_mesh.FACEMESH_CONTOURS,
        landmark_drawing_spec=None,
        connection_drawing_spec=mediapipe.solutions.drawing_styles
        .get_default_face_mesh_contours_style())
    solutions.drawing_utils.draw_landmarks(
        image=rgb_image,
        landmark_list=face_landmarks_proto,
        connections=mediapipe.solutions.face_mesh.FACEMESH_IRISES,
          landmark_drawing_spec=None,
          connection_drawing_spec=mediapipe.solutions.drawing_styles
          .get_default_face_mesh_iris_connections_style())


BODY_25_PAIRS = [
    (0, 1), (1, 2), (2, 3), (3, 4), (1, 5), (5, 6), (6, 7), (1, 8),
    (8, 9), (9, 10), (10, 11), (8, 12), (12, 13), (13, 14), (0, 15),
    (15, 17), (0, 16), (16, 18), (14, 19), (19, 20), (14, 21),
    (11, 22), (22, 23), (11, 24)
]


def render_body25_pose(image, keypoints):
    keypoints = np.array(keypoints)

    # Draw all keypoints
    for i in range(len(keypoints)):
        if keypoints[i][0] < 1 and keypoints[i][1] < 1:
            continue

        point = tuple(map(int, keypoints[i][:2]))
        cv2.circle(image, point, 4, (0, 0, 0), -1)

    # Iterate over each pair and draw lines
    for pair in BODY_25_PAIRS:
        partA = pair[0]
        partB = pair[1]

        if keypoints[partA][0] < 1 and keypoints[partA][1] < 1 or keypoints[partB][0] < 1 and keypoints[partB][1] < 1:
            continue

        pointA = tuple(map(int, keypoints[partA]))
        pointB = tuple(map(int, keypoints[partB]))
        cv2.line(image, pointA, pointB, (0, 255, 0), 2)

    return image


MP_POSE_PAIRS = [
    (0, 1), (1, 2), (2, 3), (3, 7), (0, 4), (4, 5), (5, 6), (6, 8),
    (9, 10), (11, 12), (11, 13), (13, 15), (15, 19), (15, 17), (17, 19),
    (12, 14), (14, 16), (16, 20), (16, 18), (18, 20), (11, 23), (12, 24),
    (23, 25), (24, 26), (25, 27), (26, 28), (23, 24),
    (28, 30), (28, 32), (30, 32), (27, 29), (27, 31), (29, 31)
]

def render_mediapipe_pose(image, keypoints):
    keypoints = np.array(keypoints)

    # Draw all keypoints
    for i in range(len(keypoints)):
        if keypoints[i][0] < 1 and keypoints[i][1] < 1:
            continue

        point = tuple(map(int, keypoints[i][:2]))
        cv2.circle(image, point, 4, (0, 0, 0), -1)

    # Iterate over each pair and draw lines
    for pair in MP_POSE_PAIRS:
        partA = pair[0]
        partB = pair[1]

        if keypoints[partA][0] < 1 and keypoints[partA][1] < 1 or keypoints[partB][0] < 1 and keypoints[partB][1] < 1:
            continue

        pointA = tuple(map(int, keypoints[partA][:2]))
        pointB = tuple(map(int, keypoints[partB][:2]))
        cv2.line(image, pointA, pointB, (0, 255, 0), 2)

    return image


class Sam2PoseMasker:
    _sam2_client: Sam2Client
    _openpose_client: OpenposeClient
    _input_path: str
    _output_path: str
    _progress_callback: Callable[[int], None]

    def __init__(
            self,
            sam2_client: Sam2Client,
            openpose_client: OpenposeClient,
            input_path: str,
            output_path: str,
            progress_callback: Callable[[int], None]
    ):
        self._sam2_client = sam2_client
        self._openpose_client = openpose_client
        self._input_path = input_path
        self._output_path = output_path
        self._progress_callback = progress_callback

    def mask(self, video_masking_data: dict):
        content = self._read_video_content()
        masks = self._sam2_client.segment_video(video_masking_data['posePrompts'], content)
        del content

        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        total_frames = int(video_capture.get(cv2.CAP_PROP_FRAME_COUNT))

        bounding_boxes = self._calculate_full_object_bounding_boxes(masks)
        estimation_input_bounding_boxes = self._calculate_estimation_input_bounding_boxes(bounding_boxes, frame_width, frame_height)

        subvideo_output_dir = '/app/subvideos'
        sub_video_paths = self._create_sub_videos(video_capture, estimation_input_bounding_boxes, masks, subvideo_output_dir)
        video_capture.release()

        pose_data_dict = self._compute_pose_data(video_masking_data, sub_video_paths, total_frames)
        self._streamline_pose_data(video_masking_data, pose_data_dict, estimation_input_bounding_boxes, total_frames, sample_rate)

        shutil.rmtree(subvideo_output_dir)

        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        video_writer = self._initialize_video_writer(frame_width, frame_height, sample_rate)

        idx = 0
        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            output_frame = frame.copy()
            self._render_all_masks_on_image(output_frame, frame_width, idx, masks)

            if DEBUG:
                self._render_bounding_boxes(output_frame, bounding_boxes, idx, (255, 255, 255))
                self._render_bounding_boxes(output_frame, estimation_input_bounding_boxes, idx, (0, 255, 0))

            for obj_id, poses in pose_data_dict.items():
                if poses[idx] is not None:
                    current_pose = poses[idx]

                    # Adjust pose keypoints from cropped frame to original frame
                    adjusted_pose = []
                    for keypoint in current_pose:
                        if keypoint is not None:
                            adjusted_pose.append(keypoint)
                        else:
                            adjusted_pose.append((np.float64(0), np.float64(0)))

                    # Render the adjusted pose on the original frame
                    if video_masking_data['overlayStrategies'][obj_id - 1] == 'openpose':
                        render_body25_pose(output_frame, adjusted_pose)
                    elif video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_pose':
                        render_mediapipe_pose(output_frame, adjusted_pose)
                    elif video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_face':
                        draw_face_landmarks_on_image(output_frame, adjusted_pose)

            output_frame = cv2.cvtColor(output_frame, cv2.COLOR_RGB2BGR)
            video_writer.write(output_frame)
            idx += 1

        video_capture.release()
        video_writer.release()

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

        for idx in range(len(masks)):
            # Iterate over all objects in the frame
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
        sub_video_paths = []

        fps = video_capture.get(cv2.CAP_PROP_FPS)
        total_frames = int(video_capture.get(cv2.CAP_PROP_FRAME_COUNT))

        # Iterate through each object in estimation_input_bounding_boxes
        for obj_id, bbox_dict in estimation_input_bounding_boxes.items():
            sorted_frames = sorted(bbox_dict.keys())

            for i, start_frame in enumerate(sorted_frames):
                bbox = bbox_dict[start_frame]  # bbox in (xmin, ymin, xmax, ymax) format
                width = bbox[2] - bbox[0]
                height = bbox[3] - bbox[1]

                # Determine the end frame for this sub-video
                if i < len(sorted_frames) - 1:
                    end_frame = sorted_frames[i + 1] - 1
                else:
                    end_frame = total_frames - 1

                # Define the output video filename
                os.makedirs(subvideo_output_dir, exist_ok=True)

                output_filename = f"{subvideo_output_dir}/object_{obj_id}_frame_{start_frame}.mp4"
                sub_video_paths.append(output_filename)

                out = cv2.VideoWriter(output_filename, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))

                # Seek to the start_frame
                video_capture.set(cv2.CAP_PROP_POS_FRAMES, start_frame)

                for frame_num in range(start_frame, end_frame + 1):
                    ret, frame = video_capture.read()
                    if not ret:
                        break

                    mask = masks[frame_num][obj_id][0]
                    cropped_frame = self._prepare_estimation_input_frame(frame, mask, bbox)

                    # Write the cropped frame to the output video
                    out.write(cropped_frame)

                # Release the writer for this sub-video
                out.release()

        # Release the video capture object
        video_capture.release()
        return sub_video_paths

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

    def _compute_pose_data(self, video_masking_data, sub_video_paths, frame_count):
        pose_data_dict = {}

        for sub_video_path in sub_video_paths:
            if os.path.exists(sub_video_path):
                obj_id, start_frame, content = self._read_sub_video(sub_video_path)

                if video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_pose':
                    self._compute_mp_pose_data(sub_video_path, obj_id, pose_data_dict, frame_count, start_frame)
                elif video_masking_data['overlayStrategies'][obj_id - 1] == 'mp_face':
                    self._compute_mp_face_data(sub_video_path, obj_id, pose_data_dict, frame_count, start_frame)
                elif video_masking_data['overlayStrategies'][obj_id - 1] == 'openpose':
                    self._compute_openpose_pose_data(content, obj_id, pose_data_dict, frame_count, start_frame)
                else:
                    raise Exception(f'Unknown overlay strategy, got {video_masking_data["overlayStrategies"][obj_id - 1]}')

        return pose_data_dict

    def _compute_openpose_pose_data(self, content, obj_id, pose_data_dict, frame_count, start_frame):
        # Trigger the pose estimation on the sub-video
        pose_data = self._openpose_client.estimate_pose_on_video(content)

        # Ensure pose_data is properly filled or None
        extracted_poses = [
            poses[0] if poses is not None and len(poses) > 0 else None
            for poses in (pose_data or [])
        ]

        # Ensure the list for this obj_id exists in pose_data_dict
        if obj_id not in pose_data_dict:
            pose_data_dict[obj_id] = [None] * frame_count  # Initialize with None

        # Insert the extracted poses into the appropriate place in the list
        for i, pose in enumerate(extracted_poses):
            pose_data_dict[obj_id][start_frame + i] = pose

    def _compute_mp_pose_data(self, sub_video_path, obj_id, pose_data_dict, frame_count, start_frame):
        landmarker = configure_landmarker()
        video_capture = cv2.VideoCapture(sub_video_path)

        if obj_id not in pose_data_dict:
            pose_data_dict[obj_id] = [None] * frame_count

        i = 0
        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = video_capture.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)
            pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            if len(pose_landmarker_result.pose_landmarks) > 0:
                pose = pose_landmarker_result.pose_landmarks[0]
                pose_data_dict[obj_id][start_frame + i] = pose

            i += 1

        video_capture.release()

    def _compute_mp_face_data(self, sub_video_path, obj_id, pose_data_dict, frame_count, start_frame):
        landmarker = configure_face_landmarker()
        video_capture = cv2.VideoCapture(sub_video_path)

        if obj_id not in pose_data_dict:
            pose_data_dict[obj_id] = [None] * frame_count

        i = 0
        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = video_capture.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)
            face_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            if len(face_landmarker_result.face_landmarks) > 0:
                face = face_landmarker_result.face_landmarks[0]
                pose_data_dict[obj_id][start_frame + i] = face

            i += 1

        video_capture.release()

    def _read_sub_video(self, sub_video_path):
        basename = os.path.basename(sub_video_path)
        parts = basename.split('_')
        obj_id = int(parts[1])
        start_frame = int(parts[3].split('.')[0])

        # Read the sub-video content
        with open(sub_video_path, 'rb') as video_file:
            content = video_file.read()
            return obj_id, start_frame, content

    def _streamline_pose_data(self, video_masking_data, pose_data_dict, estimation_input_bounding_boxes, frame_count, sample_rate):
        confidence_threshold = 0.1

        for obj_id, pose_data in pose_data_dict.items():
            overlay_strategy = video_masking_data['overlayStrategies'][obj_id - 1]

            if overlay_strategy == 'openpose':
                for idx in range(frame_count):
                    relevant_start_frame = max(frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx)

                    bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
                    xmin, ymin, xmax, ymax = bbox

                    current_pose = pose_data[idx]

                    adjusted_pose = []
                    for keypoint in current_pose:
                        if keypoint is not None and (keypoint[0] > 0 or keypoint[1] > 0) and keypoint[2] > confidence_threshold:
                            # Translate the keypoint back to the original frame coordinates
                            adjusted_keypoint = (keypoint[0] + xmin, keypoint[1] + ymin)
                            adjusted_pose.append(adjusted_keypoint)
                        else:
                            adjusted_pose.append(None)

                    pose_data_dict[obj_id][idx] = adjusted_pose
            elif overlay_strategy == 'mp_pose':
                for idx in range(frame_count):
                    relevant_start_frame = max(frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx)

                    bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
                    xmin, ymin, xmax, ymax = bbox

                    current_pose = pose_data[idx]

                    adjusted_pose = []
                    for keypoint in current_pose:
                        if keypoint is not None and (keypoint.x > 0 or keypoint.y > 0) and keypoint.visibility > confidence_threshold:
                            # Translate the keypoint back to the original frame coordinates
                            adjusted_keypoint = (keypoint.x * (xmax - xmin) + xmin, keypoint.y * (ymax - ymin) + ymin)
                            adjusted_pose.append(adjusted_keypoint)
                        else:
                            adjusted_pose.append(None)

                    pose_data_dict[obj_id][idx] = adjusted_pose
            elif overlay_strategy == 'mp_face':
                for idx in range(frame_count):
                    relevant_start_frame = max(frame for frame in estimation_input_bounding_boxes[obj_id].keys() if frame <= idx)

                    bbox = estimation_input_bounding_boxes[obj_id][relevant_start_frame]
                    xmin, ymin, xmax, ymax = bbox

                    current_face = pose_data[idx]

                    adjusted_face = []
                    for keypoint in current_face:
                        if keypoint is not None and (keypoint.x > 0 or keypoint.y > 0):
                            # Translate the keypoint back to the original frame coordinates
                            adjusted_keypoint = (keypoint.x * (xmax - xmin) + xmin, keypoint.y * (ymax - ymin) + ymin)
                            adjusted_face.append(adjusted_keypoint)
                        else:
                            adjusted_face.append(None)

                    pose_data_dict[obj_id][idx] = adjusted_face

            if SMOOTHING and (overlay_strategy == 'openpose' or overlay_strategy == 'mp_pose'):
                pose_data_dict[obj_id] = smooth_pose(
                    pose_data_dict[obj_id],
                    sample_rate,
                    10 if overlay_strategy == 'openpose' else 14
                )
