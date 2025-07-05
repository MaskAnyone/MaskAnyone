import mediapipe


class MediaPipeImageLandmarker:
    POSE_KEYPOINT_COUNT = 33
    FACE_KEYPOINT_COUNT = 478
    HAND_KEYPOINT_COUNT = 21

    _pose_landmarker_model_path: str
    _face_landmarker_model_path: str
    _hand_landmarker_model_path: str
    _pose_landmarker: mediapipe.tasks.vision.PoseLandmarker | None

    def __init__(self):
        self._pose_landmarker_model_path = '/worker_models/pose_landmarker_heavy.task'
        self._face_landmarker_model_path = '/worker_models/face_landmarker.task'
        self._hand_landmarker_model_path = '/worker_models/hand_landmarker.task'
        self._pose_landmarker = None

    def compute_pose_data(self, image):
        landmarker = self._configure_pose_landmarker()

        mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=image)
        pose_landmarker_result = landmarker.detect(mp_image)

        return pose_landmarker_result.pose_landmarks[0] if len(pose_landmarker_result.pose_landmarks) else None

    def compute_face_data(self, image):
        landmarker = self._configure_face_landmarker()

        mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=image)
        face_landmarker_result = landmarker.detect(mp_image)

        return face_landmarker_result.face_landmarks[0] if len(face_landmarker_result.face_landmarks) else None

    def compute_hand_data(self, image):
        landmarker = self._configure_hand_landmarker()

        mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=image)
        hand_landmarker_result = landmarker.detect(mp_image)

        return hand_landmarker_result.hand_landmarks[0] if len(hand_landmarker_result.hand_landmarks) else None

    def _configure_pose_landmarker(self):
        if self._pose_landmarker is not None:
            return self._pose_landmarker

        options = mediapipe.tasks.vision.PoseLandmarkerOptions(
            base_options=mediapipe.tasks.BaseOptions(
                model_asset_path=self._pose_landmarker_model_path,
                delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
            ),
            running_mode=mediapipe.tasks.vision.RunningMode.IMAGE,
            num_poses=1,
        )

        self._pose_landmarker = mediapipe.tasks.vision.PoseLandmarker.create_from_options(options)
        return self._pose_landmarker

    def _configure_face_landmarker(self):
        if self._pose_landmarker is not None:
            return self._pose_landmarker

        options = mediapipe.tasks.vision.FaceLandmarkerOptions(
            base_options=mediapipe.tasks.BaseOptions(
                model_asset_path=self._face_landmarker_model_path,
                delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
            ),
            running_mode=mediapipe.tasks.vision.RunningMode.IMAGE,
            num_faces=1,
        )

        self._face_landmarker = mediapipe.tasks.vision.FaceLandmarker.create_from_options(options)
        return self._face_landmarker

    def _configure_hand_landmarker(self):
        if self._pose_landmarker is not None:
            return self._pose_landmarker

        options = mediapipe.tasks.vision.HandLandmarkerOptions(
            base_options=mediapipe.tasks.BaseOptions(
                model_asset_path=self._hand_landmarker_model_path,
                delegate=mediapipe.tasks.BaseOptions.Delegate.CPU
            ),
            running_mode=mediapipe.tasks.vision.RunningMode.IMAGE,
            num_hands=1,
        )

        self._hand_landmarker = mediapipe.tasks.vision.HandLandmarker.create_from_options(options)
        return self._hand_landmarker
