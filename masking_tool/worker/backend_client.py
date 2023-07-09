import requests
from enum import Enum


BASE_PATH = 'http://python:8000/worker/'


class MpKinematicsType(str, Enum):
    body = "body"
    face = "face"


class BackendClient:
    def fetch_next_job(self):
        response = requests.get(self._make_url('jobs/next'))
        return response.json()['job']

    def fetch_video(self, video_id: str):
        response = requests.get(self._make_url('videos/' + video_id))
        return response.content

    def mark_job_as_finished(self, job_id: str):
        requests.post(self._make_url('jobs/' + job_id + '/finish'))

    def mark_job_as_failed(self, job_id: str):
        requests.post(self._make_url('jobs/' + job_id + '/fail'))

    def upload_result_video(self, video_id: str, result_video_id: str, content):
        requests.post(
            self._make_url('videos/' + video_id + '/results/' + result_video_id),
            data=content,
            headers={'Content-Type': 'application/octet-stream'},
        )

    def upload_result_video_preview_image(
        self, video_id: str, result_video_id: str, content
    ):
        requests.post(
            self._make_url('videos/' + video_id + '/results/' + result_video_id + '/preview'),
            data=content,
            headers={'Content-Type': 'image/png'},
        )

    def upload_result_mp_kinematics(
        self, video_id: str, result_video_id: str, data: dict, type: MpKinematicsType
    ):
        requests.post(
            self._make_url('videos/' + video_id + '/results/' + result_video_id + '/mp_kinematics/' + type),
            json=data
        )

    def upload_result_blendshapes(
        self, video_id: str, result_video_id: str, data: dict
    ):
        requests.post(
            self._make_url('videos/' + video_id + '/results/' + result_video_id + '/blendshapes'),
            json=data
        )

    def _make_url(self, path: str) -> str:
        return BASE_PATH + path
