
from communication.backend_client import BackendClient

class WorkerProcess:
    _backend_client: BackendClient

    def __init__(self, backend_client: BackendClient):
        self._backend_client = backend_client

    def run(self):
        pass
