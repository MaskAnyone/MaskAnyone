from backend_client import BackendClient
from local_data_manager import LocalDataManager
from video_manager import VideoManager
import time
import sys
import os
from runner import run_masking
from models import RunParams
from utils.app_utils import clear_temp_dir, init_directories

DATA_BASE_DIR = 'local_data'

backend_client = BackendClient()
video_manager = VideoManager(backend_client, LocalDataManager(DATA_BASE_DIR))
init_directories()


def fetch_next_job():
    try:
        return backend_client.fetch_next_job()
    except:
        print('Error while fetching next job')

    return None


def handle_job(job):
    print('Start working on job ' + job['id'])
    video_manager.load_original_video(job['video_id'])

    run_masking(job['video_id'], RunParams.parse_obj(job['data']))


while True:
    job = fetch_next_job()

    if job is None:
        print('No suitable job found')
    else:
        handle_job(job)

    sys.stdout.flush()  # Flush log output
    time.sleep(10)  #


