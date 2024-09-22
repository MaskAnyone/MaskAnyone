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
        response = requests.get(
            self._make_url('jobs/next')
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

    def upload_result_video(self, video_id: str, result_video_id: str, content):
        requests.post(
            self._make_url("videos/" + video_id + "/results/" + result_video_id),
            data=content,
            headers={"Content-Type": "application/octet-stream"},
        )

    def upload_result_video_preview_image(self, video_id: str, result_video_id: str, content):
        requests.post(
            self._make_url("videos/" + video_id + "/results/" + result_video_id + "/preview"),
            data=content,
            headers={"Content-Type": "image/png"},
        )

    def upload_result_mp_kinematics(
        self, video_id: str, result_video_id: str, data: dict
    ):
        requests.post(
            self._make_url("videos/" + video_id + "/results/" + result_video_id + "/mp_kinematics/body"),
            json=data,
        )

    def upload_result_data(
        self, video_id: str, result_video_id: str, data_type: str, content
    ):
        if data_type == 'poses':
            requests.post(
                self._make_url("videos/" + video_id + "/results/" + result_video_id + "/data/" + data_type),
                json=content,
            )
        else:
            requests.post(
                self._make_url("videos/" + video_id + "/results/" + result_video_id + "/data/" + data_type),
                data=content,
                headers={"Content-Type": "application/octet-stream"},
            )

    def update_progress(self, job_id: str, progress: int):
        requests.post(
            self._make_url("jobs/" + job_id + "/progress"),
            json={"progress": progress},
        )

    def _make_url(self, path: str) -> str:
        return self._base_path + self._worker_id + "/" + path
