from db.db_connection import DBConnection
from db.model.video import Video
import json


class VideoManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_videos(self):
        result = []

        video_data_list = self.__db_connection.select_all(
            'SELECT * FROM videos WHERE status=%(status)s',
            {'status': 'valid'}
        )

        for video_data in video_data_list:
            result.append(Video(*video_data))

        return result

    def has_video_with_name(self, video_name: str) -> bool:
        result = self.__db_connection.select_all(
            'SELECT id FROM videos WHERE name=%(name)s',
            {'name': video_name}
        )

        return len(result) > 0

    def add_pending_video(self, id: str, name: str):
        self.__db_connection.execute(
            'INSERT INTO videos (id, name, status) VALUES (%(id)s, %(name)s, %(status)s)',
            {'id': id, 'name': name, 'status': 'pending'}
        )

    def set_video_to_valid(self, id: str, video_info: dict):
        self.__db_connection.execute(
            'UPDATE videos SET status=%(status)s, video_info=%(video_info)s WHERE id=%(id)s',
            {'id': id, 'status': 'valid', 'video_info': json.dumps(video_info)}
        )
