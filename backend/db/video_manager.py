from db.db_connection import DBConnection
from db.model.video import Video
import json


class VideoManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_videos(self, user_id: str):
        result = []

        video_data_list = self.__db_connection.select_all(
            "SELECT * FROM videos WHERE status=%(status)s AND user_id=%(user_id)s",
            {"status": "valid", "user_id": user_id},
        )

        for video_data in video_data_list:
            result.append(Video(*video_data))

        return result

    def has_video_with_name(self, video_name: str, user_id: str) -> bool:
        result = self.__db_connection.select_all(
            "SELECT id FROM videos WHERE name=%(name)s AND user_id=%(user_id)s", {"name": video_name, "user_id": user_id}
        )

        return len(result) > 0

    def add_pending_video(self, id: str, name: str, user_id: str):
        self.__db_connection.execute(
            "INSERT INTO videos (id, name, status, user_id) VALUES (%(id)s, %(name)s, %(status)s, %(user_id)s)",
            {"id": id, "name": name, "status": "pending", "user_id": user_id},
        )

    def set_video_to_valid(self, id: str, video_info: dict):
        self.__db_connection.execute(
            "UPDATE videos SET status=%(status)s, video_info=%(video_info)s WHERE id=%(id)s",
            {"id": id, "status": "valid", "video_info": json.dumps(video_info)},
        )

    def assert_user_has_video(self, video_id: str, user_id: str):
        result = self.__db_connection.select_all(
            "SELECT id FROM videos WHERE id=%(video_id)s AND user_id=%(user_id)s", {"video_id": video_id, "user_id": user_id}
        )

        if len(result) == 0:
            raise Exception("User does not have video with id " + video_id)

    def delete_video(self, video_id: str):
        self.__db_connection.execute(
            "DELETE FROM videos WHERE id=%(video_id)s",
            {"video_id": video_id},
        )
