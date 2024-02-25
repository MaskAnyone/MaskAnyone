import uuid

from communication.backend_client import BackendClient

worker_id = str(uuid.uuid4())
backend_client = BackendClient(worker_id)
backend_client.register_worker()
