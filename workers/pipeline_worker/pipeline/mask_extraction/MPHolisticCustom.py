import mediapipe as mp
import cv2
import numpy as np
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
import os

input_path = "/home/rohan/Documents/Uni/Sem4/MP/better_mp/ted_kid.mp4"
output_path = "/home/rohan/Documents/Uni/Sem4/MP/better_mp/ted_kid_out.mp4"
live_output = True

BaseOptions = mp.tasks.BaseOptions
PoseLandmarker = mp.tasks.vision.PoseLandmarker
PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
FaceLandmarker = mp.tasks.vision.FaceLandmarker
FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
HandLandmarker = mp.tasks.vision.HandLandmarker
HandLandmarkerOptions = mp.tasks.vision.HandLandmarkerOptions
VisionRunningMode = mp.tasks.vision.RunningMode
mp_pose = mp.solutions.pose

pose_options = PoseLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path="/home/rohan/Documents/Uni/Sem4/MP/better_mp/data/pose_landmarker_heavy.task"
    ),
    running_mode=VisionRunningMode.VIDEO,
)

face_options = FaceLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path="/home/rohan/Documents/Uni/Sem4/MP/better_mp/data/face_landmarker.task"
    ),
    running_mode=VisionRunningMode.VIDEO,
)

hand_options = HandLandmarkerOptions(
    base_options=BaseOptions(
        model_asset_path="/home/rohan/Documents/Uni/Sem4/MP/better_mp/data/hand_landmarker.task"
    ),
    running_mode=VisionRunningMode.VIDEO,
)

cap = cv2.VideoCapture(input_path)
width = int(cap.get(3))
height = int(cap.get(4))
samplerate = cap.get(cv2.CAP_PROP_FPS)

fourcc = cv2.VideoWriter_fourcc(*"vp09")
out = cv2.VideoWriter(
    output_path,
    fourcc,
    fps=samplerate,
    frameSize=(int(width), int(height)),
)


def draw_pose_landmarks(rgb_image, detection_result, face_mesh_found, hand_pose_found):
    pose_landmarks_list = detection_result.pose_landmarks
    annotated_image = np.copy(rgb_image)

    # Loop through the detected poses to visualize.
    for idx in range(len(pose_landmarks_list)):
        pose_landmarks = pose_landmarks_list[idx]

        # Remove all face landmarks if a face mesh was found, to avoid duplicate face visualization
        if face_mesh_found:
            for lm in pose_landmarks[:11]:
                lm.visibility = 0.0

        # Remove all hand landmarks if a detailed ahdn pose was found, to avoid duplicate visualization
        if hand_pose_found:
            for lm in pose_landmarks[17:23]:
                lm.visibility = 0.0

        # Draw the pose landmarks.
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
            annotated_image,
            pose_landmarks_proto,
            solutions.pose.POSE_CONNECTIONS,
            solutions.drawing_styles.get_default_pose_landmarks_style(),
        )
    return annotated_image


def draw_face_landmarks(rgb_image, detection_result):
    face_landmarks_list = detection_result.face_landmarks
    annotated_image = np.copy(rgb_image)

    # Loop through the detected faces to visualize.
    for idx in range(len(face_landmarks_list)):
        face_landmarks = face_landmarks_list[idx]

        # Draw the face landmarks.
        face_landmarks_proto = landmark_pb2.NormalizedLandmarkList()
        face_landmarks_proto.landmark.extend(
            [
                landmark_pb2.NormalizedLandmark(
                    x=landmark.x, y=landmark.y, z=landmark.z
                )
                for landmark in face_landmarks
            ]
        )

        solutions.drawing_utils.draw_landmarks(
            image=annotated_image,
            landmark_list=face_landmarks_proto,
            connections=mp.solutions.face_mesh.FACEMESH_TESSELATION,
            landmark_drawing_spec=None,
            connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_tesselation_style(),
        )
        solutions.drawing_utils.draw_landmarks(
            image=annotated_image,
            landmark_list=face_landmarks_proto,
            connections=mp.solutions.face_mesh.FACEMESH_CONTOURS,
            landmark_drawing_spec=None,
            connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_contours_style(),
        )
        solutions.drawing_utils.draw_landmarks(
            image=annotated_image,
            landmark_list=face_landmarks_proto,
            connections=mp.solutions.face_mesh.FACEMESH_IRISES,
            landmark_drawing_spec=None,
            connection_drawing_spec=mp.solutions.drawing_styles.get_default_face_mesh_iris_connections_style(),
        )

    return annotated_image


MARGIN = 10  # pixels
FONT_SIZE = 1
FONT_THICKNESS = 1
HANDEDNESS_TEXT_COLOR = (88, 205, 54)  # vibrant green


def draw_hand_landmarks(rgb_image, detection_result):
    hand_landmarks_list = detection_result.hand_landmarks
    handedness_list = detection_result.handedness
    annotated_image = np.copy(rgb_image)

    # Loop through the detected hands to visualize.
    for idx in range(len(hand_landmarks_list)):
        hand_landmarks = hand_landmarks_list[idx]
        handedness = handedness_list[idx]

        # Draw the hand landmarks.
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
            annotated_image,
            hand_landmarks_proto,
            solutions.hands.HAND_CONNECTIONS,
            solutions.drawing_styles.get_default_hand_landmarks_style(),
            solutions.drawing_styles.get_default_hand_connections_style(),
        )

        # Get the top left corner of the detected hand's bounding box.
        height, width, _ = annotated_image.shape
        x_coordinates = [landmark.x for landmark in hand_landmarks]
        y_coordinates = [landmark.y for landmark in hand_landmarks]
        text_x = int(min(x_coordinates) * width)
        text_y = int(min(y_coordinates) * height) - MARGIN

        # Draw handedness (left or right hand) on the image.
        cv2.putText(
            annotated_image,
            f"{handedness[0].category_name}",
            (text_x, text_y),
            cv2.FONT_HERSHEY_DUPLEX,
            FONT_SIZE,
            HANDEDNESS_TEXT_COLOR,
            FONT_THICKNESS,
            cv2.LINE_AA,
        )

    return annotated_image


is_first_frame = True
last_frame_timestamp = 0
idx = 0

with PoseLandmarker.create_from_options(
    pose_options
) as pose_landmarker, FaceLandmarker.create_from_options(
    face_options
) as face_landmarker, HandLandmarker.create_from_options(
    hand_options
) as hand_landmarker:
    while True:
        idx = idx + 1
        ret, frame = cap.read()

        if not ret:
            break

        frame_timestamp_ms = int(cap.get(cv2.CAP_PROP_POS_MSEC))
        if frame_timestamp_ms < last_frame_timestamp:
            print(
                "An Error occured: Timestamp from frame lower than from last processed frame. Skipping frame"
            )
            continue

        last_frame_timestamp = frame_timestamp_ms
        mp_image_full = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)

        # Process the image to get pose landmarks
        pose_results = pose_landmarker.detect_for_video(
            mp_image_full, frame_timestamp_ms
        )
        annotated_image = frame
        for landmarks in pose_results.pose_landmarks:
            # Crop face region
            landmarks = pose_results.pose_landmarks[0]
            x_center = int(
                (
                    landmarks[mp_pose.PoseLandmark.LEFT_EYE].x
                    + landmarks[mp_pose.PoseLandmark.RIGHT_EYE].x
                )
                / 2
                * width
            )
            y_center = int(
                (
                    landmarks[mp_pose.PoseLandmark.LEFT_EYE].y
                    + landmarks[mp_pose.PoseLandmark.RIGHT_EYE].y
                )
                / 2
                * height
            )

            # use multiple possible distances, to reduce risk of having a bad camera angle in which keypoints are not well shown
            distance_by_ears = int(
                abs(
                    landmarks[mp_pose.PoseLandmark.LEFT_EAR].x
                    - landmarks[mp_pose.PoseLandmark.RIGHT_EAR].x
                )
                * width
            )
            distance_by_eyes = 4 * int(
                abs(
                    landmarks[mp_pose.PoseLandmark.LEFT_EYE].x
                    - landmarks[mp_pose.PoseLandmark.RIGHT_EYE].x
                )
                * width
            )
            distane_by_shoulders = int(
                abs(
                    landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER].x
                    - landmarks[mp_pose.PoseLandmark.RIGHT_SHOULDER].x
                )
                * width
            )
            face_size = max(0, distance_by_ears, distance_by_eyes, distane_by_shoulders)
            padding = int(face_size * 0.1)
            face_size += padding

            face_image = frame[
                max(0, y_center - face_size) : min(height, y_center + face_size),
                max(0, x_center - face_size) : min(width, x_center + face_size),
            ].copy()

            if live_output:
                cv2.imshow("face", face_image)

            # Process the face image with face mesh model
            mp_image_face = mp.Image(image_format=mp.ImageFormat.SRGB, data=face_image)
            face_results = face_landmarker.detect_for_video(
                mp_image_face, frame_timestamp_ms
            )
            if face_results.face_landmarks:
                face_results_image = draw_face_landmarks(face_image, face_results)

                # Write face results back to the original location
                frame[
                    max(0, y_center - face_size) : min(height, y_center + face_size),
                    max(0, x_center - face_size) : min(width, x_center + face_size),
                ] = face_results_image

            # Crop hands regions
            left_wrist = [
                int(landmarks[mp_pose.PoseLandmark.LEFT_WRIST].x * width),
                int(landmarks[mp_pose.PoseLandmark.LEFT_WRIST].y * height),
            ]
            right_wrist = [
                int(landmarks[mp_pose.PoseLandmark.RIGHT_WRIST].x * width),
                int(landmarks[mp_pose.PoseLandmark.RIGHT_WRIST].y * height),
            ]
            left_elbow = [
                int(landmarks[mp_pose.PoseLandmark.LEFT_ELBOW].x * width),
                int(landmarks[mp_pose.PoseLandmark.LEFT_ELBOW].y * height),
            ]
            right_elbow = [
                int(landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW].x * width),
                int(landmarks[mp_pose.PoseLandmark.RIGHT_ELBOW].y * height),
            ]

            hand_size = max(
                max(abs(np.array(left_wrist) - np.array(left_elbow))),
                max(abs(np.array(right_wrist) - np.array(right_elbow))),
            )
            padding = int(hand_size * 0.2)
            hand_size += padding

            x_min = max(
                0,
                min(left_wrist[0], right_wrist[0], left_elbow[0], right_elbow[0])
                - hand_size,
            )
            x_max = min(
                width,
                max(left_wrist[0], right_wrist[0], left_elbow[0], right_elbow[0])
                + hand_size,
            )
            y_min = max(
                0,
                min(left_wrist[1], right_wrist[1], left_elbow[1], right_elbow[1])
                - hand_size,
            )
            y_max = min(
                height,
                max(left_wrist[1], right_wrist[1], left_elbow[1], right_elbow[1])
                + hand_size,
            )

            hand_image = frame[y_min:y_max, x_min:x_max].copy()
            if live_output:
                cv2.imshow("hands", hand_image)

            # Process the hand image with hands model
            mp_image_hand = mp.Image(image_format=mp.ImageFormat.SRGB, data=hand_image)
            frame_timestamp_ms = frame_timestamp_ms + 1
            hand_results = hand_landmarker.detect_for_video(
                mp_image_hand, frame_timestamp_ms
            )
            hand_result_image = draw_hand_landmarks(hand_image, hand_results)

            # Write hand results back to the original location
            frame[y_min:y_max, x_min:x_max] = hand_result_image

            face_mesh_found = len(face_results.face_landmarks) != 0
            hand_pose_found = len(hand_results.hand_landmarks) != 0
            annotated_image = draw_pose_landmarks(
                annotated_image, pose_results, face_mesh_found, hand_pose_found
            )

        if live_output:
            cv2.imshow("Annotated Result", annotated_image)
        cv2.waitKey(1)
        out.write(annotated_image)


out.release()
cap.release()
