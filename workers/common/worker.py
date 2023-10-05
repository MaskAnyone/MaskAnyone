from common.backend_client import BackendClient
from common.local_data_manager import LocalDataManager
from config import DATA_BASE_DIR
from common.video_manager import VideoManager
import time
import sys
from common.utils.app_utils import clear_dirs, init_directories


class Worker:
    def __init__(self, worker_type, worker_id, job_handler):
        self.worker_type = worker_type
        self.worker_id = worker_id
        self.job_handler = job_handler
        self.backend_client = BackendClient(worker_id)
        
        retry_timeout = 60  # in seconds
        start_time = time.time()
        while True:
            try:
                self.backend_client.register_worker(worker_type)
                break
            except Exception as e:
                if time.time() - start_time >= retry_timeout:
                    raise e 
                print(f"Failed to register worker. Retrying in 1 second. Error: {str(e)}")
                time.sleep(1)

        self.video_manager = VideoManager(
            self.backend_client, LocalDataManager(DATA_BASE_DIR)
        )

        init_directories()

    def fetch_next_job(self):
        try:
            print(self.worker_type)
            return self.backend_client.fetch_next_job(self.worker_type)
        except Exception as error:
            print("Error while fetching next job")
            print(error)

        return None

    def handle_job(self, job):
        print("Start working on job " + job["id"])
        clear_dirs()

        self.video_manager.load_original_video(job["video_id"])
        self.job_handler(job, self.backend_client, self.video_manager)

    def run(self):
        while True:
            job = self.fetch_next_job()

            if job is None:
                print("No suitable job found")
            else:
                try:
                    self.handle_job(job)
                    self.backend_client.mark_job_as_finished(job["id"])
                except Exception as error:
                    print("Handling job with id " + job["id"] + " failed")
                    print(error)
                    self.backend_client.mark_job_as_failed(job["id"])

            sys.stdout.flush()  # Flush log output
            time.sleep(10)  #
