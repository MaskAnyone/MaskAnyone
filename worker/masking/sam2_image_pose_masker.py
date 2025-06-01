import time
import io
import cv2

import numpy as np
from typing import Callable
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.mask_renderer import MaskRenderer
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
        chunk_generator = self._sam2_client.stream_segment_video(video_masking_data['posePrompts'], content)
        del content

        mask_renderers = {
            obj_id: MaskRenderer(
                video_masking_data['hidingStrategies'][obj_id - 1],
                {'level': 4, 'object_borders': True, 'averageColor': True}
            )
            for obj_id in [1] # TODO!!!!
        }

        video_capture, frame_width, frame_height, sample_rate = self._open_video()
        video_writer = self._initialize_video_writer(frame_width, frame_height, sample_rate)

        sam2_masks_file = open(self._sam2_masks_path, "wb")
        sam2_masks_file.close()

        for npz_chunk in chunk_generator:
            # The chunks *should* always come in incremental order, so we can just read the next frame here and they should match
            success, frame = video_capture.read()
            if not success:
                raise RuntimeError("Failed to read next video frame")

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            output_frame = frame.copy()

            masks = np.load(io.BytesIO(npz_chunk))
            for name in masks.files:
                mask = masks[name][0]
                obj_id = int(name.split("_mask")[-1])
                print(name, obj_id, mask.shape, flush=True)

                mask_renderer = mask_renderers[obj_id]
                mask_renderer.apply_to_image(output_frame, mask, obj_id)

            output_frame = cv2.cvtColor(output_frame, cv2.COLOR_RGB2BGR)
            video_writer.write(output_frame)

        video_capture.release()
        video_writer.release()




        poses_file = open(self._poses_path, "w")
        poses_file.write("{}")
        poses_file.close()



        print("Elapsed time (total):", time.time() - start)

    def _read_video_content(self):
        with open(self._input_path, "rb") as file:
            return file.read()

    def _open_video(self):
        video_capture = cv2.VideoCapture(self._input_path)
        frame_width = video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = video_capture.get(cv2.CAP_PROP_FPS)

        return video_capture, frame_width, frame_height, sample_rate

    def _initialize_video_writer(self, frame_width, frame_height, sample_rate):
        return cv2.VideoWriter(
            self._output_path,
            cv2.VideoWriter_fourcc(*'mp4v'),
            fps=sample_rate,
            frameSize=(int(frame_width), int(frame_height))
        )
