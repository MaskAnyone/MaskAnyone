from typing import List
from pipeline.detection.YoloDetector import YoloDetector
from pipeline.detection.MediaPipeDetector import MediaPipeDetector
from utils.drawing_utils import overlay_frames
from pipeline.hiding import Hider, hide_frame_part
from pipeline.PipelineTypes import DetectionResult, HidingStategies, PartToDetect
from utils.video_utils import setup_video_processing

import cv2


class Pipeline:
    def __init__(self, run_params: dict):
        # Detectors and Mask creators are stateful
        self.detectors = []
        self.mask_extractors = []
        hiding_strategies: HidingStategies = {}

        required_detectors = {}
        required_maskers = {}

        # create initialization arguments for maskers, detectors and hider
        for video_part in run_params:
            video_part_params = run_params[video_part]
            if "hiding_strategy" in video_part:
                hiding_strategies[video_part] = video_part_params.hiding_strategy.key
                hiding_params = video_part_params.hiding_strategy.params
                if "detectionModel" not in hiding_params or "subjectDetection" not in hiding_params:
                    raise Exception(f"Detection Model/Detection Type not specified for hiding of {video_part}")
                
                detection_model_name = hiding_params["detectionModel"]
                detection_type = hiding_params["subjectDetection"]

                if not detection_model_name in required_detectors:
                    required_detectors[detection_model_name] = []
                
                parts_to_detect: List[PartToDetect] = {
                    "part_name": video_part,
                    "detection_type": detection_type
                    # could be extended with fine grained paramters for detection
                }
                required_detectors[detection_model_name] = parts_to_detect
            
            if "masking_strategy" in video_part:
                self.masking_strategies[video_part] = video_part_params.masking_strategy

        self.init_detectors(required_detectors)
        self.init_maskers(required_maskers)
        
        self.hider = Hider(hiding_strategies)

    def init_detectors(self, required_detectors: dict):
        if "mediapipe" in required_detectors:
            params = required_detectors["mediapipe"]
            self.detectors.append(MediaPipeDetector(params))
        if "yolo" in required_detectors:
            params = required_detectors["mediapipe"]
            self.detectors.append(YoloDetector(params))

    def init_maskers(required_maskers: dict):
        pass
        
    def run(self, video_path: str):
        video_cap, out = setup_video_processing(video_path)

        while True:
            ret, frame = video_cap.read()
            if not ret:
                break

            frame_timestamp_ms = int(video_cap.get(cv2.CAP_PROP_POS_MSEC))

            # Detect all relevant body/video parts (as pixelMasks)
            detection_results: List[DetectionResult] = []
            for detector in self.detectors:
                detection_result = detector.detect(frame, frame_timestamp_ms)
                detection_results.append(*detection_result)

            # applies the hiding method on each detected part of the frame and combines them into one frame
            hidden_frame = frame
            for detection_result in detection_result:
                hidden_frame = self.hider.hide(hidden_frame, detection_result)

            # Extracts the masks for each desired bodypart
            mask_results = [] # mask results have to be drawn on a black frame in order to be combined correctly
            for mask_creator in self.mask_creators:
                mask_result = mask_creator.extract_mask(frame)
                mask_results.append(*mask_result)

            out_frame = overlay_frames(hidden_frame, mask_results)
            out.write(out_frame)
        
        out.release()
        video_cap.release()