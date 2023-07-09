import cv2
import os


def extract_codec_from_capture(capture) -> str:
    h = int(capture.get(cv2.CAP_PROP_FOURCC))

    codec = (
            chr(h & 0xFF)
            + chr((h >> 8) & 0xFF)
            + chr((h >> 16) & 0xFF)
            + chr((h >> 24) & 0xFF)
    )

    return codec


def extract_video_info_from_capture(video_path: str, capture) -> dict:
    frame_width = round(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = round(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = capture.get(cv2.CAP_PROP_FPS)
    frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
    duration = frame_count / fps

    return {
        'frame_width': frame_width,
        'frame_height': frame_height,
        'fps': round(fps),
        'frame_count': round(frame_count),
        'duration': duration,
        'codec': extract_codec_from_capture(capture),
        'size': os.path.getsize(video_path)
    }
