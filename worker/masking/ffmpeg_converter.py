import subprocess
import os


class FFmpegConverter:
    def __init__(self):
        self.ffmpeg_path = "ffmpeg"
        # WORKER_VIDEO_ENCODER: h264_nvenc (GPU, 5–10× faster), libx264 (CPU fallback).
        # Set to libx264 in docker-compose if the worker has no GPU access.
        self.encoder = os.environ.get("WORKER_VIDEO_ENCODER", "h264_nvenc")
        # NVENC uses -cq for quality-based rate control (equivalent to libx264 -crf);
        # libx264 uses -crf. Preset mapping: libx264 "medium" ≈ nvenc "p4".
        self.quality = 23
        self.preset = "p4" if self.encoder == "h264_nvenc" else "medium"

    def _video_encode_args(self) -> list:
        quality_flag = "-cq" if self.encoder == "h264_nvenc" else "-crf"
        return ["-c:v", self.encoder, quality_flag, str(self.quality), "-preset", self.preset]

    def _hw_decode_args(self) -> list:
        # NVDEC decode pairs with NVENC encode so frames stay on the GPU the whole way.
        return ["-hwaccel", "cuda"] if self.encoder == "h264_nvenc" else []

    @staticmethod
    def _output_fps_args(output_fps: float | None) -> list:
        # ffmpeg -r as an OUTPUT option: drop or duplicate frames so the encoded
        # stream has constant fps == output_fps. Pre-input -r would re-stamp the
        # source timestamps (wrong for our pipeline). None preserves source fps.
        if output_fps is None or output_fps <= 0:
            return []
        return ["-r", str(output_fps)]

    def convert_video_in_place(self, input_video: str, output_fps: float | None = None):
        temp_output = f"{input_video}.temp.mp4"
        command = [
            self.ffmpeg_path,
            *self._hw_decode_args(),
            "-i", input_video,
            *self._video_encode_args(),
            *self._output_fps_args(output_fps),
            "-c:a", "copy",
            temp_output
        ]
        self.run_command(command)
        self.replace_file(temp_output, input_video)

    def convert_video_with_audio_in_place(self, input_video: str, audio_video: str, output_fps: float | None = None):
        temp_output = f"{input_video}.temp.mp4"
        command = [
            self.ffmpeg_path,
            *self._hw_decode_args(),
            "-i", input_video,
            "-i", audio_video,
            "-map", "0:v",
            "-map", "1:a?",
            *self._video_encode_args(),
            *self._output_fps_args(output_fps),
            "-c:a", "copy",
            temp_output
        ]
        self.run_command(command)
        self.replace_file(temp_output, input_video)

    def extract_audio_to_wav(self, input_video: str, output_wav: str) -> bool:
        """Extract the first audio track to a mono PCM-16 WAV.

        Returns True iff ffmpeg succeeded and the file exists. Returns False
        cleanly when the source has no audio track — caller should fall back.
        """
        command = [
            self.ffmpeg_path, "-y",
            "-i", input_video,
            "-vn",
            "-acodec", "pcm_s16le",
            "-ac", "1",
            output_wav,
        ]
        try:
            result = subprocess.run(command, capture_output=True)
            if result.returncode != 0:
                return False
            return os.path.exists(output_wav) and os.path.getsize(output_wav) > 44
        except Exception:
            return False

    def replace_audio_in_place(self, input_video: str, audio_wav: str, output_fps: float | None = None):
        """Replace the audio track of input_video with audio_wav, re-encoding video."""
        temp_output = f"{input_video}.temp.mp4"
        command = [
            self.ffmpeg_path, "-y",
            *self._hw_decode_args(),
            "-i", input_video,
            "-i", audio_wav,
            "-map", "0:v",
            "-map", "1:a",
            *self._video_encode_args(),
            *self._output_fps_args(output_fps),
            "-c:a", "aac",
            "-b:a", "128k",
            "-shortest",
            temp_output,
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
