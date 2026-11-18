"""
Tests for perform_rtmpose_estimation batching behaviour.

Why we batch:
- MMPoseInferencer supports list input and batches frames internally via a single
  model forward pass (batch_size=N). Calling inferencer(frame) in a Python loop
  means N separate forward passes with full Python overhead between each.
- Passing all frames as a list lets the model process INTERNAL_BATCH_SIZE frames
  per forward pass, significantly reducing overhead on CPU.

Expected gain:
- On a 100-frame sub-video at batch_size=8: ~12 forward passes instead of 100.
- Rough speedup on CPU: 2–4x for pose estimation step depending on model size.

Risk:
- The generator from inferencer(list) must yield exactly len(list) results.
  If it yields fewer, frames are silently dropped. We guard against this with
  a safety pad at the end of perform_rtmpose_estimation, and test it here.
"""

import sys
import os
import numpy as np
import pytest
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))


def _make_prediction(confidence=0.9):
    return {
        'keypoints': [[float(i), float(i)] for i in range(17)],
        'keypoint_scores': [confidence] * 17,
    }


def _make_result(has_detection=True):
    if has_detection:
        return {'predictions': [[_make_prediction()]]}
    return {'predictions': [[]]}


class TestPerformRtmposeEstimation:

    def _run(self, frames, generator_results, model='rtmpose-s_8xb256-420e_coco-256x192'):
        """
        Patch VideoCapture to return `frames`, patch inferencer to yield
        `generator_results`, and run perform_rtmpose_estimation.
        """
        from src.pose_estimation import perform_rtmpose_estimation
        import src.pose_estimation as pe

        mock_cap = MagicMock()
        read_calls = [(True, f) for f in frames] + [(False, None)]
        mock_cap.read.side_effect = read_calls

        mock_inferencer = MagicMock()
        mock_inferencer.return_value = iter(generator_results)

        # Clear cache so our mock is used
        pe._inferencer_cache.clear()

        with patch('cv2.VideoCapture', return_value=mock_cap), \
             patch.object(pe, '_get_inferencer', return_value=mock_inferencer):
            result = perform_rtmpose_estimation('/fake/video.mp4', {'model': model})

        return result, mock_inferencer

    def test_one_result_per_frame(self):
        """Generator yields exactly as many results as there are frames."""
        frames = [np.zeros((64, 64, 3), dtype=np.uint8)] * 5
        generator_results = [_make_result(True)] * 5

        result, _ = self._run(frames, generator_results)
        assert len(result) == 5

    def test_no_detection_yields_none(self):
        frames = [np.zeros((64, 64, 3), dtype=np.uint8)] * 3
        generator_results = [_make_result(False), _make_result(True), _make_result(False)]

        result, _ = self._run(frames, generator_results)
        assert result[0] is None
        assert result[1] is not None
        assert result[2] is None

    def test_keypoints_have_correct_shape(self):
        frames = [np.zeros((64, 64, 3), dtype=np.uint8)]
        generator_results = [_make_result(True)]

        result, _ = self._run(frames, generator_results)
        assert result[0] is not None
        kps = result[0]['pose_keypoints']
        assert len(kps) == 17
        assert len(kps[0]) == 3  # [x, y, confidence]

    def test_all_frames_passed_to_inferencer_as_list(self):
        """All frames must be passed together so MMPose can batch internally."""
        frames = [np.zeros((64, 64, 3), dtype=np.uint8)] * 10
        generator_results = [_make_result(True)] * 10

        _, mock_inferencer = self._run(frames, generator_results)

        call_args = mock_inferencer.call_args
        input_arg = call_args[0][0]
        assert isinstance(input_arg, list), "Frames must be passed as a list, not one at a time"
        assert len(input_arg) == 10

    def test_batch_size_param_passed(self):
        """batch_size kwarg must be forwarded so MMPose uses it internally."""
        frames = [np.zeros((64, 64, 3), dtype=np.uint8)] * 3
        generator_results = [_make_result(True)] * 3

        _, mock_inferencer = self._run(frames, generator_results)

        kwargs = mock_inferencer.call_args[1]
        assert 'batch_size' in kwargs, "batch_size must be passed to inferencer"

    def test_safety_pad_for_short_generator(self):
        """If generator yields fewer results than frames, output is padded with None."""
        frames = [np.zeros((64, 64, 3), dtype=np.uint8)] * 5
        generator_results = [_make_result(True)] * 3  # only 3 of 5

        result, _ = self._run(frames, generator_results)
        assert len(result) == 5
        assert result[3] is None
        assert result[4] is None

    def test_empty_video_returns_empty_list(self):
        frames = []
        generator_results = []

        result, _ = self._run(frames, generator_results)
        assert result == []

    def test_highest_confidence_detection_selected(self):
        """When multiple people are detected, pick the highest mean confidence."""
        low_conf = {
            'keypoints': [[0.0, 0.0]] * 17,
            'keypoint_scores': [0.1] * 17,
        }
        high_conf = {
            'keypoints': [[10.0, 20.0]] * 17,
            'keypoint_scores': [0.95] * 17,
        }
        result_with_two = {'predictions': [[low_conf, high_conf]]}

        frames = [np.zeros((64, 64, 3), dtype=np.uint8)]
        result, _ = self._run(frames, [result_with_two])

        # Should pick high_conf
        assert result[0]['pose_keypoints'][0][0] == pytest.approx(10.0)
