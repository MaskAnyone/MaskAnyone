import requests


class BackendClient:

    def fetch_next_job(self):
        response = requests.get('http://python:8000/jobs/next')
        return response.json()['job']


    def fetch_video(self, video_id: str):
        response = requests.get('http://python:8000/videos/' + video_id)
        return response.content
