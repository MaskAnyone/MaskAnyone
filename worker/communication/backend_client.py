import os
import requests

class BackendClient:
    _worker_id: str
    _base_path: str

    def __init__(self, worker_id: str, base_path: str):
        self._worker_id = worker_id
        self._base_path = base_path

    def register_worker(self):
        requests.post(
            self._make_url("register"),
            json={"capabilities": ["media_pipe"]}
        )

    def ping_backend(self):
        requests.post(
            self._make_url("ping")
        )

    def fetch_next_job(self):
        # @todo remove job type
        job_type = "basic_masking"

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
        return self._base_path + self._worker_id + "/" + path
