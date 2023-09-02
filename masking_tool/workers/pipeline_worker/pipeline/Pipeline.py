import os
import shutil
import time
import ffmpeg
from typing import List
from moviepy.editor import VideoFileClip

from config import (
    RESULT_BASE_PATH,
    VIDEOS_BASE_PATH,
    AVAILABLE_DOCKER_MODELS,
)

from common.backend_client import BackendClient
from common.video_manager import VideoManager
from pipeline_worker.pipeline.BasicHidingMasking import BasicHidingMasking
from pipeline_worker.pipeline.audio_masking.KeepAudioMasker import KeepAudioMasker
from pipeline_worker.pipeline.audio_masking.RVCAudioMasker import RVCAudioMasker

from pipeline_worker.pipeline.PipelineTypes import (
    HidingStategies,
    Params3D,
    PartToDetect,
    PartToMask,
)
from pipeline_worker.utils.video_utils import merge_results
from common.utils.app_utils import save_preview_image


class Pipeline:
    def __init__(
        self,
        backend_client: BackendClient,
        video_manager: VideoManager,
    ):
        self.backend_client = backend_client
        self.video_manager = video_manager

        self.creates_basic_video = False
        self.creates_docker_video = False
        self.masks_audio = False
        self.keeps_audio = False
        self.creates_3d_out = False
        self.creates_video_out = False
        self.is_inpainting = False

    def check_tasks(
        self,
        run_params: dict,
        basic_maskers: dict,
        docker_maskers,
        params_3d: Params3D,
    ):
        self.is_inpainting = (
            (run_params["videoMasking"]["body"]["hidingStrategy"]["key"] == "inpaint")
            if "body" in run_params["videoMasking"]
            else False
        )
        # ToDo check for if it has any hiding and if has a docker with output
        if basic_maskers or self.is_inpainting:
            self.creates_basic_video = True

        hiding_entries = [
            True
            for entry in run_params["videoMasking"]
            if run_params["videoMasking"][entry]["hidingStrategy"]["key"] != "none"
        ]

        if any(hiding_entries):
            self.creates_basic_video = True

        if docker_maskers:
            # ToDo check that not only file is produced
            self.creates_docker_video = True

        if run_params["voiceMasking"]["maskingStrategy"]["key"] == "preserve":
            self.keeps_audio = True

        if run_params["voiceMasking"]["maskingStrategy"]["key"] not in [
            "preserve",
            "remove",
            "none",
        ]:
            self.masks_audio = True

        if params_3d["blendshapes"] or params_3d["skeleton"]:
            self.creates_3d_out = True

        if self.creates_docker_video or self.creates_basic_video or self.masks_audio:
            self.creates_video_out = True

    def identify_required_models(self, run_params: dict):
        # extract arguments from request and create initialization arguments for maskers, detectors and hider
        hiding_strategies: HidingStategies = {}
        required_detectors = {}
        required_maskers = {}

        vid_masking_params = run_params["videoMasking"]
        for video_part in vid_masking_params:
            video_part_params = vid_masking_params[video_part]
            if (
                "hidingStrategy" in video_part_params
                and video_part_params["hidingStrategy"]["key"] != "none"
                and video_part_params["hidingStrategy"]["key"] != "inpaint"
            ):
                hiding_settings = video_part_params["hidingStrategy"]["params"]
                hiding_params = hiding_settings["hidingParams"]
                hiding_strategies[video_part] = {
                    "key": video_part_params["hidingStrategy"]["key"],
                    "params": hiding_params,
                }
                if (
                    "detectionModel" not in hiding_settings
                    or "subjectDetection" not in hiding_settings
                ):
                    raise Exception(
                        f"Detection Model/Detection Type not specified for hiding of {video_part}"
                    )
                detection_model_name = hiding_settings["detectionModel"]
                detection_type = hiding_settings["subjectDetection"]
                detection_params = hiding_settings["detectionParams"]

                if not detection_model_name in required_detectors:
                    required_detectors[detection_model_name] = []

                part_to_detect: PartToDetect = {
                    "part_name": video_part,
                    "detection_type": detection_type,
                    "detection_params": detection_params,
                }
                required_detectors[detection_model_name].append(part_to_detect)

            if "maskingStrategy" in video_part_params:
                if (
                    "maskingStrategy" in video_part_params
                    and video_part_params["maskingStrategy"]["key"] != "none"
                ):
                    masking_method = video_part_params["maskingStrategy"]["key"]
                    masking_params = video_part_params["maskingStrategy"]["params"]
                    masking_model_name = masking_params["maskingModel"]
                    if "timeseries" in masking_params:
                        save_timeseries = masking_params["timeseries"]
                    else:
                        save_timeseries = False

                    if not masking_model_name in required_maskers:
                        required_maskers[masking_model_name] = []

                    part_to_mask: List[PartToMask] = {
                        "part_name": video_part,
                        "masking_method": masking_method,
                        "params": masking_params,
                        "save_timeseries": save_timeseries,
                    }
                    required_maskers[masking_model_name].append(part_to_mask)

        return required_detectors, required_maskers, hiding_strategies

    def split_mask_extractors(self, required_maskers: dict, params_3d: Params3D):
        basic_mask_extractors = {}
        docker_mask_extractors = {}

        for masker in required_maskers:
            if masker in AVAILABLE_DOCKER_MODELS:
                docker_mask_extractors[masker] = required_maskers[masker]
            else:
                basic_mask_extractors[masker] = required_maskers[masker]

        # blender file extraction wanted but not video masking with blender selected
        if params_3d["blender"] and not "blender" in docker_mask_extractors:
            docker_mask_extractors["blender"] = [
                {
                    "part_name": "body",
                    "masking_method": "blender",
                    "params": params_3d["blenderParams"],
                    "save_timeseries": False,
                }
            ]

        return basic_mask_extractors, docker_mask_extractors

    def init_audio_masker(self, audio_masker_name: str, params: dict):
        audio_maskers = {
            "preserve": KeepAudioMasker,
            "switch": RVCAudioMasker,
        }

        if audio_masker_name == "remove":
            return None
        elif audio_masker_name not in audio_maskers:
            raise Exception(f"Unknown audio masking method {audio_masker_name}")
        return audio_maskers[audio_masker_name](params)

    def handle_docker_model_finished(
        self, job_id: str, original_video_path: str, video_out_path: str
    ):
        docker_res_path = self.video_manager.load_result_video(job_id)
        print("Loaded docker result video to local path", docker_res_path)
        if not self.creates_basic_video:
            # no basic hiding or masking
            print("copying file only")
            shutil.copyfile(docker_res_path, video_out_path)
        else:
            print("merging results")
            merge_results(original_video_path, docker_res_path, video_out_path)

    def requires_audio_processing(self):
        if self.masks_audio:
            return True
        if self.keeps_audio and (self.creates_basic_video or self.creates_docker_video):
            return True
        return False

    def init_basic_hiding_masking(
        self, run_params: dict, required_detectors, required_maskers, hiding_strategies
    ):
        params_3d: Params3D = run_params["threeDModelCreation"]

        inpaining_num_poses = (
            run_params["videoMasking"]["body"]["hidingStrategy"]["params"][
                "detectionParams"
            ]["numPoses"]
            if self.is_inpainting
            else 0
        )

        return BasicHidingMasking(
            inpaining_num_poses,
            required_detectors,
            required_maskers,
            hiding_strategies,
            params_3d,
            self.backend_client,
            self.masks_audio,
            self.creates_basic_video,
        )

    def run(self, video_id: str, job_id: str, run_params: dict):
        print(f"Running job on video {video_id}")

        video_in_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
        video_out_path = os.path.join(RESULT_BASE_PATH, video_id + ".mp4")

        # Identify required models for person detection, hiding and masking
        # Detection and hiding is only handled by the basic masker
        # Masking can be handled by the basic masker or a custom docker model
        (
            required_detectors,
            required_maskers,
            hiding_strategies,
        ) = self.identify_required_models(run_params)
        params_3d = run_params["threeDModelCreation"]
        basic_mask_extractors, docker_mask_extractors = self.split_mask_extractors(
            required_maskers, params_3d
        )
        self.check_tasks(
            run_params, basic_mask_extractors, docker_mask_extractors, params_3d
        )

        docker_job_id = None

        # Start custom docker model jobs
        # @ToDo currently only supports a single docker mask extracter, as it is unclear how to merge results
        if docker_mask_extractors:
            mask_extractor_name = list(docker_mask_extractors.keys())[0]
            mask_extractor = docker_mask_extractors[mask_extractor_name]
            docker_job_id = self.backend_client.create_job(
                mask_extractor_name,
                video_id,
                mask_extractor[0]["params"],
            )

        # Run basic inbuilt hiding/masking if applicable
        if self.creates_basic_video or self.creates_3d_out:
            basic_hiding_masking = self.init_basic_hiding_masking(
                run_params, required_detectors, basic_mask_extractors, hiding_strategies
            )
            print(f"Started basic masking of {video_id}")
            basic_hiding_masking.run(video_in_path, video_out_path, job_id, video_id)
            print(f"Finished basic masking of {video_id}")

        # Wait for custom docker model to finish
        if docker_mask_extractors:
            print(f"Waiting for sub job to complete for {video_id}")
            count = 0
            timeout_max = 2160  # 6hours
            job_status = self.backend_client.fetch_job_status(docker_job_id)
            while count < timeout_max:
                if job_status == "finished":
                    break
                if job_status == "failed":
                    raise Exception("Sub job failed to complete.")
                time.sleep(1)
                count = count + 1
                job_status = self.backend_client.fetch_job_status(docker_job_id)

            self.handle_docker_model_finished(
                docker_job_id, video_in_path, video_out_path
            )
            print("Handling of sub job finished")

        # will currently create a output video even for keep_audio as only param
        if self.requires_audio_processing():
            voice_masking_strategy = run_params["voiceMasking"]["maskingStrategy"]
            audio_masker = self.init_audio_masker(
                voice_masking_strategy["key"], voice_masking_strategy["params"]
            )

            if not self.creates_basic_video and not self.creates_docker_video:
                video_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
            else:
                video_path = os.path.join(RESULT_BASE_PATH, video_id + "_old.mp4")
                os.rename(video_out_path, video_path)

            masked_audio_path = audio_masker.mask(video_id)
            input_video = ffmpeg.input(video_path)
            input_audio = ffmpeg.input(masked_audio_path)
            output = ffmpeg.output(input_video.video, input_audio.audio, video_out_path)

            ffmpeg.run(output, overwrite_output=True)
            print(f"Finished audio masking of {video_id}")

        # if a docker model produces a result and audio should be removed
        if self.creates_docker_video and not self.requires_audio_processing():
            videoclip = VideoFileClip(video_out_path)
            new_clip = videoclip.without_audio()
            new_clip.write_videofile(video_out_path)

        print(f"Finished processing video {video_id}")

        if self.creates_video_out:
            save_preview_image(video_out_path)
