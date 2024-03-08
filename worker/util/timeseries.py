import json
import dataclasses
from typing import Literal

markersbody = [
    "NOSE",
    "LEFT_EYE_INNER",
    "LEFT_EYE",
    "LEFT_EYE_OUTER",
    "RIGHT_EYE_INNER",
    "RIGHT_EYE",
    "RIGHT_EYE_OUTER",
    "LEFT_EAR",
    "RIGHT_EAR",
    "MOUTH_LEFT",
    "MOUTH_RIGHT",
    "LEFT_SHOULDER",
    "RIGHT_SHOULDER",
    "LEFT_ELBOW",
    "RIGHT_ELBOW",
    "LEFT_WRIST",
    "RIGHT_WRIST",
    "LEFT_PINKY",
    "RIGHT_PINKY",
    "LEFT_INDEX",
    "RIGHT_INDEX",
    "LEFT_THUMB",
    "RIGHT_THUMB",
    "LEFT_HIP",
    "RIGHT_HIP",
    "LEFT_KNEE",
    "RIGHT_KNEE",
    "LEFT_ANKLE",
    "RIGHT_ANKLE",
    "LEFT_HEEL",
    "RIGHT_HEEL",
    "LEFT_FOOT_INDEX",
    "RIGHT_FOOT_INDEX",
    "LEFT_WRIST",
    "LEFT_THUMB_CMC",
    "LEFT_THUMB_MCP",
    "LEFT_THUMB_IP",
    "LEFT_THUMB_TIP",
    "LEFT_INDEX_FINGER_MCP",
    "LEFT_INDEX_FINGER_PIP",
    "LEFT_INDEX_FINGER_DIP",
    "LEFT_INDEX_FINGER_TIP",
    "LEFT_MIDDLE_FINGER_MCP",
    "LEFT_MIDDLE_FINGER_PIP",
    "LEFT_MIDDLE_FINGER_DIP",
    "LEFT_MIDDLE_FINGER_TIP",
    "LEFT_RING_FINGER_MCP",
    "LEFT_RING_FINGER_PIP",
    "LEFT_RING_FINGER_DIP",
    "LEFT_RING_FINGER_TIP",
    "LEFT_PINKY_FINGER_MCP",
    "LEFT_PINKY_FINGER_PIP",
    "LEFT_PINKY_FINGER_DIP",
    "LEFT_PINKY_FINGER_TIP",
    "RIGHT_WRIST",
    "RIGHT_THUMB_CMC",
    "RIGHT_THUMB_MCP",
    "RIGHT_THUMB_IP",
    "RIGHT_THUMB_TIP",
    "RIGHT_INDEX_FINGER_MCP",
    "RIGHT_INDEX_FINGER_PIP",
    "RIGHT_INDEX_FINGER_DIP",
    "RIGHT_INDEX_FINGER_TIP",
    "RIGHT_MIDDLE_FINGER_MCP",
    "RIGHT_MIDDLE_FINGER_PIP",
    "RIGHT_MIDDLE_FINGER_DIP",
    "RIGHT_MIDDLE_FINGER_TIP",
    "RIGHT_RING_FINGER_MCP",
    "RIGHT_RING_FINGER_PIP",
    "RIGHT_RING_FINGER_DIP",
    "RIGHT_RING_FINGER_TIP",
    "RIGHT_PINKY_FINGER_MCP",
    "RIGHT_PINKY_FINGER_PIP",
    "RIGHT_PINKY_FINGER_DIP",
    "RIGHT_PINKY_FINGER_TIP",
]

facemarks = [
    str(x) for x in range(478)
]  # there are 478 points for the face mesh (see google holistic face mesh info for landmarks)

# set up the column names and objects for the time series data (add time as the first variable)
markerxyzbody = ["time"]
markerxyzface = ["time"]

for mark in markersbody:
    for pos in ["X", "Y", "Z", "visibility", "presence"]:
        nm = pos + "_" + mark
        markerxyzbody.append(nm)
for mark in facemarks:
    for pos in ["X", "Y", "Z"]:
        nm = pos + "_" + mark
        markerxyzface.append(nm)


def create_header_mp(part_name: Literal["body", "face"]):
    # creates a header for timeseris output csv from mediapipe
    if part_name == "body":
        return markerxyzbody
    elif part_name == "face":
        return markerxyzface
    else:
        raise Exception("Invalid part name specified for ts header creation")

def create_landmark_object(mp_landmark):
    lm = {"x": mp_landmark.x, "y": mp_landmark.y, "z": mp_landmark.z}

    if hasattr(mp_landmark, "visibility"):
        lm["visibility"] = mp_landmark.visibility
    if hasattr(mp_landmark, "presence"):
        lm["presence"] = mp_landmark.presence

    return lm


def list_positions_mp_body(
    pose_landmark_data, timestamp_ms: int
):
    landmarks = {}
    world_landmarks = {}

    for result in pose_landmark_data.pose_landmarks:
        landmarks["time"] = timestamp_ms

        for i, landmark in enumerate(result):
            landmarks[markersbody[i]] = create_landmark_object(landmark)

    for result in pose_landmark_data.pose_world_landmarks:
        world_landmarks["time"] = timestamp_ms

        for i, landmark in enumerate(result):
            world_landmarks[markersbody[i]] = create_landmark_object(landmark)

    return {
        'landmarks': landmarks,
        'world_landmarks': world_landmarks,
    }


def list_positions_mp_face(
    landmark_results, timestamp_ms: int
):
    output_obj = {}

    for result in landmark_results:
        output_obj["time"] = timestamp_ms

        for i, landmark in enumerate(result):
            output_obj[facemarks[i]] = create_landmark_object(landmark)

    return output_obj


def serialize_pose_landmarker_result(pose_landmarker_result, timestamp_ms: int):
# Convert each NormalizedLandmark object to a dict and maintain the list of lists structure
    serialized_landmarks = [[dataclasses.asdict(landmark) for landmark in inner_list] for inner_list in pose_landmarker_result.pose_landmarks]
    serialized_world_landmarks = [[dataclasses.asdict(landmark) for landmark in inner_list] for inner_list in pose_landmarker_result.pose_world_landmarks]

    return {
        "data": {
            "landmarks": serialized_landmarks,
            "world_landmarks": serialized_world_landmarks,
        },
        "timestamp": timestamp_ms,
    }
