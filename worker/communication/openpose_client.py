import requests
import io
import pickle


class OpenposeClient:
    _base_path: str

    def __init__(self, base_path: str):
        self._base_path = base_path

    def estimate_pose_on_video(self, video_content):
        files = {
            'video': ('video.mp4', video_content, 'video/mp4'),
        }

        response = requests.post(
            self._make_url("estimate-pose-on-video"),
            files=files,
        )

        buffer = io.BytesIO(response.content)
        pose_data = pickle.load(buffer)

        return pose_data

    def _make_url(self, path: str) -> str:
        return self._base_path + "/" + path
