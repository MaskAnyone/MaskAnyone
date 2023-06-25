import os

import cv2

import mediapipe as mp
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
import numpy as np

from masking.BaseMasker import BaseMasker

class MPMasker(BaseMasker):

    def mask_face(self):
        face_landmarker_results = self.face_landmarker.detect_for_video(self.cur_mp_image, self.frame_timestamp_ms)
        print(face_landmarker_results)
        return face_landmarker_results

    def mask_body(self):
        pose_landmarker_result = self.pose_landmarker.detect_for_video(self.cur_mp_image, self.frame_timestamp_ms)
        return pose_landmarker_result

    def mask_fingers(self):
        hand_landmarker_result = self.hand_landmarker.detect_for_video(self.cur_mp_image, self.frame_timestamp_ms)
        print(hand_landmarker_result)
        return hand_landmarker_result

    def setup_masking_utilities(self):
        face_model_path = os.path.join("models", "face_landmarker.task")
        pose_model_path = os.path.join("models", "pose_landmarker_heavy.task")
        hand_model_path = os.path.join("models", "hand_landmarker.task")

        BaseOptions = mp.tasks.BaseOptions
        VisionRunningMode = mp.tasks.vision.RunningMode
        FaceLandmarker = mp.tasks.vision.FaceLandmarker
        FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
        PoseLandmarker = mp.tasks.vision.PoseLandmarker
        PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
        HandLandmarker = mp.tasks.vision.HandLandmarker
        HandLandmarkerOptions = mp.tasks.vision.HandLandmarkerOptions

        pose_options = PoseLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=pose_model_path),
            running_mode=VisionRunningMode.VIDEO,
            output_segmentation_masks=True,
            num_poses=2)
        
        hand_options = HandLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=hand_model_path),
            running_mode=VisionRunningMode.VIDEO)
        
        face_options = FaceLandmarkerOptions(
            base_options=BaseOptions(model_asset_path=face_model_path),
            running_mode=VisionRunningMode.VIDEO,
            output_face_blendshapes=True,
            output_facial_transformation_matrixes=True,
            num_faces=2)

        self.pose_landmarker = PoseLandmarker.create_from_options(pose_options)
        self.hand_landmarker = HandLandmarker.create_from_options(hand_options)
        self.face_landmakrer = FaceLandmarker.create_from_options(face_options)

    def pre_process_cur_frame(self):
        self.cur_mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=self.frame)

    def draw_mask(self, face_res, body_res, fingers_res):
        annotated_image = np.copy(self.frame_bg)

        if face_res:
            face_landmarks_list = face_res.face_landmarks
            for idx in range(len(face_landmarks_list)):
                face_landmarks = face_landmarks_list[idx]

                face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
                face_landmarks_proto.landmark.extend([
                    landmark_pb2.NormalizedLandmark(x=landmark.x, y=landmark.y, z=landmark.z) for landmark in face_landmarks
                ])

                solutions.drawing_utils.draw_landmarks(
                    image=annotated_image,
                    landmark_list=face_landmarks_proto,
                    connections=mp.solutions.face_mesh.FACEMESH_TESSELATION,
                    landmark_drawing_spec=None,
                    connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_tesselation_style())
                solutions.drawing_utils.draw_landmarks(
                    image=annotated_image,
                    landmark_list=face_landmarks_proto,
                    connections=mp.solutions.face_mesh.FACEMESH_CONTOURS,
                    landmark_drawing_spec=None,
                    connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_contours_style())
                solutions.drawing_utils.draw_landmarks(
                    image=annotated_image,
                    landmark_list=face_landmarks_proto,
                    connections=mp.solutions.face_mesh.FACEMESH_IRISES,
                    landmark_drawing_spec=None,
                    connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_iris_connections_style())

        if body_res:
            pose_landmarks_list = body_res.pose_landmarks
            for idx in range(len(pose_landmarks_list)):
                pose_landmarks = pose_landmarks_list[idx]

                pose_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
                pose_landmarks_proto.landmark.extend([
                    landmark_pb2.NormalizedLandmark(x=landmark.x, y=landmark.y, z=landmark.z) for landmark in pose_landmarks])

                solutions.drawing_utils.draw_landmarks(
                    annotated_image,
                    pose_landmarks_proto,
                    solutions.pose.POSE_CONNECTIONS,
                    solutions.drawing_styles.get_default_pose_landmarks_style())

        if fingers_res:
            hand_landmarks_list = fingers_res.hand_landmarks
            for idx in range(len(hand_landmarks_list)):
                hand_landmarks = hand_landmarks_list[idx]

                hand_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
                hand_landmarks_proto.landmark.extend([
                    landmark_pb2.NormalizedLandmark(x=landmark.x, y=landmark.y, z=landmark.z) for landmark in hand_landmarks])

                solutions.drawing_utils.draw_landmarks(
                    annotated_image,
                    hand_landmarks_proto,
                    solutions.hands.HAND_CONNECTIONS,
                    solutions.drawing_styles.get_default_hand_landmarks_style(),
                    solutions.drawing_styles.get_default_hand_connections_style())
                
        return annotated_image