import os

from communication.backend_client import BackendClient
from communication.local_data_manager import LocalDataManager

class VideoManager:
    __backend_client: BackendClient
    __local_data_manager: LocalDataManager

    def __init__(self, backend_client: BackendClient, local_data_manager: LocalDataManager):
        self.__backend_client = backend_client
        self.__local_data_manager = local_data_manager

    def load_original_video(self, video_id: str):
        video_data = self.__backend_client.fetch_video(video_id)

        self.__local_data_manager.write_binary(
            os.path.join("original", video_id + ".mp4"),
            video_data
        )
