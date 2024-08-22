import mediapipe

class MediaPipeLandmarker:
    _pose_landmarker_model_path: str
    _face_landmarker_model_path: str
    _hand_landmarker_model_path: str

    def __init__(self, type: str):
        self._pose_landmarker_model_path = '/worker_models/pose_landmarker_heavy.task'
        self._face_landmarker_model_path = '/worker_models/face_landmarker.task'
        self._hand_landmarker_model_path = '/worker_models/hand_landmarker.task'

    def configure_pose_landmarker(self):
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

    def configure_face_landmarker(self):
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

    def configure_hand_landmarker(self):
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
