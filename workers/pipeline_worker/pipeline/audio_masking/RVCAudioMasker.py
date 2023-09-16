import os
import subprocess
import torch

from pipeline_worker.pipeline.audio_masking.BaseAudioMasker import BaseAudioMasker
from moviepy.editor import VideoFileClip
from config import (
    VIDEOS_BASE_PATH,
    RESULT_BASE_PATH,
)


class RVCAudioMasker(BaseAudioMasker):
    # Extracts the audio track from a video and write it to an mp3 file
    def __init__(self, params: dict):
        self.params = params

    def load_voice_model(self):
        model = os.path.join(
            "/Retrieval-based-Voice-Conversion-WebUI/weights",
            self.params["voice"],
            "model.pth",
        )
        file_index = os.path.join(
            "/Retrieval-based-Voice-Conversion-WebUI/weights",
            self.params["voice"],
            "index_file.index",
        )
        return model, file_index

    def auto_load_voice_model(self):
        return None, None

    def mask(self, video_id: str):
        input_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
        input_mp3_path = os.path.join(VIDEOS_BASE_PATH, video_id + "_tmp.mp3")
        output_path = os.path.join(RESULT_BASE_PATH, video_id + ".mp3")

        video = VideoFileClip(input_path)
        audio = video.audio
        audio.write_audiofile(input_mp3_path)

        f0_up_key = 0  # transpose value
        device = "cuda:0" if torch.cuda.is_available() else "cpu"
        f0_method = "crepe"

        if self.params["mode"] == "manual":
            model, file_index = self.load_voice_model()
        elif self.params["mode"] == "auto":
            model, file_index = self.auto_load_voice_model()
        else:
            raise ValueError("Invalid mode")

        args = [
            "python3",
            "/Retrieval-based-Voice-Conversion-WebUI/infer_cli.py",
            str(f0_up_key),
            input_mp3_path,
            output_path,
            model,
            file_index,
            device,
            f0_method,
        ]

        res = subprocess.run(
            args,
            capture_output=True,
            cwd="/Retrieval-based-Voice-Conversion-WebUI",
        )

        if res.stderr:
            print(res)

        # print(res.stdout)
        # print(res.stderr)
        return output_path
