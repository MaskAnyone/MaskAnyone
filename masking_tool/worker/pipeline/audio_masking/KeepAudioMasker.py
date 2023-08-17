import os

from pipeline.audio_masking.BaseAudioMasker import BaseAudioMasker
from moviepy.editor import VideoFileClip
from config import (
    VIDEOS_BASE_PATH,
    RESULT_BASE_PATH,
)


class KeepAudioMasker(BaseAudioMasker):
    # Extracts the audio track from a video and write it to an mp3 file
    def __init__(self, params: dict):
        pass

    def mask(self, video_id: str):
        input_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
        output_path = os.path.join(RESULT_BASE_PATH, video_id + ".mp3")

        video = VideoFileClip(input_path)
        audio = video.audio
        audio.write_audiofile(output_path)

        return output_path
