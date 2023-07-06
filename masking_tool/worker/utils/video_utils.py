import cv2
import os

from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH


def setup_video_processing(video_in_path: str, video_out_path: str):
    video_cap = cv2.VideoCapture(video_in_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)

    """
    vp09 seems to be a reasonable compromise that doesn't require a custom build, works in most modern browsers
    and is comparably efficient

    H264 and avc1 aren't supported without a custom build of ffmpeg and python-opencv; See: https://www.swiftlane.com/blog/generating-mp4s-using-opencv-python-with-the-avc1-codec/
    mp4v is not supported by browsers
    """
    fourcc = cv2.VideoWriter_fourcc(*"vp09")
    out = cv2.VideoWriter(
        video_out_path,
        fourcc,
        fps=samplerate,
        frameSize=(int(frameWidth), int(frameHeight)),
    )

    return video_cap, out
