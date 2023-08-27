from common.backend_client import BackendClient
from common.local_data_manager import LocalDataManager
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

    def load_result_video(self, job_id: str):
        # download a result video of a job from the backend
        video_data = self.__backend_client.fetch_result_video(job_id)
        local_path = self.__local_data_manager.write_binary(
            os.path.join("results", job_id + "_docker_res.mp4"), video_data
        )
        return local_path

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

    def upload_result_audio_file(self, video_id: str, result_video_id):
        path = os.path.join("results", video_id + ".mp3")
        if self.__local_data_manager.path_exists(path):
            data = self.__local_data_manager.read_binary(path)

            self.__backend_client.upload_result_audio_file(
                video_id, result_video_id, data
            )

    def upload_result_extra_file(
        self, video_id: str, file_ending: str, result_video_id: str
    ):
        print("a1")
        path = os.path.join("results", video_id + "." + file_ending)
        if self.__local_data_manager.path_exists(path):
            print("a2")
            data = self.__local_data_manager.read_binary(path)
            print("a3")

            self.__backend_client.upload_result_extra_file(
                video_id, file_ending, result_video_id, data
            )

    def cleanup_result_video_files(self, video_id: str):
        result_path = os.path.join("results", video_id + ".mp4")
        preview_path = os.path.join("results", video_id + ".png")
        if os.path.exists(result_path):
            self.__local_data_manager.delete_file(result_path)
        if os.path.exists(preview_path):
            self.__local_data_manager.delete_file(preview_path)
