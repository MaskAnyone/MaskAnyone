import os
from typing import List
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
from pipeline.mask_extraction.MediaPipeMaskExtractor import MediaPipeMaskExtractor

from pipeline.detection.YoloDetector import YoloDetector
from pipeline.detection.MediaPipeDetector import MediaPipeDetector
from utils.drawing_utils import overlay_frames
from pipeline.hiding import Hider
from pipeline.PipelineTypes import (
    DetectionResult,
    HidingStategies,
    PartToDetect,
    PartToMask,
)
from utils.video_utils import setup_video_processing
from utils.app_utils import save_preview_image

import cv2


class Pipeline:
    def __init__(self, run_params: dict):
        # Detectors and Mask creators are stateful
        self.detectors = []
        self.mask_extractors = []
        hiding_strategies: HidingStategies = {}

        required_detectors = {}
        required_maskers = {}

        # extract arguments from request and create initialization arguments for maskers, detectors and hider
        vid_masking_params = run_params["videoMasking"]
        for video_part in vid_masking_params:
            video_part_params = vid_masking_params[video_part]
            if (
                "hidingStrategy" in video_part_params
                and video_part_params["hidingStrategy"]["key"] != "none"
            ):
                hiding_params = video_part_params["hidingStrategy"]["params"]
                hiding_strategies[video_part] = {
                    "key": video_part_params["hidingStrategy"]["key"],
                    "params": hiding_params,
                }
                if (
                    "detectionModel" not in hiding_params
                    or "subjectDetection" not in hiding_params
                ):
                    raise Exception(
                        f"Detection Model/Detection Type not specified for hiding of {video_part}"
                    )

                detection_model_name = hiding_params["detectionModel"]
                detection_type = hiding_params["subjectDetection"]

                if not detection_model_name in required_detectors:
                    required_detectors[detection_model_name] = []

                part_to_detect: PartToDetect = {
                    "part_name": video_part,
                    "detection_type": detection_type
                    # could be extended with fine grained paramters for detection
                }
                required_detectors[detection_model_name].append(part_to_detect)

            print(video_part_params)
            if "maskingStrategy" in video_part_params:
                if (
                    "maskingStrategy" in video_part_params
                    and video_part_params["maskingStrategy"]["key"] != "none"
                ):
                    print("masking found")
                    masking_method = video_part_params["maskingStrategy"]["key"]
                    masking_params = video_part_params["maskingStrategy"]["params"]
                    masking_model_name = masking_params["maskingModel"]
                    if not masking_model_name in required_maskers:
                        required_maskers[masking_model_name] = []

                    part_to_mask: List[PartToMask] = {
                        "part_name": video_part,
                        "masking_method": masking_method,
                        "params": masking_params,
                    }
                    required_maskers[masking_model_name].append(part_to_mask)

        self.init_detectors(required_detectors)
        self.init_maskers(required_maskers)

        print("finished maskers init", required_maskers)

        self.hider = Hider(hiding_strategies)

    def init_detectors(self, required_detectors: dict):
        if "mediapipe" in required_detectors:
            params = required_detectors["mediapipe"]
            self.detectors.append(MediaPipeDetector(params))
        if "yolo" in required_detectors:
            params = required_detectors["yolo"]
            self.detectors.append(YoloDetector(params))

    def init_maskers(self, required_maskers: dict):
        if "mediapipe" in required_maskers:
            params = required_maskers["mediapipe"]
            self.mask_extractors.append(MediaPipeMaskExtractor(params))

    def run(self, video_id: str):
        print(f"Running job on video {video_id}")
        video_in_path = os.path.join(VIDEOS_BASE_PATH, video_id + ".mp4")
        video_out_path = os.path.join(RESULT_BASE_PATH, video_id + ".mp4")
        video_cap, out = setup_video_processing(video_in_path, video_out_path)
        is_first_frame = True

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
            hidden_frame = frame
            for detection_result in detection_results:
                hidden_frame = self.hider.hide_frame_part(
                    hidden_frame, detection_result
                )

            # Extracts the masks for each desired bodypart
            mask_results = (
                []
            )  # mask results have to be drawn on a black frame in order to be combined correctly
            for mask_extractor in self.mask_extractors:
                mask_result = mask_extractor.extract_mask(frame, frame_timestamp_ms)
                mask_results.extend(mask_result)

            out_frame = overlay_frames(hidden_frame, mask_results)
            out.write(out_frame)
            is_first_frame = False

        out.release()
        video_cap.release()
        print(f"Finished processing video {video_id}")

        save_preview_image(video_out_path)
