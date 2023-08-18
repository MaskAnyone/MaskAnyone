import os
import shutil
import time
from typing import List
from config import (
    BLENDSHAPES_BASE_PATH,
    RESULT_BASE_PATH,
    TS_BASE_PATH,
    VIDEOS_BASE_PATH,
)
import json
from backend_client import BackendClient
from pipeline.audio_masking.KeepAudioMasker import KeepAudioMasker
from pipeline.audio_masking.RVCAudioMasker import RVCAudioMasker
from pipeline.mask_extraction.MediaPipeMaskExtractor import MediaPipeMaskExtractor

from pipeline.detection.YoloDetector import YoloDetector
from pipeline.detection.MediaPipeDetector import MediaPipeDetector
from utils.drawing_utils import overlay_frames
from pipeline.hiding import Hider
from pipeline.PipelineTypes import (
    DetectionResult,
    HidingStategies,
    MaskingResult,
    Params3D,
    PartToDetect,
    PartToMask,
)
from utils.video_utils import setup_video_processing
from utils.app_utils import save_preview_image
from models.docker_maskers import docker_maskers as known_docker_mask_extractors

import cv2
import ffmpeg


class Pipeline:
    def __init__(self, run_params: dict, backend_client: BackendClient):
        self.backend_client = backend_client

        self.detectors = []
        self.mask_extractors = []
        self.docker_mask_extractors = {}
        self.audio_masker = None
        self.ts_file_handlers = {}

        self.model_3d_only = False
        self.blendshapes_file_handle = None

        self.num_frames = 0
        self.progress_message_sent_time = None
        self.progress_update_interval = 5  # in seconds

        (
            required_detectors,
            required_maskers,
            hiding_strategies,
        ) = self.identify_requried_models(run_params)
        params_3d: Params3D = run_params["threeDModelCreation"]
        voice_masking_strategy = run_params["voiceMasking"]["maskingStrategy"]

        self.init_detectors(required_detectors)
        self.init_maskers(required_maskers, params_3d)
        self.hider = Hider(hiding_strategies)
        self.init_audio_masker(
            voice_masking_strategy["key"], voice_masking_strategy["params"]
        )

    def identify_requried_models(self, run_params: dict):
        # extract arguments from request and create initialization arguments for maskers, detectors and hider
        hiding_strategies: HidingStategies = {}
        required_detectors = {}
        required_maskers = {}

        vid_masking_params = run_params["videoMasking"]
        print(vid_masking_params)
        for video_part in vid_masking_params:
            video_part_params = vid_masking_params[video_part]
            if (
                "hidingStrategy" in video_part_params
                and video_part_params["hidingStrategy"]["key"] != "none"
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

    def init_detectors(self, required_detectors: dict):
        if "mediapipe" in required_detectors:
            parts_to_detect = required_detectors["mediapipe"]
            self.detectors.append(MediaPipeDetector(parts_to_detect))
        if "yolo" in required_detectors:
            parts_to_detect = required_detectors["yolo"]
            self.detectors.append(YoloDetector(parts_to_detect))

    def init_maskers(self, required_maskers: dict, params_3d: Params3D):
        if not required_maskers and not self.detectors:
            self.model_3d_only = True
        if (
            "mediapipe" in required_maskers
            or params_3d["blendshapes"]
            or params_3d["skeleton"]
        ):
            if "mediapipe" in required_maskers:
                parts_to_mask = required_maskers["mediapipe"]
            else:
                parts_to_mask = []
            self.mask_extractors.append(
                MediaPipeMaskExtractor(parts_to_mask, params_3d)
            )

        for masker in required_maskers:
            if masker in known_docker_mask_extractors:
                self.docker_mask_extractors[masker] = required_maskers[masker]

    def init_audio_masker(self, audio_masker_name: str, params: dict):
        audio_maskers = {
            "remove": None,
            "preserve": KeepAudioMasker,
            "switch": RVCAudioMasker,
        }
        self.audio_masker = audio_maskers[audio_masker_name](params)

    def init_ts_file_handlers(self, video_id: str):
        for mask_extractor in self.mask_extractors:
            for part_to_mask in mask_extractor.parts_to_mask:
                if part_to_mask["save_timeseries"]:
                    file_path = os.path.join(
                        TS_BASE_PATH, f"{part_to_mask['part_name']}_{video_id}.json"
                    )
                    file_handle = open(file_path, "w+", newline="")
                    file_handle.write("[")
                    self.ts_file_handlers[part_to_mask["part_name"]] = file_handle

    def init_blendshapes_file_handle(self, video_id: str):
        file_path = os.path.join(BLENDSHAPES_BASE_PATH, f"{video_id}.json")
        file_handle = open(file_path, "w+", newline="")
        file_handle.write("[")
        self.blendshapes_file_handle = file_handle

    def write_timeseries(self, timeseries: dict, first: bool):
        for part_name in timeseries:
            file_handle = self.ts_file_handlers[part_name]
            if not first:
                file_handle.write(",")
            json_string = json.dumps(timeseries[part_name])
            file_handle.write(json_string)

    def close_ts_file_handles(self):
        for key in self.ts_file_handlers:
            self.ts_file_handlers[key].write("]")
            self.ts_file_handlers[key].close()

    def close_bs_file_handle(self):
        self.blendshapes_file_handle.write("]")
        self.blendshapes_file_handle.close()

    def write_blendshapes(self, blendshapes_dict, first):
        if blendshapes_dict:
            if not first:
                self.blendshapes_file_handle.write(",")
            json_string = json.dumps(blendshapes_dict)
            self.blendshapes_file_handle.write(json_string)

    def should_send_progress_message(self, index: int):
        if index == 0:
            return False

        if self.progress_message_sent_time is None:
            return True

        cur_time = time.time()
        elapsed_time = cur_time - self.progress_message_sent_time
        return elapsed_time > self.progress_update_interval

    def send_progress_update(self, job_id: str, current_index: int):
        if self.should_send_progress_message(current_index):
            progress = int((float(current_index) / float(self.num_frames)) * 100.0)
            if self.audio_masker:
                progress = int(progress / 2)
            self.backend_client.update_progress(job_id, progress)
            self.progress_message_sent_time = time.time()

    def masks_audio_only(self):
        return self.audio_masker and len(self.detectors) == 0

    def run(self, video_id: str, job_id: str):
        print(f"Running job on video {video_id}")
        video_in_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
        video_out_path = os.path.join(RESULT_BASE_PATH, video_id + ".mp4")

        if self.docker_mask_extractors:
            print(self.docker_mask_extractors)
            for mask_extractor in self.docker_mask_extractors:
                self.backend_client.create_job(
                    mask_extractor,
                    video_id,
                    self.docker_mask_extractors[mask_extractor][0]["params"],
                )

        video_cap, out = setup_video_processing(video_in_path, video_out_path)
        is_first_frame = True

        self.init_ts_file_handlers(video_id)
        self.init_blendshapes_file_handle(video_id)
        self.num_frames = int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT))
        index = 0

        while True:
            ret, frame = video_cap.read()
            if not ret:
                break

            frame_timestamp_ms = int(video_cap.get(cv2.CAP_PROP_POS_MSEC))
            if not is_first_frame and frame_timestamp_ms == 0:
                continue

            # Detect all relevant body/video parts (as pixelMasks)
            detection_results: List[DetectionResult] = []
            for detector in self.detectors:
                detection_result = detector.detect(frame, frame_timestamp_ms)

                detection_results.extend(detection_result)

            # applies the hiding method on each detected part of the frame and combines them into one frame
            hidden_frame = frame.copy()
            for detection_result in detection_results:
                hidden_frame = self.hider.hide_frame_part(
                    hidden_frame, detection_result
                )

            # Extracts the masks for each desired bodypart
            mask_results = []

            for mask_extractor in self.mask_extractors:
                masking_results: List[MaskingResult] = mask_extractor.extract_mask(
                    frame, frame_timestamp_ms
                )
                mask_results.extend([result["mask"] for result in masking_results])
                self.write_timeseries(
                    mask_extractor.get_newest_timeseries(), is_first_frame
                )
                self.write_blendshapes(
                    mask_extractor.get_newest_blendshapes(), is_first_frame
                )

            if not self.model_3d_only:
                out_frame = overlay_frames(hidden_frame, mask_results)
                out.write(out_frame)

            is_first_frame = False
            self.send_progress_update(job_id, index)
            index += 1

        self.close_ts_file_handles()
        self.close_bs_file_handle()
        out.release()
        video_cap.release()
        print(f"Finished video masking of {video_id}")

        if self.audio_masker:
            old_video_out_path = os.path.join(RESULT_BASE_PATH, video_id + "_old.mp4")
            os.rename(video_out_path, old_video_out_path)
            if self.masks_audio_only():  # no masking of video was performed
                shutil.copyfile(
                    os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4"),
                    old_video_out_path,
                )

            masked_audio_path = self.audio_masker.mask(video_id)
            input_video = ffmpeg.input(old_video_out_path)
            input_audio = ffmpeg.input(masked_audio_path)
            output = ffmpeg.output(input_video.video, input_audio.audio, video_out_path)

            ffmpeg.run(output, overwrite_output=True)
            print(f"Finished audio masking of {video_id}")

        print(f"Finished processing video {video_id}")

        if not self.model_3d_only:
            save_preview_image(video_out_path)
