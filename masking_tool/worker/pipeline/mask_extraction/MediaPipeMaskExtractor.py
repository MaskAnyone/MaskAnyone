from typing import List
import numpy as np
from pipeline.mask_extraction.BaseMaskExtractor import BaseMaskExtractor
import os

import mediapipe as mp
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2

from pipeline.PipelineTypes import PartToMask

face_model_path = os.path.join("models", "face_landmarker.task")
pose_model_path = os.path.join("models", "pose_landmarker_heavy.task")


class MediaPipeMaskExtractor(BaseMaskExtractor):
    def __init__(self, parts_to_mask: List[PartToMask]):
        super().__init__(parts_to_mask)
        self.part_methods = {"body": self.mask_body, "face": self.mask_face}
        self.models = {}
        self.init_models()

    def init_models(self):
        BaseOptions = mp.tasks.BaseOptions
        VisionRunningMode = mp.tasks.vision.RunningMode
        FaceLandmarker = mp.tasks.vision.FaceLandmarker
        FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
        PoseLandmarker = mp.tasks.vision.PoseLandmarker
        PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions

        pose_options = PoseLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=pose_model_path),
            running_mode=VisionRunningMode.VIDEO,
            output_segmentation_masks=True,
            num_poses=2,
        )

        face_options = FaceLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=face_model_path),
            running_mode=VisionRunningMode.VIDEO,
            output_face_blendshapes=True,
            output_facial_transformation_matrixes=True,
            num_faces=2,
        )

        self.models["pose"] = PoseLandmarker.create_from_options(pose_options)
        self.models["faceMesh"] = FaceLandmarker.create_from_options(face_options)

    def mask_body(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        frame_mp = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
        pose_result = self.models["pose"].detect_for_video(frame_mp, timestamp_ms)
        pose_landmarks_list = pose_result.pose_landmarks
        output_image = np.zeros(
            (frame_mp.height, frame_mp.width, frame_mp.channels), dtype=np.uint8
        )
        for idx in range(len(pose_landmarks_list)):
            pose_landmarks = pose_landmarks_list[idx]

            pose_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            pose_landmarks_proto.landmark.extend(
                [
                    landmark_pb2.NormalizedLandmark(
                        x=landmark.x, y=landmark.y, z=landmark.z
                    )
                    for landmark in pose_landmarks
                ]
            )

            solutions.drawing_utils.draw_landmarks(
                output_image,
                pose_landmarks_proto,
                solutions.pose.POSE_CONNECTIONS,
                solutions.drawing_styles.get_default_pose_landmarks_style(),
            )

        return output_image

    def mask_face(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        face_part = self.parts_to_mask
        if face_part["masking_method"] == "skeleton":
            return self.mask_face_simple(frame, timestamp_ms)
        elif face_part["masking_method"] == "faceMesh":
            return self.mask_face_mash(frame, timestamp_ms)
        else:
            raise Exception("Invalid face masking method specified")

    def mask_face_simple(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pass

    def mask_face_detail(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pass
