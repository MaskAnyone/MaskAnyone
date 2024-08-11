import cv2
import numpy as np

from typing import Callable
from communication.sam2_client import Sam2Client


colors = [
    (0, 0, 255),   # Red
    (0, 255, 0),   # Green
    (255, 0, 0),   # Blue
    (0, 255, 255), # Yellow
    (255, 0, 255), # Magenta
    (255, 255, 0), # Cyan
    # Add more colors if needed
]


class Sam2PoseMasker:
    _sam2_client: Sam2Client
    _input_path: str
    _output_path: str
    _progress_callback: Callable[[int], None]

    def __init__(
            self,
            sam2_client: Sam2Client,
            input_path: str,
            output_path: str,
            progress_callback: Callable[[int], None]
    ):
        self._sam2_client = sam2_client
        self._input_path = input_path
        self._output_path = output_path
        self._progress_callback = progress_callback

    def mask(self, video_masking_data: dict):
        print("Starting SAM2 video masking with options", video_masking_data)

        file = open(self._input_path, "rb")
        content = file.read()
        file.close()

        masks = self._sam2_client.segment_video(
            video_masking_data['posePrompts'],
            content
        )

        video_capture = cv2.VideoCapture(self._input_path)
        frame_width = video_capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frame_height = video_capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        sample_rate = video_capture.get(cv2.CAP_PROP_FPS)

        video_writer = cv2.VideoWriter(
            self._output_path,
            cv2.VideoWriter_fourcc(*'mp4v'),
            fps=sample_rate,
            frameSize=(int(frame_width), int(frame_height))
        )

        idx = 0
        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            output_frame = frame.copy()
            alpha = 0.5

            for object_id in range(1, len(masks[idx]) + 1):
                mask = masks[idx][object_id][0]
                color = colors[(object_id - 1) % len(colors)]

                overlay = np.zeros_like(output_frame)
                overlay[:, :, 0] = color[0]
                overlay[:, :, 1] = color[1]
                overlay[:, :, 2] = color[2]

                output_frame[mask] = (alpha * overlay[mask] + (1 - alpha) * output_frame[mask]).astype(np.uint8)

            video_writer.write(output_frame)
            idx += 1

        video_capture.release()
        video_writer.release()