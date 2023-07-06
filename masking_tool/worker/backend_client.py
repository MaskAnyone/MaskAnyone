import requests


class BackendClient:
    def fetch_next_job(self):
        response = requests.get("http://python:8000/jobs/next")
        return response.json()["job"]

    def fetch_video(self, video_id: str):
        response = requests.get("http://python:8000/videos/" + video_id)
        return response.content

    def mark_job_as_finished(self, job_id: str):
        requests.post("http://python:8000/jobs/" + job_id + "/finish")

    def upload_result_video(self, video_id: str, result_video_id: str, content):
        requests.post(
            "http://python:8000/videos/" + video_id + "/results/" + result_video_id,
            data=content,
            headers={"Content-Type": "application/octet-stream"},
        )

    def upload_result_video_preview_image(
        self, video_id: str, result_video_id: str, content
    ):
        requests.post(
            "http://python:8000/videos/"
            + video_id
            + "/results/"
            + result_video_id
            + "/preview",
            data=content,
            headers={"Content-Type": "image/png"},
        )
