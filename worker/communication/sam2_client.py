import os
import requests
import json
import io
import numpy as np

class Sam2Client:
    _base_path: str

    def __init__(self, base_path: str):
        self._base_path = base_path

    def segment_video(self, pose_prompts, video_content, model_variant: str = "sam2.1_hiera_small"):
        files = {
            'video': ('video.mp4', video_content, 'video/mp4'),
        }

        data = {
            'pose_prompts': json.dumps(pose_prompts),
            'model_variant': model_variant,
        }

        response = requests.post(
            self._make_url("segment-video"),
            files=files,
            data=data,
        )

        response.raise_for_status()
        return response.content

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
