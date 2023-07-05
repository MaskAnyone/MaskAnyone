from backend_client import BackendClient
from local_data_manager import LocalDataManager
from config import VIDEOS_BASE_PATH
from pipeline.Pipeline import Pipeline
from video_manager import VideoManager
import time
import sys
import os
from utils.app_utils import init_directories

DATA_BASE_DIR = 'local_data'

backend_client = BackendClient()
video_manager = VideoManager(backend_client, LocalDataManager(DATA_BASE_DIR))
init_directories()


def fetch_next_job():
    try:
        return backend_client.fetch_next_job()
    except Exception as error:
        print('Error while fetching next job')

    return None


def handle_job(job):
    print('Start working on job ' + job['id'])

    video_id = job['video_id']
    video_manager.load_original_video(video_id)

    video_path = os.path.join(VIDEOS_BASE_PATH, video_id + '.mp4')
    masking_pipeline = Pipeline(job['data'])
    masking_pipeline.run(video_path)

    video_manager.upload_result_video(video_id)
    video_manager.upload_result_video_preview_image(video_id)
    video_manager.cleanup_result_video_files(video_id)


while True:
    job = fetch_next_job()

    if job is None:
        print('No suitable job found')
    else:
        try:
            handle_job(job)
            backend_client.mark_job_as_finished(job['id'])
        except Exception as error:
            print('Handling job with id ' + job['id'] + ' failed')
            print(error)
            # @todo: mark job as failed in backend

    sys.stdout.flush()  # Flush log output
    time.sleep(10)  #


