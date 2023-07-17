from backend_client import BackendClient
from local_data_manager import LocalDataManager
from pipeline.Pipeline import Pipeline
from video_manager import VideoManager
import time
import sys
import uuid
from utils.app_utils import init_directories

DATA_BASE_DIR = "local_data"
worker_id = str(uuid.uuid4())

backend_client = BackendClient(worker_id)
backend_client.register_worker(worker_id)

video_manager = VideoManager(backend_client, LocalDataManager(DATA_BASE_DIR))
init_directories()


def fetch_next_job():
    try:
        return backend_client.fetch_next_job()
    except Exception as error:
        print("Error while fetching next job")
        print(error)

    return None


def produces_out_vid(run_params: dict):
    masking_params = run_params["videoMasking"]
    for video_part in masking_params:
        if masking_params[video_part]["hidingStrategy"]["key"] != "none":
            return True
        if masking_params[video_part]["maskingStrategy"]["key"] != "none":
            return True
    return False


def produces_kinematics(run_params: dict):
    if run_params["threeDModelCreation"]["skeleton"]:
        return True
    return False


def produces_blendshapes(run_params: dict):
    if run_params["threeDModelCreation"]["blendshapes"]:
        return True
    return False


def handle_job(job):
    print("Start working on job " + job["id"])

    video_id = job["video_id"]
    video_manager.load_original_video(video_id)

    masking_pipeline = Pipeline(job["data"], backend_client)
    masking_pipeline.run(video_id, job["id"])

    result_video_id = job["result_video_id"]
    if produces_out_vid(job["data"]):
        video_manager.upload_result_video(video_id, result_video_id)
        video_manager.upload_result_video_preview_image(video_id, result_video_id)
    if produces_kinematics(job["data"]):
        video_manager.upload_result_kinematics(video_id, result_video_id)
    if produces_blendshapes(job["data"]):
        video_manager.upload_result_blendshapes(video_id, result_video_id)
    video_manager.cleanup_result_video_files(video_id)


while True:
    job = fetch_next_job()

    if job is None:
        print("No suitable job found")
    else:
        try:
            handle_job(job)
            backend_client.mark_job_as_finished(job["id"])
        except Exception as error:
            print("Handling job with id " + job["id"] + " failed")
            print(error)
            backend_client.mark_job_as_failed(job["id"])

    sys.stdout.flush()  # Flush log output
    time.sleep(10)  #
