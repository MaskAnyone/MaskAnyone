"""
Tests for Sam2PoseMasker._mask_streaming().

What we're testing and why:
- _mask_streaming is the memory-safe path for chunked jobs. It must:
  * Call SAM2 exactly once per chunk (not accumulate all masks first).
  * Never hold more than one chunk's mask data in RAM simultaneously
    (tested indirectly by verifying disk save/load cycle).
  * Merge pose data from all chunks into a single global accumulator.
  * Hand the boundary mask from chunk N to chunk N+1 as initial_masks.
  * Render every non-overlap frame exactly once to the video writer.
  * Clean up all temp npz files when done.
  * Call the postprocessor once with the full merged pose data.

We mock: _get_video_info, _open_video, _segment_one_chunk,
         _create_sub_videos, _compute_pose_data, _initialize_video_writer,
         _pose_postprocessor, cv2.VideoCapture (for render loop).

We do NOT mock: np.savez_compressed / np.load — the disk round-trip is
part of the contract and we want to verify it works.
"""

import sys
import os
import io
import tempfile
import numpy as np
import pytest
from unittest.mock import MagicMock, patch, call

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from masking.sam2_pose_masker import Sam2PoseMasker


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_masker():
    masker = Sam2PoseMasker.__new__(Sam2PoseMasker)
    masker._sam2_client = MagicMock()
    masker._openpose_client = MagicMock()
    masker._rtmpose_client = MagicMock()
    masker._input_path = '/fake/video.mp4'
    masker._output_path = '/fake/output.mp4'
    masker._sam2_masks_path = '/fake/masks.npz'
    masker._poses_path = tempfile.mktemp(suffix='.json')
    masker._progress_callback = MagicMock()
    masker._media_pipe_landmarker = MagicMock()
    masker._pose_postprocessor = MagicMock()
    return masker


def _make_local_masks(frame_indices, obj_ids=(1,), h=4, w=4):
    """Build {local_frame: {obj_id: np.array(1,H,W,bool)}}."""
    return {
        fi: {oid: np.ones((1, h, w), dtype=bool) for oid in obj_ids}
        for fi in frame_indices
    }


def _make_video_masking_data(n_objects=1):
    return {
        'posePrompts': {0: [[[10, 10, 1]]]},
        'overlayStrategies': ['mp_pose'] * n_objects,
        'hidingStrategies': ['solid_fill'] * n_objects,
        'samModel': 'sam2.1_hiera_small',
    }


def _run_streaming(
    masker,
    total_frames=60,
    fps=25.0,
    chunk_size_frames=40,
    overlap_frames=10,
    n_objects=1,
    local_masks_per_chunk=None,
    pose_per_chunk=None,
):
    """
    Patch heavy dependencies and run _mask_streaming.
    Returns (call_args_to_segment_one_chunk, call_count_video_writer_write).
    """
    vmd = _make_video_masking_data(n_objects)
    stride = chunk_size_frames - overlap_frames
    n_chunks = max(1, (total_frames - overlap_frames + stride - 1) // stride)

    if local_masks_per_chunk is None:
        local_masks_per_chunk = [
            _make_local_masks(range(chunk_size_frames))
            for _ in range(n_chunks)
        ]

    if pose_per_chunk is None:
        pose_per_chunk = [
            {i + 1: [None] * total_frames for i in range(n_objects)}
            for _ in range(n_chunks)
        ]

    segment_calls = []
    chunk_iter = iter(local_masks_per_chunk)
    pose_iter = iter(pose_per_chunk)

    def fake_segment_one_chunk(gs, ge, fps_, pp, mv, im):
        segment_calls.append({'gs': gs, 'ge': ge, 'initial_masks': im})
        return next(chunk_iter)

    fake_frame = np.zeros((4, 4, 3), dtype=np.uint8)
    mock_cap = MagicMock()
    mock_cap.read.return_value = (True, fake_frame)
    mock_writer = MagicMock()

    with patch.object(masker, '_segment_one_chunk', side_effect=fake_segment_one_chunk), \
         patch.object(masker, '_get_video_info', return_value=(total_frames, fps)), \
         patch.object(masker, '_open_video', return_value=(MagicMock(), 4, 4, fps)), \
         patch.object(masker, '_create_sub_videos', return_value=[]), \
         patch.object(masker, '_compute_pose_data', side_effect=lambda vmd, sv, tf: next(pose_iter)), \
         patch.object(masker, '_calculate_full_object_bounding_boxes', return_value={}), \
         patch.object(masker, '_calculate_estimation_input_bounding_boxes', return_value={}), \
         patch.object(masker, '_initialize_video_writer', return_value=mock_writer), \
         patch.object(masker, '_render_all_masks_on_image'), \
         patch('masking.sam2_pose_masker.PoseRenderer'), \
         patch('masking.sam2_pose_masker.MaskRenderer'), \
         patch('cv2.VideoCapture', return_value=mock_cap), \
         patch('cv2.cvtColor', side_effect=lambda img, *_: img):
        masker._mask_streaming(
            video_masking_data=vmd,
            model_variant='sam2.1_hiera_small',
            chunk_size_frames=chunk_size_frames,
            overlap_frames=overlap_frames,
            total_frames=total_frames,
            fps=fps,
            start_time=0.0,
        )

    return segment_calls, mock_writer


# ---------------------------------------------------------------------------
# SAM2 call count and boundary mask handoff
# ---------------------------------------------------------------------------

class TestSam2CallsAndBoundaryHandoff:

    def test_sam2_called_once_per_chunk(self):
        masker = _make_masker()
        # total=60, chunk=40, overlap=10 → stride=30 → 2 chunks
        calls, _ = _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        assert len(calls) == 2

    def test_first_chunk_no_initial_masks(self):
        masker = _make_masker()
        calls, _ = _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        assert calls[0]['initial_masks'] is None

    def test_second_chunk_receives_initial_masks(self):
        masker = _make_masker()
        calls, _ = _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        assert calls[1]['initial_masks'] is not None

    def test_boundary_mask_is_2d_bool(self):
        masker = _make_masker()
        calls, _ = _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        im = calls[1]['initial_masks']
        for obj_id, arr in im.items():
            assert arr.ndim == 2
            assert arr.dtype == bool

    def test_three_chunks_correct_call_count(self):
        masker = _make_masker()
        # total=90, chunk=40, overlap=10, stride=30 → 3 chunks
        calls, _ = _run_streaming(masker, total_frames=90, chunk_size_frames=40, overlap_frames=10,
                                   local_masks_per_chunk=[
                                       _make_local_masks(range(40)),
                                       _make_local_masks(range(40)),
                                       _make_local_masks(range(30)),
                                   ])
        assert len(calls) == 3

    def test_single_chunk_no_initial_masks_ever(self):
        masker = _make_masker()
        # video fits in one chunk
        calls, _ = _run_streaming(masker, total_frames=30, chunk_size_frames=40, overlap_frames=10,
                                   local_masks_per_chunk=[_make_local_masks(range(30))])
        assert len(calls) == 1
        assert calls[0]['initial_masks'] is None


# ---------------------------------------------------------------------------
# Disk round-trip: masks saved and deleted
# ---------------------------------------------------------------------------

class TestDiskRoundTrip:

    def test_no_npz_files_remain_after_streaming(self):
        """All temp mask files must be deleted when streaming completes."""
        masker = _make_masker()
        created_paths = []

        real_savez = np.savez_compressed

        def tracking_savez(path, **kwargs):
            created_paths.append(path)
            real_savez(path, **kwargs)

        with patch('numpy.savez_compressed', side_effect=tracking_savez):
            _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)

        for p in created_paths:
            assert not os.path.exists(p), f"Temp file not cleaned up: {p}"

    def test_masks_written_as_compressed_npz(self):
        """Each chunk must produce one compressed npz save call."""
        masker = _make_masker()
        save_calls = []

        real_savez = np.savez_compressed

        def tracking_savez(path, **kwargs):
            save_calls.append(path)
            real_savez(path, **kwargs)

        with patch('numpy.savez_compressed', side_effect=tracking_savez):
            _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)

        # Two chunks → two save calls
        assert len(save_calls) == 2


# ---------------------------------------------------------------------------
# Pose data accumulation and postprocessor
# ---------------------------------------------------------------------------

class TestPoseAccumulation:

    def test_postprocessor_called_once(self):
        masker = _make_masker()
        _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        masker._pose_postprocessor.postprocess.assert_called_once()

    def test_postprocessor_receives_full_frame_count(self):
        masker = _make_masker()
        _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        args = masker._pose_postprocessor.postprocess.call_args[0]
        # Third positional arg is total_frames
        assert args[2] == 60

    def test_pose_json_written(self):
        masker = _make_masker()
        _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        assert os.path.exists(masker._poses_path)
        os.unlink(masker._poses_path)

    def test_pose_data_from_multiple_chunks_merged(self):
        """Non-None pose values from each chunk should survive in the written JSON.

        We verify the merge logic by inspecting all_pose_data captured in the
        postprocessor call, which receives the fully-merged dict before rendering.
        """
        masker = _make_masker()

        # chunk 0 contributes frame 5, chunk 1 contributes frame 40
        pose_c0 = {1: [None] * 60}
        pose_c0[1][5] = 'frame5_marker'
        pose_c1 = {1: [None] * 60}
        pose_c1[1][40] = 'frame40_marker'

        _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10,
                       pose_per_chunk=[pose_c0, pose_c1])

        # The postprocessor receives the merged dict — inspect its first argument
        merged_pose = masker._pose_postprocessor.postprocess.call_args[0][0]
        assert merged_pose[1][5] == 'frame5_marker'
        assert merged_pose[1][40] == 'frame40_marker'


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

class TestRendering:

    def test_video_writer_write_called_for_each_non_overlap_frame(self):
        """
        total=60, chunk=40, overlap=10:
          chunk 0 keeps [0, 40)  → 40 frames
          chunk 1 keeps [40, 60) → 20 frames
          total rendered = 60
        """
        masker = _make_masker()
        _, writer = _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        assert writer.write.call_count == 60

    def test_writer_released_after_streaming(self):
        masker = _make_masker()
        _, writer = _run_streaming(masker, total_frames=60, chunk_size_frames=40, overlap_frames=10)
        writer.release.assert_called_once()
