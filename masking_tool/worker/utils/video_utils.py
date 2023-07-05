import cv2
import os

from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH

def setup_video_processing(video_in_path: str, video_out_path: str):
    video_cap = cv2.VideoCapture(video_in_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    out = cv2.VideoWriter(video_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))
    return video_cap, out