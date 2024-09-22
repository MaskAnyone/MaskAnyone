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
            self._get_original_video_path(video_id),
            video_data
        )

    def upload_result_video(self, video_id: str, result_video_id: str):
        path = self._get_output_video_path(video_id)

        if self.__local_data_manager.path_exists(path):
            video_data = self.__local_data_manager.read_binary(path)
            self.__backend_client.upload_result_video(
                video_id, result_video_id, video_data
            )
        else:
            print('WARNING: result video file does not exist')

    def upload_result_video_preview_image(self, video_id: str, result_video_id: str):
        path = self._get_output_video_path(video_id).replace(".mp4", ".png")

        if self.__local_data_manager.path_exists(path):
            image_data = self.__local_data_manager.read_binary(path)
            self.__backend_client.upload_result_video_preview_image(
                video_id, result_video_id, image_data
            )
        else:
            print('WARNING: result video preview image file does not exist')

    def upload_result_mp_kinematics(self, video_id: str, result_video_id):
        path = self._get_output_video_path(video_id).replace(".mp4", ".json")

        if self.__local_data_manager.path_exists(path):
            data = self.__local_data_manager.read_json(path)
            self.__backend_client.upload_result_mp_kinematics(
                video_id, result_video_id, data
            )

    def upload_result_data(self, video_id: str, result_video_id, data_type: str):
        path = self._get_result_data_path(video_id, data_type)

        if self.__local_data_manager.path_exists(path):
            result_data = self.__local_data_manager.read_json(path) if data_type == 'poses' else self.__local_data_manager.read_binary(path)

            self.__backend_client.upload_result_data(
                video_id, result_video_id, data_type, result_data
            )
        else:
            print(f'WARNING: result data file {data_type} does not exist')

    def get_original_video_path(self, video_id: str):
        return os.path.join(self.__local_data_manager.get_base_dir(), self._get_original_video_path(video_id))

    def get_output_video_path(self, video_id: str):
        return os.path.join(self.__local_data_manager.get_base_dir(), self._get_output_video_path(video_id))

    def get_result_mp_kinematics_path(self, video_id: str):
        return os.path.join(self.__local_data_manager.get_base_dir(), "timeseries", "body_" + video_id + ".json")

    def get_result_data_path(self, video_id: str, data_type: str) -> str:
        return os.path.join(self.__local_data_manager.get_base_dir(), self._get_result_data_path(video_id, data_type))

    def _get_original_video_path(self, video_id: str) -> str:
        return os.path.join("original", video_id + ".mp4")

    def _get_output_video_path(self, video_id: str) -> str:
        return os.path.join("results", video_id + ".mp4")

    def _get_result_data_path(self, video_id: str, data_type: str) -> str:
        return self._get_output_video_path(video_id).replace(".mp4", "_" + data_type)

