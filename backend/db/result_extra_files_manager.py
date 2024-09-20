import json

from db.db_connection import DBConnection
from db.model.result_extra_file import ResultExtraFile


class ResultExtraFilesManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_result_extra_files_entry(
        self,
        id: str,
        result_video_id: str,
        video_id: str,
        job_id: str,
        type: str,
        data: bytes,
    ):
        self.__db_connection.execute(
            "INSERT INTO result_extra_files (id, result_video_id, video_id, job_id, data, type) VALUES (%(id)s, %(result_video_id)s, %(video_id)s, %(job_id)s, %(data)s, %(type)s)",
            {
                "id": id,
                "result_video_id": result_video_id,
                "video_id": video_id,
                "job_id": job_id,
                "data": data,
                "type": type,
            },
        )

    def fetch_result_extra_files_entry(self, extra_file_id: str):
        result_extra_files_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_extra_files WHERE id=%(id)s", {"id": extra_file_id}
        )

        if len(result_extra_files_data_list) < 1:
            raise Exception("Could not find extra files entry with id " + extra_file_id)

        return ResultExtraFile(*result_extra_files_data_list[0])

    def find_entries(self, result_video_id: str):
        result = []

        result_extra_files_data_list = self.__db_connection.select_all(
            "SELECT id, ending FROM result_extra_files WHERE result_video_id=%(result_video_id)s",
            {"result_video_id": result_video_id},
        )

        for result_extra_files_data in result_extra_files_data_list:
            result.append(
                {"id": result_extra_files_data[0], "ending": result_extra_files_data[1]}
            )

        return result
