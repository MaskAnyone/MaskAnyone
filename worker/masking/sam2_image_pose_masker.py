import time
import io

import numpy as np
from typing import Callable
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.media_pipe_landmarker import MediaPipeLandmarker

class Sam2ImagePoseMasker:
    _sam2_client: Sam2Client
    _openpose_client: OpenposeClient
    _input_path: str
    _output_path: str
    _sam2_masks_path: str
    _poses_path: str
    _progress_callback: Callable[[int], None]
    _media_pipe_landmarker: MediaPipeLandmarker

    def __init__(
            self,
            sam2_client: Sam2Client,
            openpose_client: OpenposeClient,
            input_path: str,
            output_path: str,
            sam2_masks_path: str,
            poses_path: str,
            progress_callback: Callable[[int], None]
    ):
        self._sam2_client = sam2_client
        self._openpose_client = openpose_client
        self._input_path = input_path
        self._output_path = output_path
        self._sam2_masks_path = sam2_masks_path
        self._poses_path = poses_path
        self._progress_callback = progress_callback
        self._media_pipe_landmarker = MediaPipeLandmarker()

    def mask(self, video_masking_data: dict):
        start = time.time()

        content = self._read_video_content()

        print("START", time.time(), flush=True)
        for npz_chunk in self._sam2_client.stream_segment_video(video_masking_data['posePrompts'], content):
            masks = np.load(io.BytesIO(npz_chunk))
            for name in masks.files:
                mask = masks[name]
                print(name, mask.shape, mask.dtype, time.time(), flush=True)
        print("DONE", time.time(), flush=True)

        del content

        print("Elapsed time (total):", time.time() - start)

    def _read_video_content(self):
        with open(self._input_path, "rb") as file:
            return file.read()
