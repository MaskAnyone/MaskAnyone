"""
Tests for Sam2Client.segment_video — specifically the new initial_masks
(mask prompt) code path.

What we're testing and why:
- Without initial_masks: request files must NOT contain an 'initial_masks' field
  (no regression on the existing point-prompt path).
- With initial_masks: the npz payload must be included and must round-trip
  correctly — the server decodes the same data that was encoded here.
- The npz keys must be string obj_ids so np.load() can read them back as
  {str: array}; the server then calls int(key) to recover the integer id.
- decode_mask_npz_content must correctly unpack the flat frame_mask key format.

We mock requests.post entirely — we are NOT testing HTTP transport here.
"""

import sys
import os
import io
import numpy as np
import pytest
from unittest.mock import MagicMock, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from communication.sam2_client import Sam2Client


def _make_mock_response(content=b"fake_npz"):
    mock_resp = MagicMock()
    mock_resp.content = content
    mock_resp.raise_for_status = MagicMock()
    return mock_resp


def _client():
    return Sam2Client(base_path="http://sam2:5000/sam2")


# ---------------------------------------------------------------------------
# segment_video — point-prompt path (no initial_masks)
# ---------------------------------------------------------------------------

class TestSegmentVideoPointPrompt:

    def test_no_initial_masks_field_when_not_provided(self):
        client = _client()
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={}, video_content=b"video")
            _, kwargs = mock_post.call_args
            assert "initial_masks" not in kwargs["files"]

    def test_video_field_always_present(self):
        client = _client()
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={0: []}, video_content=b"vid")
            _, kwargs = mock_post.call_args
            assert "video" in kwargs["files"]

    def test_pose_prompts_serialised_as_json(self):
        client = _client()
        prompts = {0: [[[10, 20, 1]]]}
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts=prompts, video_content=b"vid")
            _, kwargs = mock_post.call_args
            import json
            decoded = json.loads(kwargs["data"]["pose_prompts"])
            # JSON always stringifies dict keys, so int 0 becomes str "0" on the wire
            assert decoded == {"0": [[[10, 20, 1]]]}

    def test_model_variant_forwarded(self):
        client = _client()
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={}, video_content=b"vid", model_variant="sam2.1_hiera_large")
            _, kwargs = mock_post.call_args
            assert kwargs["data"]["model_variant"] == "sam2.1_hiera_large"

    def test_returns_response_content(self):
        client = _client()
        expected = b"some_npz_bytes"
        with patch("requests.post", return_value=_make_mock_response(content=expected)):
            result = client.segment_video(pose_prompts={}, video_content=b"vid")
        assert result == expected


# ---------------------------------------------------------------------------
# segment_video — mask-prompt path (initial_masks provided)
# ---------------------------------------------------------------------------

class TestSegmentVideoMaskPrompt:

    def test_initial_masks_field_present_when_provided(self):
        client = _client()
        masks = {1: np.ones((100, 100), dtype=bool)}
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={}, video_content=b"vid", initial_masks=masks)
            _, kwargs = mock_post.call_args
            assert "initial_masks" in kwargs["files"]

    def test_initial_masks_npz_roundtrips_correctly(self):
        """The bytes sent must decode back to the original arrays."""
        client = _client()
        mask1 = np.array([[True, False], [False, True]], dtype=bool)
        mask2 = np.zeros((3, 3), dtype=bool)
        initial_masks = {1: mask1, 7: mask2}

        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={}, video_content=b"vid", initial_masks=initial_masks)
            _, kwargs = mock_post.call_args
            # Extract the bytes that would be uploaded
            _name, npz_bytes, _mime = kwargs["files"]["initial_masks"]

        loaded = np.load(io.BytesIO(npz_bytes))
        assert set(loaded.files) == {"1", "7"}
        np.testing.assert_array_equal(loaded["1"], mask1)
        np.testing.assert_array_equal(loaded["7"], mask2)

    def test_initial_masks_keys_are_strings(self):
        """np.savez requires string keys; int keys would raise TypeError."""
        client = _client()
        masks = {3: np.ones((4, 4), dtype=bool)}
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={}, video_content=b"vid", initial_masks=masks)
            _, kwargs = mock_post.call_args
            _name, npz_bytes, _mime = kwargs["files"]["initial_masks"]

        loaded = np.load(io.BytesIO(npz_bytes))
        assert "3" in loaded.files   # str key, not int

    def test_video_still_present_with_initial_masks(self):
        client = _client()
        masks = {1: np.ones((10, 10), dtype=bool)}
        with patch("requests.post", return_value=_make_mock_response()) as mock_post:
            client.segment_video(pose_prompts={}, video_content=b"vid", initial_masks=masks)
            _, kwargs = mock_post.call_args
            assert "video" in kwargs["files"]


# ---------------------------------------------------------------------------
# decode_mask_npz_content
# ---------------------------------------------------------------------------

class TestDecodeMaskNpzContent:

    def _make_npz(self, frame_masks: dict) -> bytes:
        """frame_masks: {frame_idx: {obj_id: array}}"""
        flat = {
            f"frame{frame}_mask{obj}": arr
            for frame, objs in frame_masks.items()
            for obj, arr in objs.items()
        }
        buf = io.BytesIO()
        np.savez_compressed(buf, **flat)
        buf.seek(0)
        return buf.read()

    def test_single_frame_single_object(self):
        client = _client()
        arr = np.ones((2, 2), dtype=bool)
        content = self._make_npz({0: {1: arr}})
        result = client.decode_mask_npz_content(content)
        assert 0 in result
        assert 1 in result[0]
        np.testing.assert_array_equal(result[0][1], arr)

    def test_multiple_frames_multiple_objects(self):
        client = _client()
        content = self._make_npz({
            0: {1: np.ones((3, 3), dtype=bool), 2: np.zeros((3, 3), dtype=bool)},
            1: {1: np.zeros((3, 3), dtype=bool)},
        })
        result = client.decode_mask_npz_content(content)
        assert set(result.keys()) == {0, 1}
        assert set(result[0].keys()) == {1, 2}
        assert set(result[1].keys()) == {1}
