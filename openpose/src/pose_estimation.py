import cv2
import sys

sys.path.append('/workspace/openpose/build/python')
from openpose import pyopenpose as op


def perform_openpose_pose_estimation(input_path: str):
    video_capture = cv2.VideoCapture(input_path)

    op_wrapper = initialize_open_pose()

    idx = 0
    while video_capture.isOpened():
        ret, frame = video_capture.read()

        if not ret:
            break

        datum = op.Datum()
        datum.cvInputData = frame
        op_wrapper.emplaceAndPop(op.VectorDatum([datum]))

        if datum.poseKeypoints is not None and len(datum.poseKeypoints) > 0:
            print(datum.poseKeypoints)
            pass

        idx += 1

    video_capture.release()


def initialize_open_pose():
    params = dict()
    params["model_folder"] = "./docker/openpose/models/"
    # params["model_pose"] = "COCO"
    params["face"] = False
    params["hand"] = False

    op_wrapper = op.WrapperPython()
    op_wrapper.configure(params)
    op_wrapper.start()

    return op_wrapper
