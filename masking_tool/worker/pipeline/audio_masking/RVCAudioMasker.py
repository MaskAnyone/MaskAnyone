import os
import subprocess
import torch

from pipeline.audio_masking.BaseAudioMasker import BaseAudioMasker
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
        if self.params["voice"] == "kanyeWest":
            model = "/Retrieval-based-Voice-Conversion-WebUI/weights/weights/KanyeV2_Redux_40khz.pth"
            file_index = "/Retrieval-based-Voice-Conversion-WebUI/weights/logs/KanyeV2_Redux_40khz/added_IVF1663_Flat_nprobe_1_KanyeV2_Redux_40khz_v2.index"
        elif self.params["voice"] == "arianaGrande":
            model = "/Retrieval-based-Voice-Conversion-WebUI/weights/arianagrandev2.pth"
            file_index = "/Retrieval-based-Voice-Conversion-WebUI/weights/added_IVF1033_Flat_nprobe_1_v2.index"
        else:
            raise ValueError("Invalid voice model specified")
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
        device = "cuda" if torch.cuda.is_available() else "cpu"
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
            f"/app/{input_mp3_path}",
            f"/app/{output_path}",
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

        return output_path
