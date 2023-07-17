import json

from db.db_connection import DBConnection
from db.model.result_blendshapes import ResultBlendshapes


class ResultBlendshapesManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_result_mp_kinematics_entry(
        self, id: str, result_video_id: str, video_id: str, job_id: str, data: dict
    ):
        self.__db_connection.execute(
            "INSERT INTO result_blendshapes (id, result_video_id, video_id, job_id, data) VALUES (%(id)s, %(result_video_id)s, %(video_id)s, %(job_id)s, %(data)s)",
            {
                "id": id,
                "result_video_id": result_video_id,
                "video_id": video_id,
                "job_id": job_id,
                "data": json.dumps(data),
            },
        )

    def fetch_result_blendshapes_entry(self, blendshapes_id: str):
        result_blendshapes_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_blendshapes WHERE id=%(id)s", {"id": blendshapes_id}
        )

        if len(result_blendshapes_data_list) < 1:
            raise Exception(
                "Could not find blendshapes entry with id " + blendshapes_id
            )

        return ResultBlendshapes(*result_blendshapes_data_list[0])

    def fetch_result_blendshapes_entry_by_resvid_id(self, result_video_id: str):
        result_blendshapes_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_blendshapes WHERE result_video_id=%(result_video_id)s",
            {"result_video_id": result_video_id},
        )

        if not result_blendshapes_data_list:
            raise Exception(
                f"No blendshapes for result video id {result_video_id} found"
            )

        return ResultBlendshapes(*result_blendshapes_data_list[0])

    def find_entries(self, result_video_id: str):
        result = []

        result_blendshapes_data_list = self.__db_connection.select_all(
            "SELECT id FROM result_blendshapes WHERE result_video_id=%(result_video_id)s",
            {"result_video_id": result_video_id},
        )

        for result_blendshapes_data in result_blendshapes_data_list:
            result.append(result_blendshapes_data[0])

        return result
