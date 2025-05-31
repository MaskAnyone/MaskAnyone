import os
import struct
import requests
import json
import io
import numpy as np

class Sam2Client:
    _base_path: str

    def __init__(self, base_path: str):
        self._base_path = base_path

    def segment_video(self, pose_prompts, video_content):
        """Classic blocking call – returns full .npz content."""
        files = {
            'video': ('video.mp4', video_content, 'video/mp4'),
        }

        data = {
            'pose_prompts': json.dumps(pose_prompts),
        }

        response = requests.post(
            self._make_url("segment-video"),
            files=files,
            data=data,
        )

        return response.content  # unchanged

    def stream_segment_video(self, pose_prompts, video_content):
        """Streaming version – yields .npz chunks as they arrive."""
        files = {
            'video': ('video.mp4', video_content, 'video/mp4'),
        }

        data = {
            'pose_prompts': json.dumps(pose_prompts),
        }

        response = requests.post(
            self._make_url("stream-segment-video"),
            files=files,
            data=data,
            stream=True,
        )

        raw = response.raw
        while True:
            length_bytes = raw.read(4)
            if not length_bytes:
                break
            chunk_len = struct.unpack("!I", length_bytes)[0]
            chunk = raw.read(chunk_len)
            yield chunk

    def decode_mask_npz_content(self, content):
        buffer = io.BytesIO(content)
        loaded = np.load(buffer)

        masks = {}
        for key in loaded.files:
            frame, mask = key.split('_mask')
            frame = int(frame.replace('frame', ''))
            mask = int(mask)
            if frame not in masks:
                masks[frame] = {}
            masks[frame][mask] = loaded[key]

        return masks

    def _make_url(self, path: str) -> str:
        return self._base_path + "/" + path
