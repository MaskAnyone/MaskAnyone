import subprocess


class VideoCompatibilityChecker:
    """
    Checks whether a video file is compatible with browsers.
    Assumes MP4 container.

    Compatibility requires:
    - Video codec: h264
    - Audio codec: aac, mp3, or none
    """

    @staticmethod
    def is_browser_compatible(video_path: str) -> bool:
        video_codec = VideoCompatibilityChecker.get_codec(video_path, "v")
        audio_codec = VideoCompatibilityChecker.get_codec(video_path, "a")

        if video_codec != "h264":
            return False
        if audio_codec and audio_codec not in ("aac", "mp3"):
            return False
        return True

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
