import json

from db.db_connection import DBConnection
from db.model.result_mp_kinematics import ResultMpKinematics


class ResultMpKinematicsManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_result_mp_kinematics_entry(self, id: str, result_video_id: str, job_id: str, data: dict):
        self.__db_connection.execute(
            "INSERT INTO result_mp_kinematics (id, result_video_id, job_id, data) VALUES (%(id)s, %(result_video_id)s, %(job_id)s, %(data)s)",
            {"id": id, "result_video_id": result_video_id, "job_id": job_id, "data": json.dumps(data)},
        )

    def fetch_result_mp_kinematics_entry(self, result_video_id: str):
        result_mp_kinematics_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_mp_kinematics WHERE result_video_id=%(result_video_id)s",
            {'result_video_id': result_video_id}
        )

        if len(result_mp_kinematics_data_list) > 0:
            return ResultMpKinematics(*result_mp_kinematics_data_list[0])

        return None
