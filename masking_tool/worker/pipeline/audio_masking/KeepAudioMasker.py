import os

from masking_tool.worker.pipeline.audio_masking.BaseAudioMasker import BaseAudioMasker
from moviepy.editor import VideoFileClip


class KeepAudioMasker(BaseAudioMasker):
    # Extracts the audio track from a video and write it to an mp3 file
    def __init__(self, params: dict):
        pass

    def mask(input_path):
        output_path = os.path.splitext(input_path)[0] + ".mp3"
        video = VideoFileClip(input_path)
        audio = video.audio
        audio.write_audiofile(output_path)
        return output_path
