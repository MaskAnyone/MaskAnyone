import cv2
import os

from fastapi import APIRouter, Request, Depends
from auth.jwt_bearer import JWTBearer
from ultralytics import YOLO
from config import VIDEOS_BASE_PATH


router = APIRouter(
    prefix="/prompts",
)

model = YOLO('./models/yolov8m-pose.pt')

@router.get("/{video_id}/pose")
def fetch_pose_prompts(video_id: str, token_payload: dict = Depends(JWTBearer())):
    user_id = token_payload["sub"]

    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
    capture = cv2.VideoCapture(video_path)
    success, frame = capture.read()
    capture.release()

    results = model.predict(
        source=frame,
        device='cpu',
    )

    poses = results[0].keypoints.xy.cpu().numpy().astype(int)
    pose_prompts = [extract_pose_points(pose) for pose in poses]
    print(pose_prompts)

    return {'pose_prompts': pose_prompts}



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


def extract_pose_points(pose):
    # Collect valid points from indices 0 to 4
    points_0_to_4 = [pose[j] for j in range(5)]
    avg_point_0_to_4 = average_points(points_0_to_4)

    # Collect valid points from indices 5 and 6
    points_5_and_6 = [pose[j] for j in range(5, 7)]
    avg_point_5_and_6 = average_points(points_5_and_6)

    # Collect valid points from indices 11 and 12
    points_11_and_12 = [pose[j] for j in range(11, 13)]
    avg_point_11_and_12 = average_points(points_11_and_12)

    # Create a new list of points
    new_pose = []

    # Add the averaged points to the new list if they are valid
    if is_valid(avg_point_0_to_4):
        new_pose.append(avg_point_0_to_4 + [1])
    if is_valid(avg_point_5_and_6):
        new_pose.append(avg_point_5_and_6 + [1])
    if is_valid(avg_point_11_and_12):
        new_pose.append(avg_point_11_and_12 + [1])

    # Add other points (indices 7 to 10 and 13 to end) if they are valid
    for j in range(7, 11):
        if is_valid(pose[j]):
            new_pose.append(pose[j].tolist() + [1])
    for j in range(13, len(pose)):
        if is_valid(pose[j]):
            new_pose.append(pose[j].tolist() + [1])

    return new_pose
