import uuid

from communication.backend_client import BackendClient
from background_process import BackgroundProcess


def main():
    worker_id = str(uuid.uuid4())
    backend_client = BackendClient(worker_id)

    initialize_worker(backend_client)


def initialize_worker(backend_client: BackendClient) -> None:
    backend_client.register_worker()

    background_process = BackgroundProcess(backend_client)
    background_process.start()


if __name__ == "__main__":
    main()
