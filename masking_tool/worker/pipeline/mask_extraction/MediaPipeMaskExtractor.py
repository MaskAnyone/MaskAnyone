from typing import List
import numpy as np
from utils.timeseries import create_header_mp, list_positions_mp
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
        self.timeseries = {"body": [], "face": []}
        self.ts_headers = {
            "body": create_header_mp("body"),
            "face": create_header_mp("face"),
        }
        self.init_models()

    def reorder_parts_to_mask(self):
        # Sets face to be processes last, so that if body result is available it can be used for simple face
        face_part = self.get_part_to_mask("face")
        if face_part:
            index = self.parts_to_detect.index(face_part)
            self.parts_to_detect.pop(index)
            self.parts_to_detect.append(face_part)

    def init_models(self):
        BaseOptions = mp.tasks.BaseOptions
        VisionRunningMode = mp.tasks.vision.RunningMode
        PoseLandmarker = mp.tasks.vision.PoseLandmarker
        PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions

        body_part = self.get_part_to_mask("body")
        face_part = self.get_part_to_mask("face")
        pose_params = None
        if body_part:
            pose_params = body_part["params"]
        elif face_part and face_part["masking_method"] == "skeleton":
            pose_params = face_part["params"]
        if pose_params:
            pose_options = PoseLandmarkerOptions(
                base_options=BaseOptions(model_asset_path=pose_model_path),
                running_mode=VisionRunningMode.VIDEO,
                output_segmentation_masks=False,
                num_poses=pose_params["numPoses"],
                min_pose_detection_confidence=pose_params["confidence"],
            )
            self.models["pose"] = PoseLandmarker.create_from_options(pose_options)

        if face_part and face_part["masking_method"] == "faceMesh":
            face_params = face_part["params"]
            FaceLandmarker = mp.tasks.vision.FaceLandmarker
            FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
            face_options = FaceLandmarkerOptions(
                base_options=BaseOptions(model_asset_path=face_model_path),
                running_mode=VisionRunningMode.VIDEO,
                output_face_blendshapes=True,
                output_facial_transformation_matrixes=True,
                num_faces=face_params["numPoses"],
                min_face_detection_confidence=face_params["confidence"],
            )
            self.models["faceMesh"] = FaceLandmarker.create_from_options(face_options)

    def compute_pose_landmarks(self, frame: np.ndarray, timestamp_ms: int):
        frame_mp = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
        pose_result = self.models["pose"].detect_for_video(frame_mp, timestamp_ms)
        return pose_result.pose_landmarks

    def is_face_required(self):
        return any(
            part["part_name"] == "face" and part["masking_method"] == "skeleton"
            for part in self.parts_to_mask
        )

    def mask_body(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pose_landmarks_list = self.compute_pose_landmarks(frame, timestamp_ms)
        if not self.is_face_required():
            landmarks_to_hide = [lms[:11] for lms in pose_landmarks_list]
            landmarks_to_hide = [lm for lms in landmarks_to_hide for lm in lms]
            for lm in landmarks_to_hide:
                lm.visibility = 0.0

        output_image = np.zeros(frame.shape, dtype=np.uint8)
        output_image = self.draw_pose_landmarks(output_image, pose_landmarks_list)

        self.timeseries["body"] = list_positions_mp(pose_landmarks_list)
        self.timeseries["body"].insert(0, timestamp_ms)

        return output_image

    def mask_face(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        face_part = self.get_part_to_mask("face")
        if face_part["masking_method"] == "skeleton":
            return self.mask_face_simple(frame, timestamp_ms)
        elif face_part["masking_method"] == "faceMesh":
            return self.mask_face_mesh(frame, timestamp_ms)
        else:
            raise Exception("Invalid face masking method specified")

    def mask_face_simple(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        body_result = self.get_part_to_mask("body")

        if body_result:
            return

        landmarks_to_hide = [lms[:11] for lms in body_result]
        landmarks_to_hide = [lm for lms in landmarks_to_hide for lm in lms]
        for lm in landmarks_to_hide:
            lm.visibility = 0.0

        output_image = np.zeros((frame.shape), dtype=np.uint8)
        output_image = self.draw_pose_landmarks(output_image, landmarks_to_hide)
        self.timeseries["body"] = list_positions_mp(body_result)
        self.timeseries["body"].insert(0, timestamp_ms)

        return output_image

    def compute_face_landmarks(self, frame: np.ndarray, timestamp_ms: int):
        frame_mp = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
        face_result = self.models["faceMesh"].detect_for_video(frame_mp, timestamp_ms)
        return face_result.face_landmarks

    def mask_face_mesh(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        face_landmarks_list = self.compute_face_landmarks(frame, timestamp_ms)

        output_image = np.zeros(frame.shape, dtype=np.uint8)
        output_image = self.draw_face_mesh_landmarks(output_image, face_landmarks_list)
        self.timeseries["face"] = list_positions_mp(face_landmarks_list)
        self.timeseries["face"].insert(0, timestamp_ms)
        return output_image

    def draw_pose_landmarks(self, output_image, pose_landmarks_list):
        for idx in range(len(pose_landmarks_list)):
            pose_landmarks = pose_landmarks_list[idx]

            pose_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            pose_landmarks_proto.landmark.extend(
                [
                    landmark_pb2.NormalizedLandmark(
                        x=landmark.x,
                        y=landmark.y,
                        z=landmark.z,
                        visibility=landmark.visibility,
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

    def draw_face_mesh_landmarks(self, output_image, face_landmarks_list):
        for idx in range(len(face_landmarks_list)):
            face_landmarks = face_landmarks_list[idx]

            face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            face_landmarks_proto.landmark.extend(
                [
                    landmark_pb2.NormalizedLandmark(
                        x=landmark.x,
                        y=landmark.y,
                        z=landmark.z,
                        visibility=landmark.visibility,
                    )
                    for landmark in face_landmarks
                ]
            )

            solutions.drawing_utils.draw_landmarks(
                image=output_image,
                landmark_list=face_landmarks_proto,
                connections=mp.solutions.face_mesh.FACEMESH_TESSELATION,
                landmark_drawing_spec=None,
                connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_tesselation_style(),
            )
            solutions.drawing_utils.draw_landmarks(
                image=output_image,
                landmark_list=face_landmarks_proto,
                connections=mp.solutions.face_mesh.FACEMESH_CONTOURS,
                landmark_drawing_spec=None,
                connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_contours_style(),
            )
            solutions.drawing_utils.draw_landmarks(
                image=output_image,
                landmark_list=face_landmarks_proto,
                connections=mp.solutions.face_mesh.FACEMESH_IRISES,
                landmark_drawing_spec=None,
                connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_iris_connections_style(),
            )
        return output_image
