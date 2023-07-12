from typing import List
import numpy as np
from utils.timeseries import create_header_mp, list_positions_mp
from pipeline.mask_extraction.BaseMaskExtractor import BaseMaskExtractor
import os

import mediapipe as mp
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2

from pipeline.PipelineTypes import Params3D, PartToMask

face_model_path = os.path.join("models", "face_landmarker.task")
pose_model_path = os.path.join("models", "pose_landmarker_heavy.task")
hand_model_path = os.path.join("models", "hand_landmarker.task")


class MediaPipeMaskExtractor(BaseMaskExtractor):
    def __init__(self, parts_to_mask: List[PartToMask], params_3d: Params3D):
        super().__init__(parts_to_mask)
        self.params_3d = params_3d
        self.part_methods = {"body": self.mask_body, "face": self.mask_face}
        self.models = {}
        self.timeseries = {}
        self.current_blendshapes = []
        self.ts_headers = {
            "body": create_header_mp("body"),
            "face": create_header_mp("face"),
        }
        self.model_3d_only_parts = []
        self.handle_3d_options()
        self.init_models()

    def handle_3d_options(self):
        if self.params_3d["skeleton"] and not self.get_part_to_mask("body"):
            self.model_3d_only_parts.append("body")
            self.parts_to_mask.append(
                {
                    "part_name": "body",
                    "save_timeseries": "true",
                    "params": {"numPoses": 1, "confidence": 0.5},
                    "masking_method": "skeleton",
                }
            )
        elif self.params_3d["skeleton"] and self.get_part_to_mask("body"):
            body_part = self.get_part_to_mask("body")
            body_part["save_timeseries"] = True

        if self.params_3d["blendshapes"] and not self.get_part_to_mask("face"):
            self.model_3d_only_parts.append("body")
            self.parts_to_mask.append(
                {
                    "part_name": "face",
                    "save_timeseries": "true",
                    "params": {"numPoses": 1, "confidence": 0.5},
                    "masking_method": "faceMesh",
                }
            )
        elif self.params_3d["blendshapes"] and self.get_part_to_mask("face"):
            body_part = self.get_part_to_mask("body")
            if body_part["masking_method"] != "faceMesh":
                self.parts_to_mask.append(
                    {
                        "part_name": "face",
                        "save_timeseries": "true",
                        "params": {"numPoses": 1, "confidence": 0.5},
                        "masking_method": "faceMesh",
                    }
                )

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
        HandLandmarker = mp.tasks.vision.HandLandmarker
        HandLandmarkerOptions = mp.tasks.vision.HandLandmarkerOptions

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
            hand_options = HandLandmarkerOptions(
                base_options=BaseOptions(model_asset_path=hand_model_path),
                running_mode=VisionRunningMode.VIDEO,
            )
            self.models["pose"] = PoseLandmarker.create_from_options(pose_options)
            self.models["hand"] = HandLandmarker.create_from_options(hand_options)

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

    def compute_hand_landmarks(self, frame: np.ndarray, timestamp_ms: int):
        frame_mp = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
        hand_result = self.models["hand"].detect_for_video(frame_mp, timestamp_ms)
        return hand_result.hand_landmarks

    def hide_pose_hand_landmarks(self, pose_landmarks_list):
        pose_hand_lm_indixes = [17, 18, 19, 20, 21, 22]
        for lms in pose_landmarks_list:
            for hand_lm_index in pose_hand_lm_indixes:
                lms[hand_lm_index].visibility = 0.0

    def hide_pose_face_landmarks(self, pose_landmarks_list):
        landmarks_to_hide = [lms[:11] for lms in pose_landmarks_list]
        landmarks_to_hide = [lm for lms in landmarks_to_hide for lm in lms]
        for lm in landmarks_to_hide:
            lm.visibility = 0.0

    def mask_body(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        pose_landmarks_list = self.compute_pose_landmarks(frame, timestamp_ms)
        hand_landmark_list = self.compute_hand_landmarks(frame, timestamp_ms)

        # Hide hand points from pose, since if already have the detailed ones
        if hand_landmark_list:
            self.hide_pose_hand_landmarks(pose_landmarks_list)

        # Hide facial points from pose if face masking is none or mesh
        if not self.is_face_required():
            self.hide_pose_face_landmarks(pose_landmarks_list)

        if self.get_part_to_mask("body")["save_timeseries"]:
            self.store_ts(
                "body", pose_landmarks_list + hand_landmark_list, timestamp_ms
            )

        # only draw an output frame, if we require an output video and do not
        # just want to extract a 3d model
        if not "body" in self.model_3d_only_parts:
            output_image = np.zeros(frame.shape, dtype=np.uint8)
            output_image = self.draw_pose_landmarks(output_image, pose_landmarks_list)
            output_image = self.draw_hand_landmarks(output_image, hand_landmark_list)
            return output_image
        return

    def mask_face(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        face_part = self.get_part_to_mask("face")
        if face_part["masking_method"] == "skeleton":
            return self.mask_face_skeleton(frame, timestamp_ms)
        elif face_part["masking_method"] == "faceMesh":
            return self.mask_face_mesh(frame, timestamp_ms)
        else:
            raise Exception("Invalid face masking method specified")

    def mask_face_skeleton(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        body_result = self.get_part_to_mask("body")

        # if landmarks of body pose were already included this includes the facial points already
        if body_result:
            return

        body_result = self.compute_pose_landmarks(frame, timestamp_ms)
        self.hide_pose_face_landmarks(body_result)

        output_image = np.zeros((frame.shape), dtype=np.uint8)
        output_image = self.draw_pose_landmarks(output_image, body_result)
        return output_image

    def compute_face_results(self, frame: np.ndarray, timestamp_ms: int):
        frame_mp = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
        face_result = self.models["faceMesh"].detect_for_video(frame_mp, timestamp_ms)
        return face_result

    def store_blendshapes(self, blendshapes, transformation_matrixes):
        # @ToDo currently only supporting one detected person
        if not blendshapes:
            self.current_blendshapes = {}
            return
        processed_blendshapes = {
            entry.category_name: entry.score for entry in blendshapes[0]
        }
        processed_matrices = transformation_matrixes[0].flatten("F").tolist()
        self.current_blendshapes = {
            "blendshapes": processed_blendshapes,
            "transformationMatrices": processed_matrices,
        }

    def mask_face_mesh(self, frame: np.ndarray, timestamp_ms: int) -> np.ndarray:
        face_results = self.compute_face_results(frame, timestamp_ms)
        face_landmarks_list = face_results.face_landmarks
        if self.get_part_to_mask("face")["save_timeseries"] == True:
            self.store_ts("face", face_landmarks_list, timestamp_ms)
        if self.params_3d["blendshapes"]:
            self.store_blendshapes(
                face_results.face_blendshapes,
                face_results.facial_transformation_matrixes,
            )

        if not "face" in self.model_3d_only_parts:
            output_image = np.zeros(frame.shape, dtype=np.uint8)
            output_image = self.draw_face_mesh_landmarks(
                output_image, face_landmarks_list
            )
            return output_image
        return

    def store_ts(self, video_part, landmarks, timestamp_ms):
        self.timeseries[video_part] = list_positions_mp(
            landmarks, video_part, timestamp_ms
        )

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
                        visibility=0 if landmark.visibility == 0 else 1,
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

    def draw_hand_landmarks(self, output_image, hand_landmarks_list):
        for idx in range(len(hand_landmarks_list)):
            hand_landmarks = hand_landmarks_list[idx]

            hand_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
            hand_landmarks_proto.landmark.extend(
                [
                    landmark_pb2.NormalizedLandmark(
                        x=landmark.x, y=landmark.y, z=landmark.z
                    )
                    for landmark in hand_landmarks
                ]
            )

            solutions.drawing_utils.draw_landmarks(
                output_image,
                hand_landmarks_proto,
                solutions.hands.HAND_CONNECTIONS,
                solutions.drawing_styles.get_default_hand_landmarks_style(),
                solutions.drawing_styles.get_default_hand_connections_style(),
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
