import sys
import time
import cv2
import os
import gc
import ctypes
import tempfile
import traceback

from communication.backend_client import BackendClient

try:
    _libc = ctypes.CDLL("libc.so.6")
    _malloc_trim = _libc.malloc_trim
except (OSError, AttributeError):
    _malloc_trim = None


def _release_memory_to_os() -> None:
    # Python's gc frees objects but glibc retains them in per-arena pools;
    # malloc_trim(0) hands unused pages back to the OS so RSS actually drops
    # between jobs instead of ratcheting up to VmPeak.
    gc.collect()
    if _malloc_trim is not None:
        _malloc_trim(0)
from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from communication.rtmpose_client import RtmposeClient
from communication.video_manager import VideoManager
from masking.media_pipe_pose_masker import MediaPipePoseMasker
from masking.sam2_pose_masker import Sam2PoseMasker
from masking.ffmpeg_converter import FFmpegConverter
from masking.mcadams_anonymizer import mcadams_anonymize
from masking.exceptions import JobCancelled

SLEEP_INTERVAL = 5

class WorkerProcess:
    _backend_client: BackendClient
    _sam2_client: Sam2Client
    _openpose_client: OpenposeClient
    _rtmpose_client: RtmposeClient
    _video_manager: VideoManager
    _last_api_call_time: int

    def __init__(
            self,
            backend_client: BackendClient,
            sam2_client: Sam2Client,
            openpose_client: OpenposeClient,
            rtmpose_client: RtmposeClient,
            video_manager: VideoManager,
    ):
        self._backend_client = backend_client
        self._sam2_client = sam2_client
        self._openpose_client = openpose_client
        self._rtmpose_client = rtmpose_client
        self._video_manager = video_manager

    def run(self):
        while True:
            print("Attempting to fetch next job.")
            sys.stdout.flush()

            job = self._fetch_job()

            if job is None:
                time.sleep(SLEEP_INTERVAL)
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

            if job['type'] == 'basic_masking':
                self._run_media_pipe_pose_masker(job)
            elif job['type'] == 'sam2_masking':
                self._run_sam2_masking(job)
            else:
                raise Exception(f'Unknown job type, got {job["type"]}')

            self._convert_to_h264_codec_and_apply_audio(job)

            self._video_manager.upload_result_video(job["video_id"], job["result_video_id"])

            self._generate_preview_image(self._video_manager.get_output_video_path(job["video_id"]))
            self._video_manager.upload_result_video_preview_image(job["video_id"], job["result_video_id"])

            # @todo fix this
            if job['type'] == 'basic_masking':
                self._video_manager.upload_result_mp_kinematics(job["video_id"], job["result_video_id"])

            if job['type'] == 'sam2_masking':
                self._video_manager.upload_result_data(job["video_id"], job["result_video_id"], 'sam2_masks')
                self._video_manager.upload_result_data(job["video_id"], job["result_video_id"], 'poses')
                self._video_manager.upload_result_data(job["video_id"], job["result_video_id"], 'qa')

            self._backend_client.mark_job_as_finished(job["id"])
            print("Finished processing job with id " + job["id"], flush=True)
        except JobCancelled:
            # The cancel endpoint already set status='cancelled' in the DB — do NOT
            # mark as failed. Just log and move on to the next job.
            print("Job " + job["id"] + " was cancelled by the user. Unwinding cleanly.", flush=True)
        except Exception as e:
            print("Error while processing job, marking as failed.", flush=True)
            stack_trace = traceback.format_exc()
            print("An exception occurred:", e, flush=True)
            print("Stack trace:", stack_trace, flush=True)
            self._backend_client.mark_job_as_failed(job["id"])
        finally:
            _release_memory_to_os()

    def _run_media_pipe_pose_masker(self, job):
        self._last_api_call_time = 0

        def progress_callback(progress: int, phase: str | None = None) -> None:
            self._report_masker_progress(job, progress, phase)

        media_pipe_pose_masker = MediaPipePoseMasker(
            self._video_manager.get_original_video_path(job["video_id"]),
            self._video_manager.get_output_video_path(job["video_id"]),
            progress_callback
        )

        media_pipe_pose_masker.mask(job['data']['videoMasking'])

    def _run_sam2_masking(self, job):
        self._last_api_call_time = 0
        self._last_cancel_check_time = 0
        self._cached_cancel_status = False

        def progress_callback(progress: int, phase: str | None = None) -> None:
            self._report_masker_progress(job, progress, phase)

        def is_cancelled() -> bool:
            # Rate-limit status polls to every 2s to avoid hammering the backend.
            # Return the cached decision in between polls.
            current = time.time()
            if current - self._last_cancel_check_time >= 2:
                self._last_cancel_check_time = current
                status = self._backend_client.get_job_status(job["id"])
                self._cached_cancel_status = (status == "cancelled")
            return self._cached_cancel_status

        sam2_pose_masker = Sam2PoseMasker(
            self._sam2_client,
            self._openpose_client,
            self._rtmpose_client,
            self._video_manager.get_original_video_path(job["video_id"]),
            self._video_manager.get_output_video_path(job["video_id"]),
            self._video_manager.get_result_data_path(job["video_id"], 'sam2_masks'),
            self._video_manager.get_result_data_path(job["video_id"], 'poses'),
            progress_callback,
            is_cancelled_callback=is_cancelled,
            qa_path=self._video_manager.get_result_data_path(job["video_id"], 'qa'),
        )

        sam2_pose_masker.mask(job['data']['videoMasking'])

    def _convert_to_h264_codec_and_apply_audio(self, job):
        ffmpeg_converter = FFmpegConverter()
        output_path = self._video_manager.get_output_video_path(job["video_id"])
        original_path = self._video_manager.get_original_video_path(job["video_id"])
        voice_masking = job['data'].get('voiceMasking', {}) or {}
        strategy = voice_masking.get('strategy', 'preserve')
        output_fps = self._read_output_fps(job)

        if strategy == 'preserve':
            ffmpeg_converter.convert_video_with_audio_in_place(output_path, original_path, output_fps=output_fps)
        elif strategy == 'switch':
            self._apply_mcadams_audio(ffmpeg_converter, output_path, original_path, voice_masking, output_fps=output_fps)
        else:
            # 'remove' (or any unknown strategy) — strip audio.
            ffmpeg_converter.convert_video_in_place(output_path, output_fps=output_fps)

    @staticmethod
    def _read_output_fps(job) -> float | None:
        """Parse videoMasking.outputFps. None means preserve source fps."""
        video_masking = job['data'].get('videoMasking', {}) or {}
        raw = video_masking.get('outputFps')
        if raw is None:
            return None
        try:
            fps = float(raw)
        except (TypeError, ValueError):
            return None
        return fps if fps > 0 else None

    def _apply_mcadams_audio(self, ffmpeg_converter, output_path, original_path, voice_masking, output_fps: float | None = None):
        """Extract original audio, run McAdams anonymisation, mux back into the masked video.

        Audio anonymisation must never block the job: any failure (no audio
        track, ffmpeg error, McAdams crash) falls back to removing audio so
        the result still ships and privacy is preserved.
        """
        with tempfile.TemporaryDirectory(prefix='mcadams_') as tmp:
            wav_in = os.path.join(tmp, 'in.wav')
            wav_out = os.path.join(tmp, 'out.wav')

            if not ffmpeg_converter.extract_audio_to_wav(original_path, wav_in):
                print('[voice_masking] no audio track to anonymise; falling back to remove', flush=True)
                ffmpeg_converter.convert_video_in_place(output_path, output_fps=output_fps)
                return

            params = (voice_masking.get('params') or {})
            try:
                alpha = float(params.get('alpha', 0.8))
            except (TypeError, ValueError):
                alpha = 0.8

            try:
                mcadams_anonymize(wav_in, wav_out, alpha=alpha)
            except Exception as e:
                print(f'[voice_masking] McAdams failed ({e}); falling back to remove', flush=True)
                ffmpeg_converter.convert_video_in_place(output_path, output_fps=output_fps)
                return

            ffmpeg_converter.replace_audio_in_place(output_path, wav_out, output_fps=output_fps)

    def _report_masker_progress(self, job, progress: int, phase: str | None = None) -> None:
        current_time = time.time()
        # Phase transitions bypass the 3s rate-limit — they're rare and worth surfacing
        # to the UI immediately.
        if phase is not None or current_time - self._last_api_call_time >= 3:
            self._last_api_call_time = current_time
            self._backend_client.update_progress(job["id"], progress, phase)

    def _generate_preview_image(self, video_path: str) -> None:
        video_cap = cv2.VideoCapture(video_path)
        file_name = os.path.splitext(os.path.basename(video_path))[0] + ".png"
        preview_img_path = os.path.join(os.path.split(video_path)[0], file_name)
        num_frames = int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT))
        video_cap.set(cv2.CAP_PROP_POS_FRAMES, int(num_frames / 2))
        _, frame = video_cap.read()
        cv2.imwrite(preview_img_path, frame)
