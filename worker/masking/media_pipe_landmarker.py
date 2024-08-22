import mediapipe
import cv2


class MediaPipeLandmarker:
    _pose_landmarker_model_path: str
    _face_landmarker_model_path: str
    _hand_landmarker_model_path: str

    def __init__(self):
        self._pose_landmarker_model_path = '/worker_models/pose_landmarker_heavy.task'
        self._face_landmarker_model_path = '/worker_models/face_landmarker.task'
        self._hand_landmarker_model_path = '/worker_models/hand_landmarker.task'

    def compute_pose_data(self, sub_video_path: str):
        landmarker = self._configure_pose_landmarker()
        video_capture = cv2.VideoCapture(sub_video_path)

        data = []

        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = video_capture.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)
            pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            if len(pose_landmarker_result.pose_landmarks) > 0:
                data.append(pose_landmarker_result.pose_landmarks[0])
            else:
                data.append(None)

        video_capture.release()
        return data

    def compute_face_data(self, sub_video_path: str):
        landmarker = self._configure_face_landmarker()
        video_capture = cv2.VideoCapture(sub_video_path)

        data = []

        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = video_capture.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)
            face_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            if len(face_landmarker_result.face_landmarks) > 0:
                data.append(face_landmarker_result.face_landmarks[0])
            else:
                data.append(None)

        video_capture.release()
        return data

    def compute_hand_data(self, sub_video_path: str):
        landmarker = self._configure_hand_landmarker()
        video_capture = cv2.VideoCapture(sub_video_path)

        data = []

        while video_capture.isOpened():
            ret, frame = video_capture.read()

            if not ret:
                break

            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_timestamp_ms = video_capture.get(cv2.CAP_PROP_POS_MSEC)

            mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=frame)
            hand_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

            if len(hand_landmarker_result.hand_landmarks) > 0:
                data.append(hand_landmarker_result.hand_landmarks[0])
            else:
                data.append(None)

        video_capture.release()
        return data

    def _configure_pose_landmarker(self):
        options = mediapipe.tasks.vision.PoseLandmarkerOptions(
            base_options=mediapipe.tasks.BaseOptions(
                model_asset_path=self._pose_landmarker_model_path,
                delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
            ),
            running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
            num_poses=1,
        )

        landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)
        return landmarker

    def _configure_face_landmarker(self):
        options = mediapipe.tasks.vision.FaceLandmarkerOptions(
            base_options=mediapipe.tasks.BaseOptions(
                model_asset_path=self._face_landmarker_model_path,
                delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
            ),
            running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
            # output_face_blendshapes=True,
            # output_facial_transformation_matrixes=True,
            num_faces=1
        )

        landmarker = mediapipe.tasks.vision.FaceLandmarker.create_from_options(options)
        return landmarker

    def _configure_hand_landmarker(self):
        options = mediapipe.tasks.vision.HandLandmarkerOptions(
            base_options=mediapipe.tasks.BaseOptions(
                model_asset_path=self._hand_landmarker_model_path,
                delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
            ),
            running_mode=mediapipe.tasks.vision.RunningMode.VIDEO,
            num_hands=1
        )

        landmarker = mediapipe.tasks.vision.HandLandmarker.create_from_options(options)
        return landmarker
