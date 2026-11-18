"""
Tests for the sub-video creation and pose data dispatch pipeline.

What we're testing and why:
- _create_sub_videos now returns (obj_id, start_frame, path, content) tuples instead of
  just paths. The content bytes are read once from disk immediately after writing, so
  RTMPose/OpenPose callers never touch the disk again for that sub-video.
- _compute_pose_data unpacks those tuples and dispatches to the right strategy.
- MediaPipe gets the path (it requires a file path), everyone else gets content bytes.

Expected gains from the disk roundtrip removal:
- Eliminates one file read per sub-video per job. For a job with 2 tracked objects
  this is 2 saved reads. Low absolute time (~ms each) but removes unnecessary I/O
  contention and simplifies the data flow.
"""

import os
import sys
import tempfile
import numpy as np
import pytest
from unittest.mock import MagicMock, patch, call

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_masker(overlay_strategies=None):
    """Build a Sam2PoseMasker with all external dependencies mocked out."""
    from masking.sam2_pose_masker import Sam2PoseMasker

    masker = Sam2PoseMasker.__new__(Sam2PoseMasker)
    masker._sam2_client = MagicMock()
    masker._openpose_client = MagicMock()
    masker._rtmpose_client = MagicMock()
    masker._media_pipe_landmarker = MagicMock()
    masker._pose_postprocessor = MagicMock()
    masker._progress_callback = MagicMock()
    masker._video_path = '/fake/video.mp4'
    masker._sam2_masks_path = '/fake/masks.npz'
    masker._confidence = 0.3
    return masker


def _make_sub_videos(*strategies):
    """Return a list of fake (obj_id, start_frame, path, content) tuples."""
    return [
        (i + 1, 0, f'/fake/object_{i+1}_frame_0.mp4', b'fakevideocontent')
        for i in range(len(strategies))
    ]


# ---------------------------------------------------------------------------
# _compute_pose_data dispatch
# ---------------------------------------------------------------------------

class TestComputePoseDataDispatch:
    """Verify that each overlay strategy routes to the right method."""

    def test_none_strategy_fills_nones(self):
        masker = _make_masker()
        sub_videos = _make_sub_videos('none')
        result = masker._compute_pose_data(
            {'overlayStrategies': ['none']},
            sub_videos,
            frame_count=10
        )
        assert result[1] == [None] * 10

    def test_rtmpose_receives_content_bytes_not_path(self):
        masker = _make_masker()
        masker._rtmpose_client.estimate_pose_on_video.return_value = [None] * 5
        sub_videos = [(1, 0, '/fake/object_1_frame_0.mp4', b'videobytes')]

        masker._compute_pose_data(
            {'overlayStrategies': ['rtmpose_s']},
            sub_videos,
            frame_count=5
        )

        # Must be called with bytes, not a file path
        args = masker._rtmpose_client.estimate_pose_on_video.call_args
        assert args[0][0] == b'videobytes', "RTMPose must receive content bytes, not a path"

    def test_openpose_receives_content_bytes_not_path(self):
        masker = _make_masker()
        masker._openpose_client.estimate_pose_on_video.return_value = [None] * 5
        sub_videos = [(1, 0, '/fake/object_1_frame_0.mp4', b'videobytes')]

        masker._compute_pose_data(
            {'overlayStrategies': ['openpose_body25']},
            sub_videos,
            frame_count=5
        )

        args = masker._openpose_client.estimate_pose_on_video.call_args
        assert args[0][0] == b'videobytes', "OpenPose must receive content bytes, not a path"

    def test_mediapipe_receives_path_not_bytes(self):
        masker = _make_masker()
        masker._media_pipe_landmarker.compute_pose_data.return_value = [None] * 5
        sub_videos = [(1, 0, '/fake/object_1_frame_0.mp4', b'videobytes')]

        masker._compute_pose_data(
            {'overlayStrategies': ['mp_pose']},
            sub_videos,
            frame_count=5
        )

        args = masker._media_pipe_landmarker.compute_pose_data.call_args
        assert args[0][0] == '/fake/object_1_frame_0.mp4', "MediaPipe must receive a file path"

    def test_unknown_strategy_raises(self):
        masker = _make_masker()
        sub_videos = _make_sub_videos('unknown_strategy')
        with pytest.raises(Exception, match='Unknown overlay strategy'):
            masker._compute_pose_data(
                {'overlayStrategies': ['unknown_strategy']},
                sub_videos,
                frame_count=5
            )

    def test_pose_data_placed_at_correct_start_frame(self):
        """Data from a sub-video starting at frame 10 must land at index 10, not 0."""
        masker = _make_masker()
        frame_pose = {'pose_keypoints': [[0, 0, 1.0]] * 17}
        masker._rtmpose_client.estimate_pose_on_video.return_value = [frame_pose] * 3
        sub_videos = [(1, 10, '/fake/object_1_frame_10.mp4', b'bytes')]

        result = masker._compute_pose_data(
            {'overlayStrategies': ['rtmpose_s']},
            sub_videos,
            frame_count=20
        )

        assert result[1][0] is None       # before start_frame
        assert result[1][10] == frame_pose  # at start_frame
        assert result[1][12] == frame_pose  # start_frame + 2
        assert result[1][13] is None      # after data ends

    def test_mp_face_receives_path(self):
        masker = _make_masker()
        masker._media_pipe_landmarker.compute_face_data.return_value = [None] * 5
        sub_videos = [(1, 0, '/fake/object_1_frame_0.mp4', b'bytes')]
        masker._compute_pose_data({'overlayStrategies': ['mp_face']}, sub_videos, 5)
        args = masker._media_pipe_landmarker.compute_face_data.call_args
        assert args[0][0] == '/fake/object_1_frame_0.mp4'

    def test_mp_hand_receives_path(self):
        masker = _make_masker()
        masker._media_pipe_landmarker.compute_hand_data.return_value = [None] * 5
        sub_videos = [(1, 0, '/fake/object_1_frame_0.mp4', b'bytes')]
        masker._compute_pose_data({'overlayStrategies': ['mp_hand']}, sub_videos, 5)
        args = masker._media_pipe_landmarker.compute_hand_data.call_args
        assert args[0][0] == '/fake/object_1_frame_0.mp4'

    def test_openpose_body25b_receives_bytes(self):
        masker = _make_masker()
        masker._openpose_client.estimate_pose_on_video.return_value = [None] * 5
        sub_videos = [(1, 0, '/fake/object_1_frame_0.mp4', b'opbytes')]
        masker._compute_pose_data({'overlayStrategies': ['openpose_body25b']}, sub_videos, 5)
        args = masker._openpose_client.estimate_pose_on_video.call_args
        assert args[0][0] == b'opbytes'

    def test_rtmpose_variants_all_dispatch_correctly(self):
        for variant in ['rtmpose_s', 'rtmpose_m', 'rtmpose_l']:
            masker = _make_masker()
            masker._rtmpose_client.estimate_pose_on_video.return_value = [None] * 3
            sub_videos = [(1, 0, '/fake/path.mp4', b'bytes')]
            masker._compute_pose_data({'overlayStrategies': [variant]}, sub_videos, 3)
            assert masker._rtmpose_client.estimate_pose_on_video.called, f"{variant} did not call rtmpose client"

    def test_two_objects_dispatched_independently(self):
        masker = _make_masker()
        masker._rtmpose_client.estimate_pose_on_video.return_value = [None] * 5
        masker._media_pipe_landmarker.compute_pose_data.return_value = [None] * 5

        sub_videos = [
            (1, 0, '/fake/object_1_frame_0.mp4', b'bytes1'),
            (2, 0, '/fake/object_2_frame_0.mp4', b'bytes2'),
        ]

        masker._compute_pose_data(
            {'overlayStrategies': ['rtmpose_s', 'mp_pose']},
            sub_videos,
            frame_count=5
        )

        assert masker._rtmpose_client.estimate_pose_on_video.call_count == 1
        assert masker._media_pipe_landmarker.compute_pose_data.call_count == 1


# ---------------------------------------------------------------------------
# _create_sub_videos return format
# ---------------------------------------------------------------------------

class TestCreateSubVideosReturnFormat:
    """Verify the tuple format and that content bytes match what was written."""

    def test_returns_tuples_with_four_elements(self, tmp_path):
        masker = _make_masker()

        # Minimal single-object, single-frame setup
        cap = MagicMock()
        cap.get.side_effect = lambda prop: 30.0 if prop == 5 else 1  # FPS=30, FRAME_COUNT=1
        cap.read.side_effect = [(True, np.zeros((100, 100, 3), dtype=np.uint8)), (False, None)]

        masks = {0: {1: {0: np.ones((100, 100), dtype=bool)}}}
        estimation_input_bboxes = {1: {0: (10, 10, 90, 90)}}

        masker._prepare_estimation_input_frame = MagicMock(
            return_value=np.zeros((80, 80, 3), dtype=np.uint8)
        )

        result = masker._create_sub_videos(cap, estimation_input_bboxes, masks, str(tmp_path))

        assert len(result) == 1
        obj_id, start_frame, path, content = result[0]
        assert obj_id == 1
        assert start_frame == 0
        assert os.path.exists(path), "File must still exist on disk (MediaPipe needs it)"
        assert isinstance(content, bytes) and len(content) > 0, "Content must be non-empty bytes"

    def test_content_matches_file_on_disk(self, tmp_path):
        masker = _make_masker()

        cap = MagicMock()
        cap.get.side_effect = lambda prop: 30.0 if prop == 5 else 1
        cap.read.side_effect = [(True, np.zeros((100, 100, 3), dtype=np.uint8)), (False, None)]

        masks = {0: {1: {0: np.ones((100, 100), dtype=bool)}}}
        estimation_input_bboxes = {1: {0: (10, 10, 90, 90)}}
        masker._prepare_estimation_input_frame = MagicMock(
            return_value=np.zeros((80, 80, 3), dtype=np.uint8)
        )

        result = masker._create_sub_videos(cap, estimation_input_bboxes, masks, str(tmp_path))
        _, _, path, content = result[0]

        with open(path, 'rb') as f:
            disk_content = f.read()

        assert content == disk_content, "In-memory bytes must match what is on disk"
