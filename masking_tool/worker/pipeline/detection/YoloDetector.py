import os
from typing import List
import numpy as np
import cv2
from utils.drawing_utils import draw_rectangle, overlay_segmask, yolo_draw_segmask
from pipeline.PipelineTypes import PartToDetect
from pipeline.detection.BaseDetector import BaseDetector

from ultralytics import YOLO

# @ToDo unifify models into one model with different classes?
body_bbox_model_path = os.path.join("models", "yolov8n.pt")
face_bbox_model_path = os.path.join("models", "yolov8n-face.pt")
seg_model_path = os.path.join("models", "yolov8n-seg.pt")


class YoloDetector(BaseDetector):
    def __init__(self, parts_to_detect: List[PartToDetect]):
        super().__init__(parts_to_detect)
        self.reorder_parts_to_detect()
        self.silhouette_methods = {
            "body": self.detect_body_silhouette,
            "face": self.detect_face_silhouette,
            "background": self.detect_background_silhouette,
        }
        self.boundingbox_methods = {
            "body": self.detect_body_bbox,
            "face": self.detect_face_bbox,
            "background": self.detect_background_bbox,
        }
        self.models = {}
        self.init_model()

    def reorder_parts_to_detect(self) -> List[PartToDetect]:
        background_part = self.get_part_to_detect("background")
        if background_part:
            index = self.parts_to_detect.index(background_part)
            self.parts_to_detect.pop(index)
            self.parts_to_detect.append(background_part)

    def init_model(self):
        self.models["body"] = YOLO(body_bbox_model_path)
        if any(
            [
                True
                for part in self.parts_to_detect
                if part["detection_type"] == "silhouette"
            ]
        ):
            # detection_params = self.get_part_to_detect("body")["detection_params"]
            # @ToDo use custom detection_params
            self.models["silhouette"] = YOLO(seg_model_path)
        if any([True for part in self.parts_to_detect if part["part_name"] == "face"]):
            # detection_params = self.get_part_to_detect("face")["detection_params"]
            # @ToDo use custom detection_params
            self.models["face"] = YOLO(face_bbox_model_path)

    def detect_body_bbox(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        # Returns the segmentation mask for the body [black / white]
        results = self.models["body"].predict(frame, classes=[0])
        output_image = np.zeros((frame.shape))
        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = [int(val) for val in box.xyxy[0].tolist()]
                output_image = draw_rectangle(output_image, x1, y1, x2, y2, 1)
        return output_image

    def detect_face_bbox(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        # Returns the segmentation mask for the body [black / white]
        results = self.models["face"].predict(frame)
        output_image = np.zeros((frame.shape))
        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = [int(val) for val in box.xyxy[0].tolist()]
                output_image = draw_rectangle(output_image, x1, y1, x2, y2, 1)
        return output_image

    def detect_body_silhouette(
        self, frame: np.ndarray, timestamp_ms: int
    ) -> np.ndarray:
        results = self.models["silhouette"].predict(frame)
        output_image = np.zeros((frame.shape))
        if not results:
            return output_image
        for r in results:
            masks = r.masks.masks
            if masks is not None:
                masks = masks.data.cpu()
                h, w, _ = frame.shape
                for seg in masks.data.cpu().numpy():
                    seg = cv2.resize(seg, (w, h))
                    output_image = overlay_segmask(output_image, seg, 1, 0.4)
        return output_image

    def detect_face_silhouette(
        self, frame: np.ndarray, timestamp_ms: int
    ) -> np.ndarray:
        # Returns the segmentation mask for the body [black / white]
        results_face = self.models["face"].predict(frame)
        results_seg = self.models["silhouette"].predict(frame)

        combined_masks = np.zeros((frame.shape))
        h, w, _ = frame.shape
        if results_seg:
            for r in results_seg:
                masks = r.masks.masks
                if masks is not None:
                    masks = masks.data.cpu()
                    for seg in masks.data.cpu().numpy():
                        seg = cv2.resize(seg, (w, h))
                        combined_masks = overlay_segmask(combined_masks, seg, 1, 0.4)

        face_mask = np.zeros((frame.shape))
        if results_face:
            for result in results_face:
                for box in result.boxes:
                    x1, y1, x2, y2 = [int(val) for val in box.xyxy[0].tolist()]
                    face_mask = draw_rectangle(face_mask, x1, y1, x2, y2, 1)
        combined_masks[face_mask != 1] = 0

        return combined_masks

    def detect_background_silhouette(
        self, frame: np.ndarray, timestamp_ms: int
    ) -> np.ndarray:
        # Returns the segmentation mask for the background [black / white]
        person_silhouette_result = self.get_part_to_detect("body")
        if person_silhouette_result:
            mask = person_silhouette_result["mask"]
        else:
            mask = self.detect_body_silhouette(frame, timestamp_ms)
        return ~mask

    def detect_background_bbox(
        self, frame: np.ndarray, timestamp_ms: int
    ) -> np.ndarray:
        pass
