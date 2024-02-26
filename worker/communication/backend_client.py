import os
import requests

BASE_PATH = os.environ["WORKER_BACKEND_BASE_PATH"]

class BackendClient:
    _worker_id: str

    def __init__(self, worker_id: str):
        self._worker_id = worker_id

    def register_worker(self):
        requests.post(
            self._make_url("register"),
            json={"capabilities": ["media_pipe"]}
        )

    def ping_backend(self):
        requests.post(
            self._make_url("ping")
        )

    def fetch_next_job(self, job_type: str):
        response = requests.get(
            self._make_url(f"jobs/next/{job_type}")
        )

        return response.json()["job"]

    def fetch_video(self, video_id: str):
        response = requests.get(
            self._make_url("videos/" + video_id)
        )

        return response.content

    def mark_job_as_finished(self, job_id: str):
        requests.post(
            self._make_url("jobs/" + job_id + "/finish")
        )

    def mark_job_as_failed(self, job_id: str):
        requests.post(
            self._make_url("jobs/" + job_id + "/fail")
        )

    def _make_url(self, path: str) -> str:
        return BASE_PATH + self._worker_id + "/" + path
