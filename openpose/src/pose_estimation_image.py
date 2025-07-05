import sys
import os
import numpy as np
from typing import Optional

sys.path.append('/workspace/openpose/build/python')
from openpose import pyopenpose as op

OPENPOSE_MODEL_DIR = os.environ["OPENPOSE_MODEL_DIR"]

_op_wrapper: Optional[op.WrapperPython] = None
_op_initialized = False


def perform_openpose_pose_estimation_on_image(image_np: np.ndarray, options: dict):
    global _op_wrapper, _op_initialized

    if not _op_initialized:
        _op_wrapper = op.WrapperPython()
        params = {
            "model_folder": f"{OPENPOSE_MODEL_DIR}/",
            "number_people_max": 1,
            "render_pose": 0,
        }

        if options.get("face"):
            params["face"] = True
        if options.get("hand"):
            params["hand"] = True
        if "model_pose" in options:
            params["model_pose"] = options["model_pose"]

        _op_wrapper.configure(params)
        _op_wrapper.start()
        _op_initialized = True

    datum = op.Datum()
    datum.cvInputData = image_np
    _op_wrapper.emplaceAndPop(op.VectorDatum([datum]))

    if datum.poseKeypoints is not None and len(datum.poseKeypoints) > 0:
        return {
            'pose_keypoints': datum.poseKeypoints[0],
            'face_keypoints': (
                datum.faceKeypoints[0]
                if datum.faceKeypoints is not None and len(datum.faceKeypoints) > 0
                else None
            ),
            'left_hand_keypoints': (
                datum.handKeypoints[0][0]
                if datum.handKeypoints is not None and len(datum.handKeypoints) > 0
                and datum.handKeypoints[0] is not None and len(datum.handKeypoints[0]) > 0
                else None
            ),
            'right_hand_keypoints': (
                datum.handKeypoints[1][0]
                if datum.handKeypoints is not None and len(datum.handKeypoints) > 1
                and datum.handKeypoints[1] is not None and len(datum.handKeypoints[1]) > 0
                else None
            )
        }
    else:
        return None
