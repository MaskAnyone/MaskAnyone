"""Per-frame mask QA — runs inside the render loop.

Collects two cheap signals using data we already have on hand for each
rendered frame:

  1. mask_area_px — sum of the rendered mask. A confident pose with a
     ~empty mask suggests segmentation broke for that frame.

  2. uncovered keypoints — confident pose keypoints that fall outside
     the rendered mask polygon. Strong leak signal: we found the person's
     face/limb but didn't cover it.

Per-frame cost is ~one mask.sum() and a handful of array lookups, so it's
negligible against SAM2/pose estimation.
"""

from __future__ import annotations

from typing import Any


MIN_MASK_PIXELS = 200

# Keypoint groups in dict-shaped pose data. The QA checks every group present.
#
# What each overlay strategy actually fills (see
# Sam2PoseMasker._compute_openpose_pose_data, which builds the OpenPose options):
#
#   strategy            OpenPose options               pose_keypoints     face_keypoints  hands
#   ------------------  -----------------------------  -----------------  --------------  -----
#   openpose            BODY_25,  face=False           25 body            None            None
#   openpose_body25b    BODY_25B, face=False           25 body            None            None
#   openpose_face       BODY_25,  face=True            25 body            70 face         None
#   openpose_body_135   BODY_135, face=False           135: body 0-24,    None            None
#                                                      hands 25-64,
#                                                      face 65-134
#   rtmpose_*           (RTMPose service)              17 body (COCO) or  —               —
#                                                      animal keypoints
#
# Notes:
# - BODY_135 is a single model whose 135 points already include hands and face,
#   all inside pose_keypoints. That is why the QA covers BODY_135 hands/face
#   even though its separate face/hand groups are None.
# - The separate OpenPose hand detector (left/right_hand_keypoints) is never
#   enabled: hand=False for every strategy. Both groups are listed anyway so
#   the QA covers them if a hand option is added later.
# - Groups that are None (not requested or not detected) are skipped.
# - MediaPipe strategies (mp_pose, mp_face, mp_hand) produce plain lists, not
#   dicts, and are handled separately in _extract_keypoints.
KEYPOINT_GROUPS = ('pose_keypoints', 'face_keypoints', 'left_hand_keypoints', 'right_hand_keypoints')


def _extract_keypoints(keypoint_data: Any) -> list:
    """Normalise postprocessed pose data for one frame into a list of keypoints.

    Each keypoint is (x, y) or None (dropped by PosePostprocessor as low-confidence).
    Handles the three shapes used in this codebase:
      - dict {'pose_keypoints': [...], 'face_keypoints': [...] | None, ...}
                                                   (rtmpose / openpose)
      - list [(x, y) | None, ...]                  (mediapipe variants)
      - None                                       (no detection)

    For dicts, every keypoint group is included, not just the body: an
    uncovered face point (openpose_face) is the most important leak to catch.
    Groups that are None (not requested / not detected) are skipped.
    """
    if keypoint_data is None:
        return []
    if isinstance(keypoint_data, dict):
        kps = []
        for group in KEYPOINT_GROUPS:
            kps.extend(keypoint_data.get(group) or [])
        return kps
    if isinstance(keypoint_data, list):
        return keypoint_data
    return []


class MaskQaCollector:
    def __init__(
        self,
        min_mask_pixels: int = MIN_MASK_PIXELS,
    ):
        self._min_mask_pixels = min_mask_pixels
        self._suspect_frames: list[dict] = []
        self._missing_mask_count = 0
        self._uncovered_kp_count = 0
        self._frames_recorded = 0
        self._failed = False

    def record_frame(
        self,
        frame_idx: int,
        masks_for_frame: dict | None,
        pose_for_frame_per_obj: dict,
        fps: float,
    ) -> None:
        """Inspect one rendered frame.

        masks_for_frame: {obj_id: np.array(1, H, W)} or None when SAM2 has no mask
                         for this frame (renderer treats this as "no mask drawn").
        pose_for_frame_per_obj: {obj_id: keypoint_data}  per object for this frame.

        QA is advisory and must never fail the masking job. If inspecting a frame
        raises, the collector logs it once and disables itself; finalize() then
        returns None so no (partial, possibly falsely green) report is written.
        """
        if self._failed:
            return
        try:
            self._record_frame(frame_idx, masks_for_frame, pose_for_frame_per_obj, fps)
        except Exception as e:
            self._failed = True
            print(f"[qa] disabled after error on frame {frame_idx}: {e!r}", flush=True)

    def _record_frame(
        self,
        frame_idx: int,
        masks_for_frame: dict | None,
        pose_for_frame_per_obj: dict,
        fps: float,
    ) -> None:
        self._frames_recorded += 1
        t = frame_idx / fps if fps > 0 else 0.0

        for obj_id, keypoint_data in pose_for_frame_per_obj.items():
            kps = _extract_keypoints(keypoint_data)
            # PosePostprocessor is the single stage that applies keypoint
            # confidence (KEYPOINT_CONFIDENCE_THRESHOLDS): dropped keypoints are
            # None and survivors are bare (x, y) with no score. Anything left is
            # treated as confident — no second threshold here.
            confident_kps = [
                kp for kp in kps
                if kp is not None and len(kp) >= 2
                and kp[0] is not None and kp[1] is not None
                and (kp[0] >= 1 or kp[1] >= 1)
            ]
            if not confident_kps:
                continue  # nothing to verify against — skip

            mask = None
            if masks_for_frame is not None and obj_id in masks_for_frame:
                mask = masks_for_frame[obj_id][0]  # (H, W)

            if mask is None or int((mask > 0).sum()) < self._min_mask_pixels:
                self._missing_mask_count += 1
                self._suspect_frames.append({
                    'idx': int(frame_idx),
                    't': round(t, 3),
                    'reason': 'missing_mask',
                    'obj_id': int(obj_id),
                    'score': None,
                })
                continue

            h, w = mask.shape[:2]
            has_uncovered = False
            for kp in confident_kps:
                x = int(kp[0])
                y = int(kp[1])
                if not (0 <= x < w and 0 <= y < h):
                    continue  # off-frame — not a leak
                if not (mask[y, x] > 0):
                    has_uncovered = True
                    break

            if has_uncovered:
                self._uncovered_kp_count += 1
                self._suspect_frames.append({
                    'idx': int(frame_idx),
                    't': round(t, 3),
                    'reason': 'uncovered_keypoint',
                    'obj_id': int(obj_id),
                    'score': None,  # postprocessed keypoints carry no score
                })

    def finalize(self, total_frames: int, fps: float) -> dict | None:
        """Build the QA report, or None if the collector failed mid-run."""
        if self._failed:
            return None

        clean = max(0, self._frames_recorded - len(self._suspect_frames))
        coverage = (clean / self._frames_recorded * 100.0) if self._frames_recorded else 100.0

        if self._uncovered_kp_count > 0:
            verdict = 'red'
        elif self._missing_mask_count > 0:
            verdict = 'amber'
        else:
            verdict = 'green'

        return {
            'frame_count': int(total_frames),
            'frames_recorded': int(self._frames_recorded),
            'fps': float(fps) if fps else 0.0,
            'thresholds': {
                'min_mask_pixels': self._min_mask_pixels,
            },
            'summary': {
                'coverage_pct': round(coverage, 2),
                'suspect_frame_count': len(self._suspect_frames),
                'missing_mask_frames': self._missing_mask_count,
                'uncovered_keypoint_frames': self._uncovered_kp_count,
                'verdict': verdict,
            },
            'frames': self._suspect_frames,
        }
