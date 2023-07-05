import cv2
import os

from masking_tool.worker.config import RESULT_BASE_PATH

def setup_video_processing(video_path: str):
    video_cap = cv2.VideoCapture(video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join(RESULT_BASE_PATH, "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))
    return video_cap, out