from backend_client import BackendClient
from local_data_manager import LocalDataManager
import os

from config import TS_BASE_PATH


class VideoManager:
    __backend_client: BackendClient
    __local_data_manager: LocalDataManager

    def __init__(
        self, backend_client: BackendClient, local_data_manager: LocalDataManager
    ):
        self.__backend_client = backend_client
        self.__local_data_manager = local_data_manager

    def load_original_video(self, video_id: str):
        video_data = self.__backend_client.fetch_video(video_id)
        self.__local_data_manager.write_binary(
            os.path.join("original", video_id + ".mp4"), video_data
        )

    def upload_result_video(self, video_id: str, result_video_id: str):
        path = os.path.join("results", video_id + ".mp4")
        if self.__local_data_manager.path_exists(path):
            video_data = self.__local_data_manager.read_binary(path)
            self.__backend_client.upload_result_video(
                video_id, result_video_id, video_data
            )

    def upload_result_video_preview_image(self, video_id: str, result_video_id: str):
        path = os.path.join("results", video_id + ".png")
        if self.__local_data_manager.path_exists(path):
            image_data = self.__local_data_manager.read_binary(path)
            self.__backend_client.upload_result_video_preview_image(
                video_id, result_video_id, image_data
            )

    def upload_result_kinematics(self, video_id: str, result_video_id):
        possible_timeseries = ["body", "face"]
        for part in possible_timeseries:
            path = os.path.join("timeseries", part + "_" + video_id + ".json")
            if self.__local_data_manager.path_exists(path):
                data = self.__local_data_manager.read_json(path)
                self.__backend_client.upload_result_mp_kinematics(
                    video_id, result_video_id, data, part
                )

    def upload_result_blendshapes(self, video_id: str, result_video_id):
        path = os.path.join("blendshapes", video_id + ".json")
        if self.__local_data_manager.path_exists(path):
            data = self.__local_data_manager.read_json(path)

            self.__backend_client.upload_result_blendshapes(
                video_id, result_video_id, data
            )

    def cleanup_result_video_files(self, video_id: str):
        result_path = os.path.join("results", video_id + ".mp4")
        preview_path = os.path.join("results", video_id + ".png")
        if os.path.exists(result_path):
            self.__local_data_manager.delete_file(result_path)
        if os.path.exists(preview_path):
            self.__local_data_manager.delete_file(preview_path)
