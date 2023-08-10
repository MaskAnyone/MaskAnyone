import os
import subprocess

from masking_tool.worker.pipeline.audio_masking.BaseAudioMasker import BaseAudioMasker
from moviepy.editor import VideoFileClip


class KeepAudioMasker(BaseAudioMasker):
    # Extracts the audio track from a video and write it to an mp3 file
    def __init__(self, params: dict):
        pass

    def mask(input_path):
        input_mp3_path = os.path.splitext(input_path)[0] + "_tmp.mp3"
        output_path = os.path.splitext(input_path)[0] + ".mp3"
        video = VideoFileClip(input_path)
        audio = video.audio
        audio.write_audiofile(input_mp3_path)

        f0_up_key = 0  # transpose value
        model = "/app/Retrieval-based-Voice-Conversion-WebUI/weights/arianagrandev2.pth"
        file_index = "/app/Retrieval-based-Voice-Conversion-WebUI/weights/added_IVF1033_Flat_nprobe_1_v2.index"
        device = "cpu"
        f0_method = "crepe"

        subprocess.run(
            [
                "python3",
                "/app/Retrieval-based-Voice-Conversion-WebUI/infer_cli.py",
                f0_up_key,
                input_mp3_path,
                output_path,
                model,
                file_index,
                device,
                f0_method,
            ]
        )

        return output_path
