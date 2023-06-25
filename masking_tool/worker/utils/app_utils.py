import os
import cv2

from config import RESULT_BASE_PATH

def init_directories():
    print("Initializing directories")
    if not os.path.exists(RESULT_BASE_PATH):
        os.mkdir(RESULT_BASE_PATH)
    
    temp_dir_path = os.path.join(RESULT_BASE_PATH, "temp")
    if not os.path.exists(temp_dir_path):
        os.mkdir(temp_dir_path)
    else:
        clear_temp_dir()

def clear_temp_dir():
    print("Cleaning temp dir")
    temp_dir_path = os.path.join(RESULT_BASE_PATH, "temp")
    if os.path.exists(temp_dir_path):
        for f in os.listdir(temp_dir_path):
            os.remove(os.path.join(temp_dir_path, f))

def save_preview_image(masked_video_path):
    print("Saving preview image of masked video")
    video_cap = cv2.VideoCapture(masked_video_path)
    file_name = os.path.splitext(os.path.basename(masked_video_path))[0] + ".png"
    preview_img_path = os.path.join(os.path.split(masked_video_path)[0], file_name)
    num_frames = int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT))
    video_cap.set(cv2.CAP_PROP_POS_FRAMES, int(num_frames/2))
    _, frame = video_cap.read()
    cv2.imwrite(preview_img_path, frame)
