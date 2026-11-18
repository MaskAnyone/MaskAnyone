import subprocess


class VideoCompatibilityChecker:
    """
    Checks whether a video file is compatible with browsers.

    Compatibility requires:
    - Container: MP4 (the file extension lies on disk; ffprobe is authoritative)
    - Video codec: h264
    - Audio codec: aac, mp3, or none
    """

    @staticmethod
    def is_browser_compatible(video_path: str) -> bool:
        container = VideoCompatibilityChecker.get_container(video_path)
        video_codec = VideoCompatibilityChecker.get_codec(video_path, "v")
        audio_codec = VideoCompatibilityChecker.get_codec(video_path, "a")

        # ffprobe returns format_name as a comma-separated alias list, e.g.
        # "mov,mp4,m4a,3gp,3g2,mj2" for any MP4-family file. AVI shows up as
        # "avi", MKV as "matroska,webm", etc. Anything not containing "mp4"
        # needs remuxing to MP4 even if the codecs are already correct.
        if "mp4" not in container.split(","):
            return False
        if video_codec != "h264":
            return False
        if audio_codec and audio_codec not in ("aac", "mp3"):
            return False
        return True

    @staticmethod
    def get_container(file_path: str) -> str:
        """Return ffprobe's `format_name` (lowercase, comma-separated alias list)."""
        try:
            result = subprocess.run(
                [
                    "ffprobe", "-v", "error",
                    "-show_entries", "format=format_name",
                    "-of", "default=noprint_wrappers=1:nokey=1",
                    file_path
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            return result.stdout.strip().lower()
        except Exception:
            return ""

    @staticmethod
    def get_codec(file_path: str, stream_type: str) -> str:
        """
        Returns codec name for the given stream type ('v' = video, 'a' = audio).
        Returns empty string if stream is missing or on error.
        """
        try:
            result = subprocess.run(
                [
                    "ffprobe", "-v", "error",
                    "-select_streams", f"{stream_type}:0",
                    "-show_entries", "stream=codec_name",
                    "-of", "default=noprint_wrappers=1:nokey=1",
                    file_path
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            return result.stdout.strip().lower()
        except Exception:
            return ""
