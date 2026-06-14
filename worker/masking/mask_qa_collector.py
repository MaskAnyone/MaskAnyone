"""Per-frame mask QA — runs inside the render loop.

Collects two cheap signals using data we already have on hand for each
rendered frame:

  1. mask_area_px — sum of the rendered mask. A high-confidence pose with a
     ~empty mask suggests segmentation broke for that frame.

  2. uncovered keypoints — high-confidence pose keypoints that fall outside
     the rendered mask polygon. Strong leak signal: we found the person's
     face/limb but didn't cover it.

Per-frame cost is ~one mask.sum() and a handful of array lookups, so it's
negligible against SAM2/pose estimation.
"""

from __future__ import annotations

from typing import Any


KEYPOINT_SCORE_THRESHOLD = 0.5
MIN_MASK_PIXELS = 200


def _extract_keypoints(keypoint_data: Any) -> list:
    """Normalise pose data for one frame into a list of [x, y, score?] entries.

    Handles the three shapes used in this codebase:
      - dict {'pose_keypoints': [[x, y, s], ...]}  (rtmpose / openpose)
      - list [[x, y, s], ...]                      (mediapipe variants)
      - None                                       (no detection)
    """
    if keypoint_data is None:
        return []
    if isinstance(keypoint_data, dict):
        kps = keypoint_data.get('pose_keypoints') or []
        return list(kps)
    if isinstance(keypoint_data, list):
        return keypoint_data
    return []


class MaskQaCollector:
    def __init__(
        self,
        keypoint_score_threshold: float = KEYPOINT_SCORE_THRESHOLD,
        min_mask_pixels: int = MIN_MASK_PIXELS,
    ):
        self._kp_threshold = keypoint_score_threshold
        self._min_mask_pixels = min_mask_pixels
        self._suspect_frames: list[dict] = []
        self._missing_mask_count = 0
        self._uncovered_kp_count = 0
        self._frames_recorded = 0

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
        """
        self._frames_recorded += 1
        t = frame_idx / fps if fps > 0 else 0.0

        for obj_id, keypoint_data in pose_for_frame_per_obj.items():
            kps = _extract_keypoints(keypoint_data)
            high_conf_kps = [
                kp for kp in kps
                if len(kp) >= 3 and kp[2] >= self._kp_threshold and (kp[0] >= 1 or kp[1] >= 1)
            ]
            if not high_conf_kps:
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
            worst_kp = None  # (score, x, y) of the highest-confidence kp outside the mask
            for kp in high_conf_kps:
                x = int(kp[0])
                y = int(kp[1])
                if not (0 <= x < w and 0 <= y < h):
                    continue  # off-frame — not a leak
                if not (mask[y, x] > 0):
                    if worst_kp is None or kp[2] > worst_kp[0]:
                        worst_kp = (float(kp[2]), x, y)

            if worst_kp is not None:
                self._uncovered_kp_count += 1
                self._suspect_frames.append({
                    'idx': int(frame_idx),
                    't': round(t, 3),
                    'reason': 'uncovered_keypoint',
                    'obj_id': int(obj_id),
                    'score': round(worst_kp[0], 3),
                })

    def finalize(self, total_frames: int, fps: float) -> dict:
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
                'keypoint_score_min': self._kp_threshold,
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
