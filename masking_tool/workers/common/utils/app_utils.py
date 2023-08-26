import os
import cv2

from config import (
    BLENDSHAPES_BASE_PATH,
    RESULT_BASE_PATH,
    TEMP_PATH,
    TS_BASE_PATH,
    VIDEOS_BASE_PATH,
    DATA_BASE_DIR,
)


def init_directories():
    print("Initializing directories")
    if not os.path.exists(DATA_BASE_DIR):
        os.mkdir(DATA_BASE_DIR)

    if not os.path.exists(RESULT_BASE_PATH):
        os.mkdir(RESULT_BASE_PATH)

    if not os.path.exists(VIDEOS_BASE_PATH):
        os.mkdir(VIDEOS_BASE_PATH)

    if not os.path.exists(TS_BASE_PATH):
        os.mkdir(TS_BASE_PATH)

    if not os.path.exists(BLENDSHAPES_BASE_PATH):
        os.mkdir(BLENDSHAPES_BASE_PATH)

    if not os.path.exists(TEMP_PATH):
        os.mkdir(TEMP_PATH)
    else:
        clear_dirs()


def clear_temp_dir():
    print("Cleaning temp dir")
    if os.path.exists(TEMP_PATH):
        for f in os.listdir(TEMP_PATH):
            os.remove(os.path.join(TEMP_PATH, f))


def clear_results_dir():
    print("Cleaning results dir")
    if os.path.exists(RESULT_BASE_PATH):
        for f in os.listdir(RESULT_BASE_PATH):
            if os.path.isfile(os.path.join(RESULT_BASE_PATH, f)):
                os.remove(os.path.join(RESULT_BASE_PATH, f))


def clear_dirs():
    clear_temp_dir()
    clear_results_dir()


def save_preview_image(masked_video_path):
    print("Saving preview image of masked video")
    video_cap = cv2.VideoCapture(masked_video_path)
    file_name = os.path.splitext(os.path.basename(masked_video_path))[0] + ".png"
    preview_img_path = os.path.join(os.path.split(masked_video_path)[0], file_name)
    num_frames = int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT))
    video_cap.set(cv2.CAP_PROP_POS_FRAMES, int(num_frames / 2))
    _, frame = video_cap.read()
    cv2.imwrite(preview_img_path, frame)
