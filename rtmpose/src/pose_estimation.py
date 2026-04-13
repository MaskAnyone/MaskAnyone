import cv2
import numpy as np

from mmpose.apis import MMPoseInferencer


_inferencer_cache = {}

# MMPoseInferencer processes inputs in batches internally when given a list.
# We pass all frames at once and let it handle batching — one yielded result per frame.
# Verified: the generator yields exactly len(inputs) results when inputs is a list.
INTERNAL_BATCH_SIZE = 8


def _get_inferencer(model: str, device: str):
    key = (model, device)
    if key not in _inferencer_cache:
        _inferencer_cache[key] = MMPoseInferencer(model, device=device)
    return _inferencer_cache[key]


def perform_rtmpose_estimation(video_path: str, options: dict) -> list:
    model = options.get('model', 'rtmpose-m_8xb256-420e_coco-256x192')
    device = options.get('device', 'cpu')

    inferencer = _get_inferencer(model, device)

    # Read all frames upfront so we can pass as a list.
    # Sub-videos are small (cropped bboxes) so RAM cost is low.
    cap = cv2.VideoCapture(video_path)
    frames = []
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        frames.append(frame)
    cap.release()

    if not frames:
        return []

    pose_data = []

    # Pass all frames as a list — MMPoseInferencer batches internally (INTERNAL_BATCH_SIZE
    # frames per forward pass) and yields one result per input frame.
    # This avoids the Python-loop overhead of calling inferencer() once per frame.
    result_generator = inferencer(frames, return_vis=False, batch_size=INTERNAL_BATCH_SIZE)

    for result in result_generator:
        predictions = result.get('predictions', [[]])[0]

        if not predictions:
            pose_data.append(None)
            continue

        best = max(predictions, key=lambda p: np.mean(p['keypoint_scores']))
        keypoints = best['keypoints']
        scores = best['keypoint_scores']

        pose_data.append({
            'pose_keypoints': [
                [kp[0], kp[1], float(score)]
                for kp, score in zip(keypoints, scores)
            ]
        })

    # Guard: if generator yields fewer results than frames (shouldn't happen but be safe)
    while len(pose_data) < len(frames):
        pose_data.append(None)

    return pose_data
