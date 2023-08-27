import json
import os
import re
import subprocess
import time
import uuid

from common.worker import Worker
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH, DOCKER_MODELS_CONFIG_PATH
from common.utils.app_utils import save_preview_image


def handle_job_custom_model(job, backend_client, video_manager):
    model_name = job["type"]
    print(os.path.exists(DOCKER_MODELS_CONFIG_PATH))
    print(os.listdir(("/")))
    print(os.listdir((DOCKER_MODELS_CONFIG_PATH)))
    video_in_path = os.path.join(VIDEOS_BASE_PATH, job["video_id"] + ".mp4")
    config_path = os.path.join(DOCKER_MODELS_CONFIG_PATH, model_name + ".json")
    print(video_in_path)
    print(os.path.exists(video_in_path))

    def kebabify(key: str):
        return re.sub(r"(?<!^)(?=[A-Z])", "-", key).lower()

    if not os.path.exists(config_path):
        raise Exception(f"No config for docker image {model_name} found")
    with open(config_path, "r") as f:
        data = json.load(f)
        arguments = job["data"]
        run_command = data["run_command"]
        entry_point = data["entry_point"]
        video_out_path = os.path.join(RESULT_BASE_PATH, f"{job['video_id']}.mp4")
        if "maskingModel" in arguments:
            arguments.pop("maskingModel")
        argument_list = []
        for key in arguments:
            argument_list.append(f"--{kebabify(key)}")
            argument_list.append(str(arguments[key]))
        backend_progress_path = backend_client._make_url(
            "jobs/" + job["id"] + "/progress"
        )
        command = [
            run_command,
            entry_point,
            f"--in-path",
            video_in_path,
            f"--out-path",
            video_out_path,
            *argument_list,
        ]

        if data["can_send_progress_update"]:
            command.append(f"--backend-update-url")
            command.append(backend_progress_path)

        if data["can_produce_extra_file"]:
            command.append(f"--out-path-extra")
            file_ending = data["extra_file_ending"]
            command.append(
                os.path.join(RESULT_BASE_PATH, f"{job['video_id']}.{file_ending}")
            )

        res = subprocess.run(command, shell=False, capture_output=True)
        print(res.stderr)
        print(res.stdout)
        print(res.returncode)

        if not res.returncode == 0:
            raise Exception(f"Error while running docker image {model_name}")
        if os.path.exists(video_out_path):
            save_preview_image(video_out_path)
            video_manager.upload_result_video(job["video_id"], job["result_video_id"])
            video_manager.upload_result_video_preview_image(
                job["video_id"], job["result_video_id"]
            )

        if data["can_produce_extra_file"] and os.path.exists(
            os.path.join(
                RESULT_BASE_PATH, f"{job['video_id']}.{data['extra_file_ending']}"
            )
        ):
            print("extra file found, uploading...")
            video_manager.upload_result_extra_file(
                job["video_id"], data["extra_file_ending"], job["result_video_id"]
            )


worker_id = str(uuid.uuid4())
worker_type = os.environ["WORKER_TYPE"]
time.sleep(5)  # wait for backend to come online
worker = Worker(worker_type, worker_id, handle_job_custom_model)
worker.run()  # runs loop waiting for jobs
