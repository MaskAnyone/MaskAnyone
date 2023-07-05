from functools import reduce
from utils.drawing_utils import hider_reducer, overlay_frames
from utils.video_utils import setup_video_processing

import cv2


class Pipeline:
    def __init__(self, runParams: dict):
        # Detectors and Mask creators are stateful
        self.detectors = [] 
        self.mask_creators = []
        self.init_detectors(runParams)
        self.init_mask_creators(runParams)

    def init_detectors(self, runParams):
        pass

    def init_mask_creators(self, runParams):
        pass

    def run(self, video_path: str):
        video_cap, out = setup_video_processing(video_path)

        while True:
            ret, frame = video_cap.read()
            if not ret:
                break

            frame_timestamp_ms = int(video_cap.get(cv2.CAP_PROP_POS_MSEC))

            # Detect all relevant body/video parts (as pixelMasks)
            detection_results = [] # detectionResultObject = {type, mask} - depending on type result will be handled differently by hider
            for detector in self.detectors:
                detection_result = detector.detect(frame, frame_timestamp_ms)
                detection_results.append(*detection_result)

            # frame with all detected parts hidden respectively
            mergedDetectionResults = reduce(hider_reducer, detection_result)
            hiddenFrame = overlay_frames(frame, mergedDetectionResults)
           
            mask_results = []
            for mask_creator in self.mask_creators:
                mask_result = mask_creator.extract_mask(frame)
                mask_results.append(*mask_result)

            out_frame = overlay_frames(hiddenFrame, mask_results)
            out.write(out_frame)
        
        out.release()
        video_cap.release()