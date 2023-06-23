from backend_client import BackendClient
from local_data_manager import LocalDataManager
from video_manager import VideoManager
import time
import sys
import os
from runner import run_masking
from models import RunParams

DATA_BASE_DIR = 'local_data'
ORIGINAL_DATA_BASE_DIR = os.path.join(DATA_BASE_DIR, 'original')

backend_client = BackendClient()
video_manager = VideoManager(backend_client, LocalDataManager(ORIGINAL_DATA_BASE_DIR))


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


