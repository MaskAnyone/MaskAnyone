from typing import List
import uuid
import requests
from enum import Enum

BASE_PATH = "http://python:8000/_worker/"


class MpKinematicsType(str, Enum):
    body = "body"
    face = "face"


class BackendClient:
    _worker_id: str

    def __init__(self, worker_id: str):
        self._worker_id = worker_id

    def register_worker(self, worker_type: str):
        requests.post(
            self._make_url("register"),
            json={'type': worker_type}
        )

    def fetch_next_job(self, job_type: str):
        response = requests.get(self._make_url(f"jobs/next/{job_type}"))
        return response.json()["job"]

    def fetch_video(self, video_id: str):
        response = requests.get(self._make_url("videos/" + video_id))
        return response.content

    def mark_job_as_finished(self, job_id: str):
        requests.post(self._make_url("jobs/" + job_id + "/finish"))

    def mark_job_as_failed(self, job_id: str):
        requests.post(self._make_url("jobs/" + job_id + "/fail"))

    def upload_result_video(self, video_id: str, result_video_id: str, content):
        requests.post(
            self._make_url("videos/" + video_id + "/results/" + result_video_id),
            data=content,
            headers={"Content-Type": "application/octet-stream"},
        )

    def upload_result_video_preview_image(
            self, video_id: str, result_video_id: str, content
    ):
        requests.post(
            self._make_url(
                "videos/" + video_id + "/results/" + result_video_id + "/preview"
            ),
            data=content,
            headers={"Content-Type": "image/png"},
        )

    def upload_result_mp_kinematics(
            self, video_id: str, result_video_id: str, data: dict, type: MpKinematicsType
    ):
        requests.post(
            self._make_url(
                "videos/"
                + video_id
                + "/results/"
                + result_video_id
                + "/mp_kinematics/"
                + type
            ),
            json=data,
        )

    def upload_result_blendshapes(
            self, video_id: str, result_video_id: str, data: dict
    ):
        requests.post(
            self._make_url(
                "videos/" + video_id + "/results/" + result_video_id + "/blendshapes"
            ),
            json=data,
        )

    def upload_result_audio_file(
            self, video_id: str, result_video_id: str, data: bytes
    ):
        requests.post(
            self._make_url(
                "videos/" + video_id + "/results/" + result_video_id + "/audio_files"
            ),
            data=data,
            headers={"Content-Type": "audio/mp3"},
        )

    def upload_result_extra_file(
            self, video_id: str, file_ending: str, result_video_id: str, data: bytes
    ):
        print("a4")
        requests.post(
            self._make_url(
                "videos/"
                + video_id
                + "/results/"
                + result_video_id
                + "/extra_files/"
                + file_ending
            ),
            data=data,
            headers={"Content-Type": "application/octet-stream"},
        )

    def update_progress(self, job_id: str, progress: int):
        requests.post(
            self._make_url("jobs/" + job_id + "/progress"),
            json={"progress": progress},
        )

    def _make_url(self, path: str) -> str:
        return BASE_PATH + self._worker_id + "/" + path

    def create_job(self, job_type: str, video_id: List[str], arguments: dict):
        job_id = str(uuid.uuid4())
        run_params = {
            "id": job_id,
            "video_ids": [video_id],
            "result_video_id": str(uuid.uuid4()),
            "run_data": arguments,
        }
        requests.post(self._make_url(f"jobs/create/{job_type}"), json=run_params)
        return job_id

    def fetch_job_status(self, job_id: str):
        response = requests.get(self._make_url(f"jobs/{job_id}/status"))
        return response.json()["status"]

    def fetch_result_video(self, job_id: str):
        response = requests.get(self._make_url("results/video/" + job_id))
        return response.content
