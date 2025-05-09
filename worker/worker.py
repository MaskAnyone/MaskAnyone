import uuid
import os

from communication.backend_client import BackendClient
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from communication.local_data_manager import LocalDataManager
from communication.video_manager import VideoManager
from background_process import BackgroundProcess
from processing.worker_process import WorkerProcess

WORKER_BACKEND_BASE_PATH = os.environ["WORKER_BACKEND_BASE_PATH"]
WORKER_SAM2_BASE_PATH = 'http://sam2:8000/sam2'
WORKER_OPENPOSE_BASE_PATH = 'http://openpose:8000/openpose'
WORKER_LOCAL_DATA_DIR = os.environ["WORKER_LOCAL_DATA_DIR"]


def main():
    worker_id = str(uuid.uuid4())
    print("Starting worker with id " + worker_id, flush=True)

    backend_client = BackendClient(worker_id, WORKER_BACKEND_BASE_PATH)
    sam2_client = Sam2Client(WORKER_SAM2_BASE_PATH)
    openpose_client = OpenposeClient(WORKER_OPENPOSE_BASE_PATH)
    video_manager = VideoManager(backend_client, LocalDataManager(WORKER_LOCAL_DATA_DIR))

    initialize_worker(backend_client)
    print("Worker initialized.", flush=True)

    try:
        worker_process = WorkerProcess(backend_client, sam2_client, openpose_client, video_manager)
        worker_process.run()
    except Exception as e:
        print("Got error while running worker process, shutting down worker.", flush=True)
        raise e

    print("Worker process terminated unexpectedly, shutting down worker.", flush=True)
    raise Exception("Worker process terminated unexpectedly.")


def initialize_worker(backend_client: BackendClient) -> None:
    backend_client.register_worker()

    background_process = BackgroundProcess(backend_client)
    background_process.start()


if __name__ == "__main__":
    main()
