import mediapipe
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2


class PoseRenderer:
    _type: str

    def __init__(self, type: str):
        self._type = type

    def render_keypoint_overlay(self, rgb_image, keypoint_data):
        if keypoint_data is None:
            return

        if self._type == 'mp_hand':
            self._render_mp_hand_overlay(rgb_image, keypoint_data)
        elif self._type == 'mp_face':
            self._render_mp_face_overlay(rgb_image, keypoint_data)

    def _render_mp_pose_overlay(self):
        pass

    def _render_mp_face_overlay(self, rgb_image, keypoint_data):
        image_height, image_width, _ = rgb_image.shape

        face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
        face_landmarks_proto.landmark.extend([
            landmark_pb2.NormalizedLandmark(x=landmark[0] / image_width, y=landmark[1] / image_height, z=0.5) for
            landmark in keypoint_data
        ])

        solutions.drawing_utils.draw_landmarks(
            image=rgb_image,
            landmark_list=face_landmarks_proto,
            connections=mediapipe.solutions.face_mesh.FACEMESH_TESSELATION,
            landmark_drawing_spec=None,
            connection_drawing_spec=mediapipe.solutions.drawing_styles
            .get_default_face_mesh_tesselation_style())
        solutions.drawing_utils.draw_landmarks(
            image=rgb_image,
            landmark_list=face_landmarks_proto,
            connections=mediapipe.solutions.face_mesh.FACEMESH_CONTOURS,
            landmark_drawing_spec=None,
            connection_drawing_spec=mediapipe.solutions.drawing_styles
            .get_default_face_mesh_contours_style())
        solutions.drawing_utils.draw_landmarks(
            image=rgb_image,
            landmark_list=face_landmarks_proto,
            connections=mediapipe.solutions.face_mesh.FACEMESH_IRISES,
            landmark_drawing_spec=None,
            connection_drawing_spec=mediapipe.solutions.drawing_styles
            .get_default_face_mesh_iris_connections_style())

    def _render_mp_hand_overlay(self, rgb_image, keypoint_data):
        image_height, image_width, _ = rgb_image.shape

        hand_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
        hand_landmarks_proto.landmark.extend([
            landmark_pb2.NormalizedLandmark(x=landmark[0] / image_width, y=landmark[1] / image_height, z=0.5) for
            landmark in keypoint_data
        ])
        solutions.drawing_utils.draw_landmarks(
            rgb_image,
            hand_landmarks_proto,
            solutions.hands.HAND_CONNECTIONS,
            solutions.drawing_styles.get_default_hand_landmarks_style(),
            solutions.drawing_styles.get_default_hand_connections_style())

    def _render_openpose_overlay(self):
        pass
