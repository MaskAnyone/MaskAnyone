from db.db_connection import DBConnection
from db.model.result_video import ResultVideo


class ResultVideoManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_result_videos(self, video_id: str):
        result = []

        result_video_data_list = self.__db_connection.select_all(
            "SELECT * FROM result_videos WHERE video_id=%(video_id)s",
            { 'video_id': video_id }
        )

        for result_video_data in result_video_data_list:
            result.append(ResultVideo(*result_video_data))

        return result
