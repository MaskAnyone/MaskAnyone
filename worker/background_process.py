import asyncio
import sys

from communication.backend_client import BackendClient

class BackgroundProcess:
    _backend_client: BackendClient

    def __init__(self, backend_client: BackendClient):
        self._backend_client = backend_client

    def start(self):
        asyncio.run(self._run_background_process())

    async def _run_background_process(self):
        while True:
            self._backend_client.ping_backend()
            sys.stdout.flush()
            await asyncio.sleep(60)
