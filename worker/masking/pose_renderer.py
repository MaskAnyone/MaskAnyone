import cv2
import mediapipe
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2

MP_POSE_PAIRS = [
    (0, 1), (1, 2), (2, 3), (3, 7), (0, 4), (4, 5), (5, 6), (6, 8),
    (9, 10), (11, 12), (11, 13), (13, 15), (15, 19), (15, 17), (17, 19), (15, 21),
    (12, 14), (14, 16), (16, 20), (16, 18), (18, 20), (11, 23), (12, 24), (16, 22),
    (23, 25), (24, 26), (25, 27), (26, 28), (23, 24),
    (28, 30), (28, 32), (30, 32), (27, 29), (27, 31), (29, 31)
]

BODY_25_PAIRS = [
    (0, 1), (1, 2), (2, 3), (3, 4), (1, 5), (5, 6), (6, 7), (1, 8),
    (8, 9), (9, 10), (10, 11), (8, 12), (12, 13), (13, 14), (0, 15),
    (15, 17), (0, 16), (16, 18), (14, 19), (19, 20), (14, 21),
    (11, 22), (22, 23), (11, 24)
]

FACE_PAIRS = [
    (0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8), (8, 9), (9, 10),
    (10, 11), (11, 12), (12, 13), (13, 14), (14, 15), (15, 16),  # Jawline
    (17, 18), (18, 19), (19, 20), (20, 21),  # Right eyebrow
    (22, 23), (23, 24), (24, 25), (25, 26),  # Left eyebrow
    (27, 28), (28, 29), (29, 30),  # Nose bridge
    (31, 32), (32, 33), (33, 34), (34, 35),  # Nose bottom
    (36, 37), (37, 38), (38, 39), (39, 40), (40, 41), (41, 36),  # Right eye
    (42, 43), (43, 44), (44, 45), (45, 46), (46, 47), (47, 42),  # Left eye
    (48, 49), (49, 50), (50, 51), (51, 52), (52, 53), (53, 54), (54, 55), (55, 56),
    (56, 57), (57, 58), (58, 59), (59, 48),  # Outer lip
    (60, 61), (61, 62), (62, 63), (63, 64), (64, 65), (65, 66), (66, 67), (67, 60)  # Inner lip
]

HAND_PAIRS = [
    (0, 1), (1, 2), (2, 3), (3, 4),  # Thumb
    (0, 5), (5, 6), (6, 7), (7, 8),  # Index finger
    (0, 9), (9, 10), (10, 11), (11, 12),  # Middle finger
    (0, 13), (13, 14), (14, 15), (15, 16),  # Ring finger
    (0, 17), (17, 18), (18, 19), (19, 20)  # Pinky
]


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
        elif self._type == 'mp_pose':
            self._render_mp_pose_overlay(rgb_image, keypoint_data)
        elif self._type == 'openpose':
            self._render_openpose_overlay(rgb_image, keypoint_data)

    def _render_mp_pose_overlay(self, rgb_image, keypoint_data):
        for i in range(len(keypoint_data)):
            if keypoint_data[i][0] < 1 and keypoint_data[i][1] < 1:
                continue

            point = tuple(map(int, keypoint_data[i][:2]))
            cv2.circle(rgb_image, point, 4, (0, 0, 0), -1)

        for pair in MP_POSE_PAIRS:
            partA = pair[0]
            partB = pair[1]

            if (keypoint_data[partA][0] < 1 and keypoint_data[partA][1] < 1
                    or keypoint_data[partB][0] < 1 and keypoint_data[partB][1] < 1):
                continue

            pointA = tuple(map(int, keypoint_data[partA][:2]))
            pointB = tuple(map(int, keypoint_data[partB][:2]))
            cv2.line(rgb_image, pointA, pointB, (0, 255, 0), 2)

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

    def _render_openpose_overlay(self, rgb_image, keypoint_data):
        pose_keypoints = keypoint_data['pose_keypoints']
        face_keypoints = keypoint_data['face_keypoints']
        left_hand_keypoints = keypoint_data['left_hand_keypoints']
        right_hand_keypoints = keypoint_data['right_hand_keypoints']

        # Draw all keypoints
        for i in range(len(pose_keypoints)):
            if pose_keypoints[i] is None or pose_keypoints[i][0] < 1 and pose_keypoints[i][1] < 1:
                continue

            point = tuple(map(int, pose_keypoints[i][:2]))
            cv2.circle(rgb_image, point, 4, (0, 255, 0), -1)

        # Iterate over each pair and draw lines
        for pair in BODY_25_PAIRS:
            partA = pair[0]
            partB = pair[1]

            if pose_keypoints[partA] is None or pose_keypoints[partB] is None:
                continue

            if pose_keypoints[partA][0] < 1 and pose_keypoints[partA][1] < 1 or pose_keypoints[partB][0] < 1 and pose_keypoints[partB][
                1] < 1:
                continue

            pointA = tuple(map(int, pose_keypoints[partA]))
            pointB = tuple(map(int, pose_keypoints[partB]))
            cv2.line(rgb_image, pointA, pointB, (0, 255, 0), 2)

        for face_keypoint in face_keypoints:
            if face_keypoint is None:
                continue

            point = tuple(map(int, face_keypoint))
            cv2.circle(rgb_image, point, 2, (0, 255, 255), -1)

        # Iterate over each pair and draw lines
        for pair in FACE_PAIRS:
            partA = pair[0]
            partB = pair[1]

            if face_keypoints[partA] is None or face_keypoints[partB] is None:
                continue

            if face_keypoints[partA][0] < 1 and face_keypoints[partA][1] < 1 or face_keypoints[partB][0] < 1 and \
                    face_keypoints[partB][1] < 1:
                continue

            pointA = tuple(map(int, face_keypoints[partA]))
            pointB = tuple(map(int, face_keypoints[partB]))
            cv2.line(rgb_image, pointA, pointB, (0, 255, 255), 2)

        for hand_keypoint in left_hand_keypoints:
            if hand_keypoint is None:
                continue

            point = tuple(map(int, hand_keypoint))
            cv2.circle(rgb_image, point, 2, (255, 0, 0), -1)

        for pair in HAND_PAIRS:
            partA = pair[0]
            partB = pair[1]

            if left_hand_keypoints[partA] is None or left_hand_keypoints[partB] is None:
                continue

            if left_hand_keypoints[partA][0] < 1 and left_hand_keypoints[partA][1] < 1 or left_hand_keypoints[partB][
                0] < 1 and left_hand_keypoints[partB][1] < 1:
                continue

            pointA = tuple(map(int, left_hand_keypoints[partA]))
            pointB = tuple(map(int, left_hand_keypoints[partB]))
            cv2.line(rgb_image, pointA, pointB, (255, 0, 0), 2)

        for hand_keypoint in right_hand_keypoints:
            if hand_keypoint is None:
                continue

            point = tuple(map(int, hand_keypoint))
            cv2.circle(rgb_image, point, 2, (0, 0, 255), -1)

        for pair in HAND_PAIRS:
            partA = pair[0]
            partB = pair[1]

            if right_hand_keypoints[partA] is None or right_hand_keypoints[partB] is None:
                continue

            if right_hand_keypoints[partA][0] < 1 and right_hand_keypoints[partA][1] < 1 or right_hand_keypoints[partB][
                0] < 1 and right_hand_keypoints[partB][1] < 1:
                continue

            pointA = tuple(map(int, right_hand_keypoints[partA]))
            pointB = tuple(map(int, right_hand_keypoints[partB]))
            cv2.line(rgb_image, pointA, pointB, (0, 0, 255), 2)
