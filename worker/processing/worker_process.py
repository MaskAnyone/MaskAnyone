import sys
import time
import cv2
import os
import traceback

from communication.backend_client import BackendClient
from communication.video_manager import VideoManager
from masking.media_pipe_pose_masker import MediaPipePoseMasker

class WorkerProcess:
    _backend_client: BackendClient
    _video_manager: VideoManager

    def __init__(self, backend_client: BackendClient, video_manager: VideoManager):
        self._backend_client = backend_client
        self._video_manager = video_manager

    def run(self):
        while True:
            print("Attempting to fetch next job.")
            sys.stdout.flush()

            job = self._fetch_job()

            if job is None:
                time.sleep(10)
                continue

            print("Found job with id " + job["id"], flush=True)
            self._process_job(job)

    def _fetch_job(self):
        try:
            return self._backend_client.fetch_next_job()
        except Exception as e:
            print("Error while fetching job, retrying.", flush=True)
            print(e, flush=True)
            return None

    def _process_job(self, job):
        try:
            self._video_manager.load_original_video(job["video_id"])

            self._run_media_pipe_pose_masker(job)
            self._video_manager.upload_result_video(job["video_id"], job["result_video_id"])

            self._generate_preview_image(self._video_manager.get_output_video_path(job["video_id"]))
            self._video_manager.upload_result_video_preview_image(job["video_id"], job["result_video_id"])

            self._video_manager.upload_result_mp_kinematics(job["video_id"], job["result_video_id"])

            self._backend_client.mark_job_as_finished(job["id"])
            print("Finished processing job with id " + job["id"], flush=True)
        except Exception as e:
            print("Error while processing job, marking as failed.", flush=True)
            stack_trace = traceback.format_exc()
            print("An exception occurred:", e, flush=True)
            print("Stack trace:", stack_trace, flush=True)
            self._backend_client.mark_job_as_failed(job["id"])

    def _run_media_pipe_pose_masker(self, job):
        media_pipe_pose_masker = MediaPipePoseMasker(
            self._video_manager.get_original_video_path(job["video_id"]),
            self._video_manager.get_output_video_path(job["video_id"])
        )

        media_pipe_pose_masker.mask(job['data']['videoMasking'])

    def _generate_preview_image(self, video_path: str) -> None:
        video_cap = cv2.VideoCapture(video_path)
        file_name = os.path.splitext(os.path.basename(video_path))[0] + ".png"
        preview_img_path = os.path.join(os.path.split(video_path)[0], file_name)
        num_frames = int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT))
        video_cap.set(cv2.CAP_PROP_POS_FRAMES, int(num_frames / 2))
        _, frame = video_cap.read()
        cv2.imwrite(preview_img_path, frame)
