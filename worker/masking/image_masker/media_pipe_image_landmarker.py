import mediapipe


class MediaPipeImageLandmarker:
    _pose_landmarker_model_path: str
    _pose_landmarker: mediapipe.tasks.vision.PoseLandmarker | None

    def __init__(self):
        self._pose_landmarker_model_path = '/worker_models/pose_landmarker_heavy.task'
        self._pose_landmarker = None

    def compute_pose_data(self, image):
        landmarker = self._configure_pose_landmarker()

        mp_image = mediapipe.Image(image_format=mediapipe.ImageFormat.SRGB, data=image)
        pose_landmarker_result = landmarker.detect(mp_image)

        return pose_landmarker_result.pose_landmarks[0] if len(pose_landmarker_result.pose_landmarks) else None

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
