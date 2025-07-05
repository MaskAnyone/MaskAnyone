import sys
import os
import numpy as np
from typing import Optional

sys.path.append('/workspace/openpose/build/python')
from openpose import pyopenpose as op

OPENPOSE_MODEL_DIR = os.environ["OPENPOSE_MODEL_DIR"]

_op_wrapper: Optional[op.WrapperPython] = None
_last_op_config: Optional[dict] = None


def _get_config_from_options(options: dict) -> dict:
    config = {
        "model_folder": f"{OPENPOSE_MODEL_DIR}/",
        "number_people_max": 1,
        "render_pose": 0,
        "face": options.get("face", False),
        "hand": options.get("hand", False),
        "model_pose": options.get("model_pose", "BODY_25"),
    }
    return config


def _configs_differ(config1: dict, config2: dict) -> bool:
    return config1 != config2


def perform_openpose_pose_estimation_on_image(image_np: np.ndarray, options: dict):
    global _op_wrapper, _last_op_config

    current_config = _get_config_from_options(options)

    if _op_wrapper is None or _last_op_config is None or _configs_differ(_last_op_config, current_config):
        _op_wrapper = op.WrapperPython()
        _op_wrapper.configure(current_config)
        _op_wrapper.start()
        _last_op_config = current_config

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
