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

    def _make_url(self, path: str) -> str:
        print(BASE_PATH, path)
        return BASE_PATH + self._worker_id + "/" + path
