from db.db_connection import DBConnection
from db.model.video import Video
import json

from db.model.result import Result


class VideoManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_videos(self):
        result = []

        video_data_list = self.__db_connection.select_all(
            "SELECT * FROM videos WHERE status=%(status)s", {"status": "valid"}
        )

        for video_data in video_data_list:
            result.append(Video(*video_data))

        return result

    def has_video_with_name(self, video_name: str) -> bool:
        result = self.__db_connection.select_all(
            "SELECT id FROM videos WHERE name=%(name)s", {"name": video_name}
        )

        return len(result) > 0

    def add_pending_video(self, id: str, name: str):
        self.__db_connection.execute(
            "INSERT INTO videos (id, name, status) VALUES (%(id)s, %(name)s, %(status)s)",
            {"id": id, "name": name, "status": "pending"},
        )

    def set_video_to_valid(self, id: str, video_info: dict):
        self.__db_connection.execute(
            "UPDATE videos SET status=%(status)s, video_info=%(video_info)s WHERE id=%(id)s",
            {"id": id, "status": "valid", "video_info": json.dumps(video_info)},
        )

    def fetch_all_results(self, video_id: str):
        result = []

        result_video_data_list = self.__db_connection.select_all(
            """SELECT DISTINCT
            j.result_video_id,
            j.video_id,
            j.id,
            rv.name,
            j.created_at,
            rv.video_info,
            j.data,
            CASE WHEN rv.id IS NOT NULL THEN TRUE ELSE FALSE END as video_result_exists,
            CASE WHEN kr.id IS NOT NULL THEN TRUE ELSE FALSE END as kinematic_results_exists,
            CASE WHEN ar.id IS NOT NULL THEN TRUE ELSE FALSE END as audio_results_exists,
            CASE WHEN br.id IS NOT NULL THEN TRUE ELSE FALSE END as blendshape_results_exists,
            CASE WHEN efr.id IS NOT NULL THEN TRUE ELSE FALSE END as extra_file_results_exists
            FROM
                jobs j
            LEFT JOIN
                result_videos rv ON j.id = rv.job_id
            LEFT JOIN
                result_mp_kinematics kr ON j.id = kr.job_id
            LEFT JOIN
                result_audio_files ar ON j.id = ar.job_id
            LEFT JOIN
                result_blendshapes br ON j.id = br.job_id
            LEFT JOIN
                result_extra_files efr ON j.id = efr.job_id
            WHERE
                j.video_id = %(video_id)s
                AND (rv.id IS NOT NULL
                OR kr.id IS NOT NULL
                OR ar.id IS NOT NULL
                OR br.id IS NOT NULL
                OR efr.id IS NOT NULL)
            ORDER BY j.created_at DESC;""",
            {"video_id": video_id},
        )

        for result_video_data in result_video_data_list:
            result.append(Result(*result_video_data))

        return result
