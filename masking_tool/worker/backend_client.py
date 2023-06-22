import requests


class BackendClient:
    def fetch_next_job(self):
        response = requests.get('http://python:8000/jobs/next')
        return response.json()['job']
