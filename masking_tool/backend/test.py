from db.video_manager import VideoManager
from db.db_connection import DBConnection

video_manager = VideoManager(DBConnection())
print(video_manager.fetch_videos())