import os
import subprocess
import torch

from pipeline.audio_masking.BaseAudioMasker import BaseAudioMasker
from moviepy.editor import VideoFileClip


class RVCAudioMasker(BaseAudioMasker):
    # Extracts the audio track from a video and write it to an mp3 file
    def __init__(self, params: dict):
        self.params = params

    def is_male(self, input_path):
        pass

    def mask(self, input_path):
        input_mp3_path = os.path.splitext(input_path)[0] + "_tmp.mp3"
        output_path = os.path.splitext(input_path)[0] + ".mp3"
        video = VideoFileClip(input_path)
        audio = video.audio
        audio.write_audiofile(input_mp3_path)

        f0_up_key = 0  # transpose value
        if self.is_male(input_mp3_path):
            model = "/Retrieval-based-Voice-Conversion-WebUI/weights/weights/KanyeV2_Redux_40khz.pth"
            file_index = "/Retrieval-based-Voice-Conversion-WebUI/weights/logs/KanyeV2_Redux_40khz/added_IVF1663_Flat_nprobe_1_KanyeV2_Redux_40khz_v2.index"
        else:
            model = "/Retrieval-based-Voice-Conversion-WebUI/weights/arianagrandev2.pth"
            file_index = "/Retrieval-based-Voice-Conversion-WebUI/weights/added_IVF1033_Flat_nprobe_1_v2.index"
        device = "cuda" if torch.cuda.is_available() else "cpu"
        f0_method = "crepe"

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
