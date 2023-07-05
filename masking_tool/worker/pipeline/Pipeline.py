import os
from typing import List
from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH
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

        # extract arguments from request and create initialization arguments for maskers, detectors and hider
        vid_masking_params = run_params["videoMasking"]
        for video_part in vid_masking_params:
            video_part_params = vid_masking_params[video_part]
            if "hidingStrategy" in video_part:
                hiding_strategies[video_part] = video_part_params["hidingStrategy"]["key"]
                hiding_params = video_part_params["hidingStrategy"]["params"]
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
            
            # @ToDo implement masking similar to detection/hiding
            """if "maskingStrategy" in video_part:
                masking_model_name = None
                masking_type = None
                masking_params = {}
                if not masking_model_name in required_maskers:
                    required_maskers[masking_model_name] = []
                
                parts_to_detect: List[PartToMask] = {
                    "part_name": video_part,
                    "masking_type": masking_type,
                    "params": masking_params
                    # could be extended with fine grained paramters for detection
                }
                required_maskers[masking_model_name] = parts_to_detect"""

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
        
    def run(self, video_id: str):
        print(f"Running job on video {video_id}")
        video_in_path = os.path.join(VIDEOS_BASE_PATH, video_id + '.mp4')
        video_out_path = os.path.join(RESULT_BASE_PATH, video_id + '.mp4')
        video_cap, out = setup_video_processing(video_in_path, video_out_path)

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

            print("Detection completed", detection_result)

            # applies the hiding method on each detected part of the frame and combines them into one frame
            hidden_frame = frame
            for detection_result in detection_result:
                hidden_frame = self.hider.hide(hidden_frame, detection_result)

            print("Masking completed", detection_result)

            # Extracts the masks for each desired bodypart
            mask_results = [] # mask results have to be drawn on a black frame in order to be combined correctly
            for mask_creator in self.mask_creators:
                mask_result = mask_creator.extract_mask(frame)
                mask_results.append(*mask_result)

            out_frame = overlay_frames(hidden_frame, mask_results)
            out.write(out_frame)
        
        out.release()
        video_cap.release()