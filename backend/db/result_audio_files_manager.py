import json

from db.db_connection import DBConnection
from db.model.result_audio_file import ResultAudioFile


class ResultAudioFilesManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_result_audio_files_entry(self, id: str, result_video_id: str, video_id: str, job_id: str, data: bytes):
        self.__db_connection.execute(
            "INSERT INTO result_audio_files (id, result_video_id, video_id, job_id, data) VALUES (%(id)s, %(result_video_id)s, %(video_id)s, %(job_id)s, %(data)s)",
            {"id": id, "result_video_id": result_video_id, "video_id": video_id, "job_id": job_id, "data": data},
        )

    def fetch_result_audio_files_entry(self, audio_file_id: str):
        result_audio_files_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_audio_files WHERE id=%(id)s",
            {'id': audio_file_id}
        )

        if len(result_audio_files_data_list) < 1:
            raise Exception('Could not find audio files entry with id ' + audio_file_id)

        return ResultAudioFile(*result_audio_files_data_list[0])

    def find_entries(self, result_video_id: str):
        result = []

        result_audio_files_data_list = self.__db_connection.select_all(
            "SELECT id FROM result_audio_files WHERE result_video_id=%(result_video_id)s",
            {'result_video_id': result_video_id}
        )

        for result_audio_files_data in result_audio_files_data_list:
            result.append(result_audio_files_data[0])

        return result
