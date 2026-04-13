import json
import os
import re

import cv2
import numpy as np
import requests
from fastapi import APIRouter, Depends, Response, HTTPException
from pydantic import BaseModel

from auth.jwt_bearer import JWTBearer
from config import VIDEOS_BASE_PATH
from ultralytics import YOLO

_UUID_PATTERN = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
    re.IGNORECASE,
)

def validate_resource_id(resource_id: str) -> str:
    if not resource_id or not _UUID_PATTERN.match(resource_id):
        raise HTTPException(status_code=400, detail=f"Invalid resource ID: {resource_id}")
    return resource_id

router = APIRouter(
    prefix="/prompts",
)

pose_model = YOLO('/backend_models/yolo11m-pose.pt')
detection_model = YOLO('/backend_models/yolo11m.pt')


@router.get("/{video_id}/frames/{frame_index}/pose")
def fetch_pose_prompts(video_id: str, frame_index: int, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    capture = cv2.VideoCapture(video_path)
    capture.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
    success, frame = capture.read()
    capture.release()

    if not success or frame is None:
        raise HTTPException(status_code=404, detail="Could not read video frame")

    results = pose_model.predict(
        source=frame,
        device='cpu',
    )

    keypoints = results[0].keypoints
    if keypoints is None or keypoints.conf is None:
        return {'pose_prompts': []}

    poses = keypoints.xy.cpu().numpy().astype(int)
    confs = keypoints.conf.cpu().numpy()

    poses = np.array([[point if conf > 0.8 else (0, 0)
                       for point, conf in zip(kps, confidences)]
                      for kps, confidences in zip(poses, confs)])

    # Remove empty poses (where all points are (0, 0))
    poses = np.array([pose for pose in poses if not np.all(pose == (0, 0))])

    if len(poses) == 0:
        return {'pose_prompts': []}

    pose_prompts = [extract_pose_points(pose, confs[i]) for i, pose in enumerate(poses)]

    # Remove prompts that have only a single point
    pose_prompts = [prompt for prompt in pose_prompts if len(prompt) >= 2]

    return {'pose_prompts': pose_prompts}


class Sam2Params(BaseModel):
    pose_prompts: list[list[list[int]]]
    model_variant: str = "sam2.1_hiera_small"


@router.post("/{video_id}/frames/{frame_index}/sam2")
def segment_frame_with_sam2(sam2_params: Sam2Params, video_id: str, frame_index: int, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    capture = cv2.VideoCapture(video_path)
    capture.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
    success, frame = capture.read()
    capture.release()

    if not success:
        raise HTTPException(status_code=404, detail="Could not read video frame")

    _, buffer = cv2.imencode('.jpg', frame)
    image_data = buffer.tobytes()

    files = {
        'image': ('frame.jpg', image_data, 'image/jpeg'),
    }

    data = {
        'pose_prompts': json.dumps(sam2_params.pose_prompts),
        'model_variant': sam2_params.model_variant,
    }

    response = requests.post(
        'http://sam2:8000/sam2/segment-image',
        files=files,
        data=data,
    )

    response.raise_for_status()
    return Response(content=response.content, media_type="image/jpeg")


@router.get("/{video_id}/frames/{frame_index}/objects")
def fetch_object_prompts(video_id: str, frame_index: int, token_payload: dict = Depends(JWTBearer())):
    validate_resource_id(video_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, f"{video_id}.mp4")
    capture = cv2.VideoCapture(video_path)
    capture.set(cv2.CAP_PROP_POS_FRAMES, frame_index)
    success, frame = capture.read()
    capture.release()

    if not success or frame is None:
        raise HTTPException(status_code=404, detail="Could not read video frame")

    results = detection_model.predict(
        source=frame,
        device='cpu',
    )

    boxes = results[0].boxes
    if boxes is None or len(boxes) == 0:
        return {'object_prompts': []}

    object_prompts: list[list[list[int]]] = []

    for i in range(len(boxes)):
        conf = float(boxes.conf[i].cpu().numpy())
        if conf < 0.5:
            continue

        # Get bounding box center point
        x1, y1, x2, y2 = boxes.xyxy[i].cpu().numpy().astype(int)
        cx = int((x1 + x2) / 2)
        cy = int((y1 + y2) / 2)

        object_prompts.append([[cx, cy, 1]])

    return {'object_prompts': object_prompts}


def is_valid(point):
    return point[0] >= 1 and point[1] >= 1


def average_points(points):
    valid_points = [point for point in points if is_valid(point)]
    if valid_points:
        avg_x = round(sum(point[0] for point in valid_points) / len(valid_points))
        avg_y = round(sum(point[1] for point in valid_points) / len(valid_points))
        return [avg_x, avg_y]
    else:
        return [0, 0]


def extract_pose_points(pose, confs):
    points_0_to_4 = [pose[j] for j in range(5)]
    merged_head_point = average_points(points_0_to_4)

    points_11_and_12 = [pose[j] for j in range(11, 13)]
    merged_lower_body_point = average_points(points_11_and_12)

    new_pose = []

    if is_valid(merged_head_point):
        new_pose.append(merged_head_point + [1])
    if is_valid(merged_lower_body_point):
        new_pose.append(merged_lower_body_point + [1])

    # If we have less than 3 points, add highest-confidence remaining points (excluding merged ones)
    merged_indices = set(range(5)) | set(range(11, 13))
    remaining_points = [(pose[j], confs[j]) for j in range(len(pose)) if j not in merged_indices and is_valid(pose[j])]
    remaining_points.sort(key=lambda x: x[1], reverse=True)

    for point, _ in remaining_points:
        if len(new_pose) >= 3:
            break
        new_pose.append(point.tolist() + [1])

    return new_pose
