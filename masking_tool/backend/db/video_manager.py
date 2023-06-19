from db.db_connection import DBConnection
from db.model.video import Video


class VideoManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_videos(self):
        result = []

        video_data_list = self.__db_connection.execute(
            'SELECT * FROM videos'
        )

        for video_data in video_data_list:
            result.append(Video(*video_data))

        return result
