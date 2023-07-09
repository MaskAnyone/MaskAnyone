import json

from db.db_connection import DBConnection
from db.model.result_mp_kinematics import ResultMpKinematics


class ResultMpKinematicsManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_result_mp_kinematics_entry(self, id: str, result_video_id: str, video_id: str, job_id: str, type: str, data: dict):
        self.__db_connection.execute(
            "INSERT INTO result_mp_kinematics (id, result_video_id, video_id, job_id, type, data) VALUES (%(id)s, %(result_video_id)s, %(video_id)s, %(job_id)s, %(type)s, %(data)s)",
            {"id": id, "result_video_id": result_video_id, "video_id": video_id, "job_id": job_id, "type": type, "data": json.dumps(data)},
        )

    def fetch_result_mp_kinematics_entry(self, mp_kinematics_id: str):
        result_mp_kinematics_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_mp_kinematics WHERE id=%(id)s",
            {'id': mp_kinematics_id}
        )

        if len(result_mp_kinematics_data_list) < 1:
            raise Exception('Could not find mp kinematics entry with id ' + mp_kinematics_id)

        return ResultMpKinematics(*result_mp_kinematics_data_list[0])

    def find_entries(self, result_video_id: str):
        result = []

        result_mp_kinematics_data_list = self.__db_connection.select_all(
            "SELECT id, type FROM result_mp_kinematics WHERE result_video_id=%(result_video_id)s",
            {'result_video_id': result_video_id}
        )

        for result_mp_kinematics_data in result_mp_kinematics_data_list:
            result.append((result_mp_kinematics_data[0], result_mp_kinematics_data[1]))

        return result
