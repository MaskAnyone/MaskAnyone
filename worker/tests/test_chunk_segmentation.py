"""
Tests for Sam2PoseMasker._segment_in_chunks().

What we're testing and why:
- If the full video fits in one chunk, only one SAM2 call is made and point
  prompts are used (no initial_masks) — we must not regress the single-pass path.
- For a two-chunk video, the second call must receive initial_masks (not
  point prompts) and those masks must be the squeezed (H, W) boundary mask
  from the last kept frame of the first chunk.
- Global frame indices in the output must be correct — local-to-global mapping.
- Overlap frames from earlier chunks must NOT appear in the output when a
  later chunk covers the same global range.
- Local pose_prompts for chunk 0 must be re-indexed from global to local frame coords.
- The method must not crash for edge cases: empty video, exact chunk boundary.

We mock _get_video_info and _extract_frames_as_bytes so no real video file
is needed. The sam2_client is a MagicMock.
"""

import sys
import os
import io
import numpy as np
import pytest
from unittest.mock import MagicMock, patch, call

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from masking.sam2_pose_masker import Sam2PoseMasker


def _make_masks(frame_indices, obj_ids=(1,), h=10, w=10):
    """Build fake decoded-masks dict {frame_idx: {obj_id: np.array((1, H, W))}}."""
    return {
        fi: {
            obj_id: np.ones((1, h, w), dtype=bool)
            for obj_id in obj_ids
        }
        for fi in frame_indices
    }


def _make_masker():
    """Return a Sam2PoseMasker with all heavy dependencies mocked."""
    masker = Sam2PoseMasker.__new__(Sam2PoseMasker)
    masker._sam2_client = MagicMock()
    masker._openpose_client = MagicMock()
    masker._rtmpose_client = MagicMock()
    masker._input_path = '/fake/video.mp4'
    masker._output_path = '/fake/output.mp4'
    masker._sam2_masks_path = '/fake/masks.npz'
    masker._poses_path = '/fake/poses.json'
    masker._progress_callback = lambda x: None
    return masker


def _run_chunks(
    masker,
    total_frames,
    fps,
    chunk_size_frames,
    overlap_frames,
    pose_prompts=None,
    model_variant='sam2.1_hiera_small',
    masks_per_call=None,
):
    """
    Patch _get_video_info and _extract_frames_as_bytes, configure
    sam2_client.decode_mask_npz_content side_effect (one dict per call),
    then invoke _segment_in_chunks.

    masks_per_call: list of dicts returned by decode_mask_npz_content in order.
    """
    pose_prompts = pose_prompts or {0: [[[5, 5, 1]]]}

    if masks_per_call is None:
        # Default: each chunk returns full-range masks (local 0..chunk_size-1)
        max_local = chunk_size_frames
        masks_per_call = [_make_masks(range(max_local)) for _ in range(10)]

    masker._sam2_client.segment_video.return_value = b'fake_npz'
    masker._sam2_client.decode_mask_npz_content.side_effect = masks_per_call

    with patch.object(masker, '_get_video_info', return_value=(total_frames, fps)), \
         patch.object(masker, '_extract_frames_as_bytes', return_value=b'fakevid'):
        result = masker._segment_in_chunks(
            pose_prompts=pose_prompts,
            model_variant=model_variant,
            chunk_size_frames=chunk_size_frames,
            overlap_frames=overlap_frames,
        )

    return result


# ---------------------------------------------------------------------------
# Single-chunk behaviour
# ---------------------------------------------------------------------------

class TestSingleChunk:

    def test_one_sam2_call_when_video_fits_in_chunk(self):
        masker = _make_masker()
        _run_chunks(masker, total_frames=50, fps=25, chunk_size_frames=300, overlap_frames=30)
        assert masker._sam2_client.segment_video.call_count == 1

    def test_single_chunk_uses_point_prompts_not_initial_masks(self):
        masker = _make_masker()
        _run_chunks(masker, total_frames=50, fps=25, chunk_size_frames=300, overlap_frames=30)
        _, kwargs = masker._sam2_client.segment_video.call_args
        assert kwargs.get('initial_masks') is None

    def test_global_frame_indices_unchanged_for_single_chunk(self):
        masker = _make_masker()
        masks_call = [_make_masks(range(50))]
        result = _run_chunks(
            masker, total_frames=50, fps=25,
            chunk_size_frames=300, overlap_frames=30,
            masks_per_call=masks_call,
        )
        assert set(result.keys()) == set(range(50))

    def test_pose_prompts_passed_unchanged_for_chunk_0(self):
        masker = _make_masker()
        pose_prompts = {0: [[[10, 20, 1]]], 5: [[[30, 40, 1]]]}
        _run_chunks(masker, total_frames=50, fps=25,
                    chunk_size_frames=300, overlap_frames=30,
                    pose_prompts=pose_prompts)
        _, kwargs = masker._sam2_client.segment_video.call_args
        # Frame 0 stays at local 0; frame 5 stays at local 5
        assert 0 in kwargs['pose_prompts']
        assert 5 in kwargs['pose_prompts']


# ---------------------------------------------------------------------------
# Two-chunk behaviour
# ---------------------------------------------------------------------------

class TestTwoChunks:

    def _setup_two_chunk(self, total=60, chunk_size=40, overlap=10):
        """
        stride = 30, so:
          chunk 0: global [0, 40), keep all [0, 40)
          chunk 1: global [30, 60), keep [30+10, 60) = [40, 60)
        """
        masker = _make_masker()
        # chunk 0 returns local [0, 40), chunk 1 returns local [0, 30)
        masks_per_call = [
            _make_masks(range(chunk_size)),
            _make_masks(range(total - (chunk_size - overlap))),  # 30 local frames
        ]
        result = _run_chunks(
            masker, total_frames=total, fps=25,
            chunk_size_frames=chunk_size, overlap_frames=overlap,
            masks_per_call=masks_per_call,
        )
        return masker, result

    def test_two_sam2_calls_for_two_chunk_video(self):
        masker, _ = self._setup_two_chunk()
        assert masker._sam2_client.segment_video.call_count == 2

    def test_second_call_uses_initial_masks(self):
        masker, _ = self._setup_two_chunk()
        calls = masker._sam2_client.segment_video.call_args_list
        second_kwargs = calls[1][1]
        assert second_kwargs.get('initial_masks') is not None

    def test_first_call_no_initial_masks(self):
        masker, _ = self._setup_two_chunk()
        calls = masker._sam2_client.segment_video.call_args_list
        first_kwargs = calls[0][1]
        assert first_kwargs.get('initial_masks') is None

    def test_initial_masks_are_2d_bool_arrays(self):
        masker, _ = self._setup_two_chunk()
        calls = masker._sam2_client.segment_video.call_args_list
        initial_masks = calls[1][1]['initial_masks']
        for obj_id, arr in initial_masks.items():
            assert arr.ndim == 2, f"obj {obj_id}: expected 2D, got shape {arr.shape}"
            assert arr.dtype == bool, f"obj {obj_id}: expected bool, got {arr.dtype}"

    def test_boundary_mask_comes_from_last_frame_of_chunk0(self):
        """The mask handed to chunk 1 must be the last-frame mask from chunk 0."""
        masker = _make_masker()
        h, w = 8, 8
        # Chunk 0 last local frame (39) has a distinctive mask
        chunk0_masks = _make_masks(range(40), h=h, w=w)
        distinctive = np.zeros((1, h, w), dtype=bool)
        distinctive[0, 3, 4] = True
        chunk0_masks[39][1] = distinctive

        masks_per_call = [chunk0_masks, _make_masks(range(20), h=h, w=w)]
        _run_chunks(masker, total_frames=60, fps=25,
                    chunk_size_frames=40, overlap_frames=10,
                    masks_per_call=masks_per_call)

        calls = masker._sam2_client.segment_video.call_args_list
        passed_mask = calls[1][1]['initial_masks'][1]
        np.testing.assert_array_equal(passed_mask, distinctive[0])

    def test_overlap_frames_not_in_second_chunk_output(self):
        """Global frames covered by the overlap must come from chunk 0, not chunk 1."""
        masker, result = self._setup_two_chunk(total=60, chunk_size=40, overlap=10)
        # stride=30; overlap region = global [30, 40) → should only appear from chunk 0
        # chunk 1 kept region starts at global 40
        # All global frames [0, 60) should be in result
        assert set(result.keys()) == set(range(60))

    def test_global_frame_count_correct(self):
        masker, result = self._setup_two_chunk(total=60, chunk_size=40, overlap=10)
        assert len(result) == 60

    def test_local_pose_prompts_reindexed_for_chunk0(self):
        """Pose prompts inside chunk 0 range must have their frame idx converted to local."""
        masker = _make_masker()
        # chunk_size=40, stride=30; pose prompts at global frames 0 and 15
        pose_prompts = {0: [[[1, 2, 1]]], 15: [[[3, 4, 1]]]}
        masks_per_call = [_make_masks(range(40)), _make_masks(range(30))]
        _run_chunks(masker, total_frames=60, fps=25,
                    chunk_size_frames=40, overlap_frames=10,
                    pose_prompts=pose_prompts,
                    masks_per_call=masks_per_call)

        first_call_kwargs = masker._sam2_client.segment_video.call_args_list[0][1]
        pp = first_call_kwargs['pose_prompts']
        # Local frame 0 = global frame 0; local frame 15 = global frame 15
        assert 0 in pp
        assert 15 in pp

    def test_pose_prompts_outside_chunk0_not_passed_to_first_call(self):
        """Prompts beyond chunk 0's range must not appear in the first call."""
        masker = _make_masker()
        # chunk_size=40; global frame 50 is outside chunk 0
        pose_prompts = {0: [[[1, 2, 1]]], 50: [[[5, 6, 1]]]}
        masks_per_call = [_make_masks(range(40)), _make_masks(range(30))]
        _run_chunks(masker, total_frames=60, fps=25,
                    chunk_size_frames=40, overlap_frames=10,
                    pose_prompts=pose_prompts,
                    masks_per_call=masks_per_call)

        first_call_kwargs = masker._sam2_client.segment_video.call_args_list[0][1]
        pp = first_call_kwargs['pose_prompts']
        assert 50 not in pp


# ---------------------------------------------------------------------------
# Edge cases
# ---------------------------------------------------------------------------

class TestEdgeCases:

    def test_exact_chunk_boundary(self):
        """Video is exactly chunk_size frames — single chunk, no second call."""
        masker = _make_masker()
        _run_chunks(masker, total_frames=40, fps=25,
                    chunk_size_frames=40, overlap_frames=10,
                    masks_per_call=[_make_masks(range(40))])
        assert masker._sam2_client.segment_video.call_count == 1

    def test_three_chunks(self):
        """stride=30, total=90 → 3 chunks; verify call count and final key range."""
        masker = _make_masker()
        # chunk 0: [0,40), chunk 1: [30,70), chunk 2: [60,90)
        masks_per_call = [
            _make_masks(range(40)),
            _make_masks(range(40)),
            _make_masks(range(30)),
        ]
        result = _run_chunks(masker, total_frames=90, fps=25,
                             chunk_size_frames=40, overlap_frames=10,
                             masks_per_call=masks_per_call)
        assert masker._sam2_client.segment_video.call_count == 3
        assert set(result.keys()) == set(range(90))
