import cv2
import sys

sys.path.append('/workspace/openpose/build/python')
from openpose import pyopenpose as op


def perform_openpose_pose_estimation(input_path: str, options: dict):
    video_capture = cv2.VideoCapture(input_path)
    pose_data = []

    op_wrapper = initialize_open_pose(options)

    idx = 0
    while video_capture.isOpened():
        ret, frame = video_capture.read()

        if not ret:
            break

        datum = op.Datum()
        datum.cvInputData = frame
        op_wrapper.emplaceAndPop(op.VectorDatum([datum]))

        if datum.poseKeypoints is not None and len(datum.poseKeypoints) > 0:
            pose_data.append({
                'pose_keypoints': datum.poseKeypoints[0],
                'face_keypoints': datum.faceKeypoints[0] if datum.faceKeypoints is not None and len(datum.faceKeypoints) > 0 else None,
                'left_hand_keypoints': datum.handKeypoints[0][0] if datum.handKeypoints is not None and len(datum.handKeypoints) > 0 else None,
                'right_hand_keypoints': datum.handKeypoints[1][0] if datum.handKeypoints is not None and len(datum.handKeypoints) > 1 else None,
            })
        else:
            pose_data.append(None)

        idx += 1

    video_capture.release()
    return pose_data


def initialize_open_pose(options: dict):
    params = dict()
    params["model_folder"] = "/models/"
    params["number_people_max"] = 1

    # params["model_pose"] = "COCO"
    # params["net_resolution"] = "-1x512"
    #params["net_resolution"] = "-1x480"
    #params["hand_scale_number"] = 6
    #params["hand_detector"] = 3

    if 'face' in options:
        params["face"] = bool(options['face'])

    if 'hand' in options:
        params["hand"] = bool(options['hand'])

    op_wrapper = op.WrapperPython()
    op_wrapper.configure(params)
    op_wrapper.start()

    return op_wrapper
