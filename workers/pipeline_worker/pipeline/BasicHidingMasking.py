from ast import List
import time
import cv2
import os
import json

from pipeline_worker.pipeline.PipelineTypes import DetectionResult, MaskingResult
from pipeline_worker.pipeline.detection.STTNMaskCreator import STTNMaskCreator
from pipeline_worker.pipeline.detection.STTNVideoInpainter import STTNVideoInpainter
from pipeline_worker.pipeline.detection.YoloDetector import YoloDetector
from pipeline_worker.pipeline.detection.MediaPipeDetector import MediaPipeDetector
from pipeline_worker.pipeline.mask_extraction.MediaPipeMaskExtractor import (
    MediaPipeMaskExtractor,
)
from pipeline_worker.pipeline.hiding import Hider

from pipeline_worker.utils.video_utils import setup_video_processing
from pipeline_worker.utils.drawing_utils import overlay_frames

from config import BLENDSHAPES_BASE_PATH, TS_BASE_PATH


class BasicHidingMasking:
    def __init__(
        self,
        inpainting_num_poses,
        required_detectors,
        required_maskers,
        hiding_strategies,
        params_3d,
        backend_client,
        masks_audio,
        creates_basic_video,
    ):
        self.detectors = self.init_detectors(required_detectors)
        self.mask_extractors = self.init_maskers(required_maskers, params_3d)
        self.hider = self.init_hider(hiding_strategies)

        self.is_inpainting = inpainting_num_poses != 0
        self.inpainting_num_poses = inpainting_num_poses

        self.blendshapes_file_handle = None
        self.is_first_blendshape_res = True
        self.ts_file_handlers = {}

        self.backend_client = backend_client
        self.progress_message_sent_time = None
        self.progress_update_interval = 5
        self.masks_audio = masks_audio
        self.creates_basic_video = creates_basic_video

    # required_detectors are of form: {"modelName": {"partToDetect": params, ...}, ...}
    def init_detectors(self, required_detectors: dict):
        detectors = []
        if "mediapipe" in required_detectors:
            parts_to_detect = required_detectors["mediapipe"]
            detectors.append(MediaPipeDetector(parts_to_detect))
        if "yolo" in required_detectors:
            parts_to_detect = required_detectors["yolo"]
            detectors.append(YoloDetector(parts_to_detect))
        return detectors

    def init_hider(self, hiding_strategies):
        return Hider(hiding_strategies)

    def init_maskers(self, required_maskers: dict, params_3d):
        mask_extractors = []
        if (
            "mediapipe" in required_maskers
            or params_3d["blendshapes"]
            or params_3d["skeleton"]
        ):
            if "mediapipe" in required_maskers:
                parts_to_mask = required_maskers["mediapipe"]
            else:
                parts_to_mask = []
            mask_extractors.append(MediaPipeMaskExtractor(parts_to_mask, params_3d))
        return mask_extractors

    def setup_inpainting(self, inpainting_num_poses, video_id, video_in_path):
        sttn_mask_creator = STTNMaskCreator()
        inpaint_mask_dir = sttn_mask_creator.run(video_id, inpainting_num_poses)

        sttn_video_inpainter = STTNVideoInpainter()
        inpainted_video_in_path = sttn_video_inpainter.run(
            video_in_path, inpaint_mask_dir
        )

        return cv2.VideoCapture(inpainted_video_in_path)

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
            if self.masks_audio:
                progress = int(progress / 2)
            self.backend_client.update_progress(job_id, progress)
            self.progress_message_sent_time = time.time()

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

    def write_blendshapes(self, blendshapes_dict):
        if blendshapes_dict:
            if not self.is_first_blendshape_res:
                self.blendshapes_file_handle.write(",")
            json_string = json.dumps(blendshapes_dict)
            self.blendshapes_file_handle.write(json_string)
            self.is_first_blendshape_res = False

    def run(self, video_in_path, video_out_path, job_id, video_id):
        video_cap, out = setup_video_processing(video_in_path, video_out_path)

        inpainted_video_in_cap = (
            self.setup_inpainting(self.inpainting_num_poses, video_id, video_in_path)
            if self.is_inpainting
            else None
        )

        self.num_frames = int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT))
        self.init_ts_file_handlers(video_id)
        self.init_blendshapes_file_handle(video_id)
        index = 0
        while True:
            ret, frame = video_cap.read()
            if not ret:
                break

            inpainted_frame = None
            if inpainted_video_in_cap is not None:
                _ret, inpainted_frame = inpainted_video_in_cap.read()

            frame_timestamp_ms = int(video_cap.get(cv2.CAP_PROP_POS_MSEC))
            if index != 0 and frame_timestamp_ms == 0:
                continue

            # Detect all relevant body/video parts (as pixelMasks)
            detection_results: List[DetectionResult] = []
            for detector in self.detectors:
                detection_result = detector.detect(frame, frame_timestamp_ms)

                detection_results.extend(detection_result)

            if inpainted_frame is not None:
                hidden_frame = inpainted_frame.copy()
            else:
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
                    mask_extractor.get_newest_timeseries(), index == 0
                )
                self.write_blendshapes(
                    mask_extractor.get_newest_blendshapes()
                )

            if self.creates_basic_video:
                out_frame = overlay_frames(hidden_frame, mask_results)
                out.write(out_frame)

            self.send_progress_update(job_id, index)
            index += 1

        self.close_ts_file_handles()
        self.close_bs_file_handle()
        out.release()
        video_cap.release()

        if inpainted_video_in_cap is not None:
            inpainted_video_in_cap.release()

        print(f"Finished basic_masking and hiding of video {video_id}")
