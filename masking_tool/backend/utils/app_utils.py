import os

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