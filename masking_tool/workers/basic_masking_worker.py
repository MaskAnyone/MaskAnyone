import os
import uuid

from pipeline_worker.pipeline.Pipeline import Pipeline
from common.utils.runparams_utils import (
    produces_blendshapes,
    produces_kinematics,
    produces_out_vid,
    produces_out_audio,
)
from common.worker import Worker


def handle_job_basic_masking(job, backend_client, video_manager):
    video_id = job["video_id"]
    result_video_id = job["result_video_id"]

    masking_pipeline = Pipeline(backend_client, video_manager)
    masking_pipeline.run(
        video_id,
        job["id"],
        job["data"],
    )

    run_params = job["data"]
    if produces_out_vid(run_params):
        video_manager.upload_result_video(video_id, result_video_id)
        video_manager.upload_result_video_preview_image(video_id, result_video_id)
    if produces_kinematics(run_params):
        video_manager.upload_result_kinematics(video_id, result_video_id)
    if produces_blendshapes(run_params):
        video_manager.upload_result_blendshapes(video_id, result_video_id)
    if produces_out_audio(run_params):
        video_manager.upload_result_audio_file(video_id, result_video_id)


worker_id = str(uuid.uuid4())
worker_type = os.environ["WORKER_TYPE"]
worker = Worker(worker_type, worker_id, handle_job_basic_masking)
worker.run()  # runs loop waiting for jobs
