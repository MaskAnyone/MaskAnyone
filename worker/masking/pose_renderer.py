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
    (1, 8), (1, 2), (1, 5), (2, 3), (3, 4), (5, 6), (6, 7), (8, 9),
    (9, 10), (10, 11), (8, 12), (12, 13), (13, 14), (1, 0), (0, 15),
    (15, 17), (0, 16), (16, 18), (14, 19), (19, 20),
    (14, 21), (11, 22), (22, 23), (11, 24)
    # (2, 17), (5, 18)
]

#https://github.com/CMU-Perceptual-Computing-Lab/openpose/blob/41d8c087459fae844e477dda50a6f732e70f2cb8/src/openpose/pose/poseParameters.cpp#L149

BODY_25B_PAIRS = [
    (0, 1), (0, 2), (1, 3), (2, 4), (5, 7), (6, 8),
    (7, 9), (8, 10), (5, 11), (6, 12), (11, 13), (12, 14), (13, 15), (14, 16),
    (15, 19), (19, 20), (15, 21), (16, 22), (22, 23), (16, 24), (5, 17), (6, 17),
    # (5, 18), (6, 18), (0, 5), (0, 6)
    # (3, 5), (4, 6), (3, 4), (5, 9), (6, 10), (9, 10), (9, 11), (10, 12), (11, 12), (15, 16)
    (11, 12), (17, 18), (5, 6)
]

H135 = 25
F135 = H135 + 40

BODY_135_HAND_PAIRS = [
    # Left Hand
    (9, H135 + 0), (H135 + 0, H135 + 1), (H135 + 1, H135 + 2), (H135 + 2, H135 + 3),
    (9, H135 + 4), (H135 + 4, H135 + 5), (H135 + 5, H135 + 6), (H135 + 6, H135 + 7),
    (9, H135 + 8), (H135 + 8, H135 + 9), (H135 + 9, H135 + 10), (H135 + 10, H135 + 11),
    (9, H135 + 12), (H135 + 12, H135 + 13), (H135 + 13, H135 + 14), (H135 + 14, H135 + 15),
    (9, H135 + 16), (H135 + 16, H135 + 17), (H135 + 17, H135 + 18), (H135 + 18, H135 + 19),

    # Right Hand
    (10, H135 + 20), (H135 + 20, H135 + 21), (H135 + 21, H135 + 22), (H135 + 22, H135 + 23),
    (10, H135 + 24), (H135 + 24, H135 + 25), (H135 + 25, H135 + 26), (H135 + 26, H135 + 27),
    (10, H135 + 28), (H135 + 28, H135 + 29), (H135 + 29, H135 + 30), (H135 + 30, H135 + 31),
    (10, H135 + 32), (H135 + 32, H135 + 33), (H135 + 33, H135 + 34), (H135 + 34, H135 + 35),
    (10, H135 + 36), (H135 + 36, H135 + 37), (H135 + 37, H135 + 38), (H135 + 38, H135 + 39),
]

BODY_135_PAIRS = BODY_25B_PAIRS + BODY_135_HAND_PAIRS + [
    # Face - COCO-Face
    (0, F135 + 30), (2, F135 + 39), (1, F135 + 42),

    # Face - Contour
    (F135 + 0, F135 + 1), (F135 + 1, F135 + 2), (F135 + 2, F135 + 3), (F135 + 3, F135 + 4),
    (F135 + 4, F135 + 5), (F135 + 5, F135 + 6), (F135 + 6, F135 + 7), (F135 + 7, F135 + 8),
    (F135 + 8, F135 + 9), (F135 + 9, F135 + 10), (F135 + 10, F135 + 11), (F135 + 11, F135 + 12),
    (F135 + 12, F135 + 13), (F135 + 13, F135 + 14), (F135 + 14, F135 + 15), (F135 + 15, F135 + 16),

    # Contour-Eyebrow + Eyebrows
    (F135 + 0, F135 + 17), (F135 + 16, F135 + 26), (F135 + 17, F135 + 18), (F135 + 18, F135 + 19),
    (F135 + 19, F135 + 20), (F135 + 20, F135 + 21), (F135 + 21, F135 + 22), (F135 + 22, F135 + 23),
    (F135 + 23, F135 + 24), (F135 + 24, F135 + 25), (F135 + 25, F135 + 26),

    # Eyebrow-Nose + Nose
    (F135 + 21, F135 + 27), (F135 + 22, F135 + 27), (F135 + 27, F135 + 28), (F135 + 28, F135 + 29),
    (F135 + 29, F135 + 30), (F135 + 30, F135 + 33), (F135 + 33, F135 + 32), (F135 + 32, F135 + 31),
    (F135 + 33, F135 + 34), (F135 + 34, F135 + 35),

    # Nose-Eyes + Eyes
    (F135 + 27, F135 + 39), (F135 + 27, F135 + 42), (F135 + 36, F135 + 37), (F135 + 37, F135 + 38),
    (F135 + 38, F135 + 39), (F135 + 39, F135 + 40), (F135 + 40, F135 + 41),
    (F135 + 42, F135 + 43), (F135 + 43, F135 + 44), (F135 + 44, F135 + 45),
    (F135 + 45, F135 + 46), (F135 + 46, F135 + 47),

    # Nose-Mouth + Outer Mouth
    (F135 + 48, F135 + 49), (F135 + 49, F135 + 50), (F135 + 50, F135 + 51),
    (F135 + 51, F135 + 52), (F135 + 52, F135 + 53), (F135 + 53, F135 + 54),
    (F135 + 54, F135 + 55), (F135 + 55, F135 + 56), (F135 + 56, F135 + 57),
    (F135 + 57, F135 + 58), (F135 + 58, F135 + 59),
    # (F135 + 33, F135 + 51),
    (F135 + 59, F135 + 48),

    # Outer-Inner + Inner Mouth
    (F135 + 48, F135 + 60), (F135 + 54, F135 + 64), (F135 + 60, F135 + 61), (F135 + 61, F135 + 62),
    (F135 + 62, F135 + 63), (F135 + 63, F135 + 64), (F135 + 64, F135 + 65),
    (F135 + 65, F135 + 66), (F135 + 66, F135 + 67),
    (F135 + 67, F135 + 60),

    # Eyes-Pupils
    (F135 + 36, F135 + 68), (F135 + 39, F135 + 68), (F135 + 42, F135 + 69), (F135 + 45, F135 + 69)
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
        elif self._type.startswith('openpose'):
            self._render_openpose_overlay(self._type, rgb_image, keypoint_data)

    def _render_mp_pose_overlay(self, rgb_image, keypoint_data):
        for i in range(len(keypoint_data)):
            if keypoint_data[i] is None or keypoint_data[i][0] < 1 and keypoint_data[i][1] < 1:
                continue

            point = tuple(map(int, keypoint_data[i][:2]))
            cv2.circle(rgb_image, point, 4, (0, 0, 0), -1)

        for pair in MP_POSE_PAIRS:
            partA = pair[0]
            partB = pair[1]

            if keypoint_data[partA] is None or keypoint_data[partB] is None or \
                    keypoint_data[partA][0] < 1 and keypoint_data[partA][1] < 1 or \
                    keypoint_data[partB][0] < 1 and keypoint_data[partB][1] < 1:
                continue

            pointA = tuple(map(int, keypoint_data[partA][:2]))
            pointB = tuple(map(int, keypoint_data[partB][:2]))
            cv2.line(rgb_image, pointA, pointB, (0, 255, 0), 2)

    def _render_mp_face_overlay(self, rgb_image, keypoint_data):
        image_height, image_width, _ = rgb_image.shape

        face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
        face_landmarks_proto.landmark.extend([
            landmark_pb2.NormalizedLandmark(
                x=(landmark[0] / image_width if landmark is not None else 0.0),
                y=(landmark[1] / image_height if landmark is not None else 0.0),
                z=0.5) for
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
            landmark_pb2.NormalizedLandmark(
                x=(landmark[0] / image_width if landmark is not None else 0.0),
                y=(landmark[1] / image_height if landmark is not None else 0.0),
                z=0.5) for
            landmark in keypoint_data
        ])
        solutions.drawing_utils.draw_landmarks(
            rgb_image,
            hand_landmarks_proto,
            solutions.hands.HAND_CONNECTIONS,
            solutions.drawing_styles.get_default_hand_landmarks_style(),
            solutions.drawing_styles.get_default_hand_connections_style())

    def _render_openpose_overlay(self, type: str, rgb_image, keypoint_data):
        pose_keypoints = keypoint_data['pose_keypoints']
        face_keypoints = keypoint_data['face_keypoints']
        left_hand_keypoints = keypoint_data['left_hand_keypoints']
        right_hand_keypoints = keypoint_data['right_hand_keypoints']

        # Draw all keypoints
        for i in range(len(pose_keypoints)):
            if pose_keypoints[i] is None or pose_keypoints[i][0] < 1 and pose_keypoints[i][1] < 1:
                continue

            size = 4
            color = (0, 255, 0)

            if i > 24:
                size = 2
                color = (255, 0, 0)

            if i > 44:
                color = (0, 0, 255)

            if i > 64:
                color = (0, 255, 255)

            point = tuple(map(int, pose_keypoints[i][:2]))
            cv2.circle(rgb_image, point, size, color, -1)

        body_pairs = BODY_25_PAIRS
        if type == 'openpose_body25b':
            body_pairs = BODY_25B_PAIRS
        elif type == 'openpose_body_135':
            body_pairs = BODY_135_PAIRS

        # Iterate over each pair and draw lines
        for pair in body_pairs:
            partA = pair[0]
            partB = pair[1]

            if pose_keypoints[partA] is None or pose_keypoints[partB] is None:
                continue

            if pose_keypoints[partA][0] < 1 and pose_keypoints[partA][1] < 1 or pose_keypoints[partB][0] < 1 and pose_keypoints[partB][1] < 1:
                continue

            color = (0, 255, 0)

            if partA > 24 and partB > 24:
                color = (255, 0, 0)

            if partA > 44 and partB > 44:
                color = (0, 0, 255)

            if partA > 64 and partB > 64:
                color = (0, 255, 255)

            pointA = tuple(map(int, pose_keypoints[partA]))
            pointB = tuple(map(int, pose_keypoints[partB]))
            cv2.line(rgb_image, pointA, pointB, color, 2)

        if face_keypoints is not None:
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

        if left_hand_keypoints is not None:
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

        if right_hand_keypoints is not None:
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

