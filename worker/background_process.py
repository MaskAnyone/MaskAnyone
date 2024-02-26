import asyncio
import threading

from communication.backend_client import BackendClient

class BackgroundProcess:
    _backend_client: BackendClient

    def __init__(self, backend_client: BackendClient):
        self._backend_client = backend_client

    def start(self):
        thread = threading.Thread(target=self._run_loop_in_thread, daemon=True)
        thread.start()

    def _run_loop_in_thread(self):
        asyncio.run(self._run_background_process())

    async def _run_background_process(self):
        while True:
            self._backend_client.ping_backend()
            print("Pinged backend.")
            await asyncio.sleep(60)
