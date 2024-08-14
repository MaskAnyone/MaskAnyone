import subprocess
import os


class FFmpegConverter:
    def __init__(self):
        self.ffmpeg_path = "ffmpeg"
        self.crf = 23
        self.preset = "medium"

    def convert_video_in_place(self, input_video: str):
        temp_output = f"{input_video}.temp.mp4"
        command = [
            self.ffmpeg_path,
            "-i", input_video,
            "-c:v", "libx264",
            "-crf", str(self.crf),
            "-preset", self.preset,
            "-c:a", "copy",
            temp_output
        ]
        self.run_command(command)
        self.replace_file(temp_output, input_video)

    def convert_video_with_audio_in_place(self, input_video: str, audio_video: str):
        temp_output = f"{input_video}.temp.mp4"
        command = [
            self.ffmpeg_path,
            "-i", input_video,
            "-i", audio_video,
            "-map", "0:v",
            "-map", "1:a",
            "-c:v", "libx264",
            "-crf", str(self.crf),
            "-preset", self.preset,
            "-c:a", "copy",
            temp_output
        ]
        self.run_command(command)
        self.replace_file(temp_output, input_video)

    @staticmethod
    def run_command(command):
        try:
            subprocess.run(command, check=True)
            print(f"Command '{' '.join(command)}' executed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"An error occurred while running command '{' '.join(command)}': {e}")

    @staticmethod
    def replace_file(src: str, dst: str):
        try:
            os.replace(src, dst)
            print(f"Replaced '{dst}' with '{src}' successfully.")
        except OSError as e:
            print(f"An error occurred while replacing file '{dst}' with '{src}': {e}")
