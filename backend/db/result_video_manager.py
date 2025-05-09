import json

from db.db_connection import DBConnection
from db.model.result_video import ResultVideo


class ResultVideoManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_result_video(
        self, id: str, video_id: str, job_id: str, name: str, video_info: dict
    ):
        self.__db_connection.execute(
            "INSERT INTO result_videos (id, video_id, job_id, video_info, created_at, name) VALUES (%(id)s, %(video_id)s, %(job_id)s, %(video_info)s, current_timestamp, %(name)s)",
            {
                "id": id,
                "video_id": video_id,
                "job_id": job_id,
                "video_info": json.dumps(video_info),
                "name": name,
            },
        )

    def fetch_result_videos(self, video_id: str):
        result = []

        result_video_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_videos WHERE video_id=%(video_id)s ORDER BY created_at DESC",
            {"video_id": video_id},
        )

        for result_video_data in result_video_data_list:
            result.append(ResultVideo(*result_video_data))

        return result

    def get_result_video(self, id: str):
        result_video_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_videos WHERE id=%(id)s",
            {"id": id},
        )

        if len(result_video_data_list) < 1:
            raise Exception("Could not find result video with id " + id)

        return ResultVideo(*result_video_data_list[0])

    def delete_result_video(self, id: str):
        self.__db_connection.execute(
            "DELETE FROM result_videos WHERE id=%(id)s",
            {"id": id},
        )
