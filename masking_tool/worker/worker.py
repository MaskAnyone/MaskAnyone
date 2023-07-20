import json
import os
from backend_client import BackendClient
from local_data_manager import LocalDataManager
from config import TEMP_PATH, VIDEOS_BASE_PATH
from utils.runparams_utils import (
    produces_blendshapes,
    produces_kinematics,
    produces_out_vid,
)
from pipeline.Pipeline import Pipeline
from video_manager import VideoManager
import time
import sys
import uuid
from utils.app_utils import init_directories
import subprocess

DATA_BASE_DIR = "local_data"
worker_id = str(uuid.uuid4())
worker_type = os.environ["WORKER_TYPE"]

backend_client = BackendClient(worker_id)
backend_client.register_worker(worker_id)

video_manager = VideoManager(backend_client, LocalDataManager(DATA_BASE_DIR))
init_directories()


def fetch_next_job():
    try:
        print(worker_type)
        return backend_client.fetch_next_job(worker_type)
    except Exception as error:
        print("Error while fetching next job")
        print(error)

    return None


def handle_job(job):
    print("Start working on job " + job["id"])

    video_manager.load_original_video(job["video_id"])

    if worker_type == "basic_masking":
        handle_job_basic_masking(job)
    else:
        handle_job_custom_model(job)


def handle_job_basic_masking(job):
    video_id = job["video_id"]
    result_video_id = job["result_video_id"]
    masking_pipeline = Pipeline(job["data"], backend_client)
    masking_pipeline.run(video_id, job["id"])

    run_params = job["data"]
    if produces_out_vid(run_params):
        video_manager.upload_result_video(video_id, result_video_id)
        video_manager.upload_result_video_preview_image(video_id, result_video_id)
    if produces_kinematics(run_params):
        video_manager.upload_result_kinematics(video_id, result_video_id)
    if produces_blendshapes(run_params):
        video_manager.upload_result_blendshapes(video_id, result_video_id)
    video_manager.cleanup_result_video_files(video_id)


def handle_job_custom_model(job):
    print(job)
    model_name = job["type"]
    video_in_path = os.path.join(VIDEOS_BASE_PATH, job["video_id"] + ".mp4")
    config_path = os.path.join("models", "docker_models", model_name, "config.json")
    if not os.path.exists(config_path):
        raise Exception(f"No config for docker image {model_name} found")
    with open(config_path, "r") as f:
        data = json.load(f)
        arguments = job["data"]
        run_command = data["run_command"]
        entry_point = data["entry_point"]
        entry_point = os.path.join("models", "docker_models", model_name, entry_point)
        video_out_path = os.path.join(TEMP_PATH, f"{job['id']}.mp4")
        argument_list = [f"{key}={arguments[key]}" for key in arguments]
        command = [
            run_command,
            entry_point,
            video_in_path,
            video_out_path,
            *argument_list,
        ]
        subprocess.check_call(command, shell=False)


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
