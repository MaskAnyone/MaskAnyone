import requests
import io
import pickle
import json


class OpenposeClient:
    _base_path: str

    def __init__(self, base_path: str):
        self._base_path = base_path

    def estimate_pose_on_video(self, video_content, options: dict):
        files = {
            'video': ('video.mp4', video_content, 'video/mp4'),
        }

        data = {
            'options': json.dumps(options),
        }

        response = requests.post(
            self._make_url("estimate-pose-on-video"),
            files=files,
            data=data,
        )

        buffer = io.BytesIO(response.content)
        pose_data = pickle.load(buffer)

        return pose_data

    def estimate_pose_on_image(self, image_content, options: dict):
        files = {
            'image': ('image.jpg', image_content, 'image/jpeg'),
        }

        data = {
            'options': json.dumps(options),
        }

        response = requests.post(
            self._make_url("estimate-pose-on-image"),
            files=files,
            data=data,
        )

        buffer = io.BytesIO(response.content)
        pose_data = pickle.load(buffer)

        return pose_data


    def _make_url(self, path: str) -> str:
        return self._base_path + "/" + path
