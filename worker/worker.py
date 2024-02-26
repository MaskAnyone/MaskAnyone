import uuid

from communication.backend_client import BackendClient
from background_process import BackgroundProcess
from processing.worker_process import WorkerProcess


def main():
    worker_id = str(uuid.uuid4())
    backend_client = BackendClient(worker_id)

    initialize_worker(backend_client)

    try:
        worker_process = WorkerProcess(backend_client)
        worker_process.run()
    except Exception as e:
        print("Got error while running worker process, shutting down worker.")
        raise e

    print("Worker process terminated unexpectedly, shutting down worker.")
    raise Exception("Worker process terminated unexpectedly.")


def initialize_worker(backend_client: BackendClient) -> None:
    backend_client.register_worker()

    background_process = BackgroundProcess(backend_client)
    background_process.start()


if __name__ == "__main__":
    main()
