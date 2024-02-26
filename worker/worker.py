import uuid
import asyncio
import sys

from communication.backend_client import BackendClient
from background_process import BackgroundProcess

worker_id = str(uuid.uuid4())
backend_client = BackendClient(worker_id)
backend_client.register_worker()

background_process = BackgroundProcess(backend_client)
background_process.start()
