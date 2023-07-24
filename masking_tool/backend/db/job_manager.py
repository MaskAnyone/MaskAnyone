import uuid
from db.db_connection import DBConnection
from db.model.job import Job
import json


class JobManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_jobs(self):
        result = []

        job_data_list = self.__db_connection.select_all(
            "SELECT * FROM jobs ORDER BY created_at DESC"
        )

        for job_data in job_data_list:
            result.append(Job(*job_data))

        return result

    def create_new_jobs(
        self,
        id: str,
        video_ids: list[str],
        result_video_id: str,
        data: dict,
        job_type: str,
    ):
        for idx, video_id in enumerate(video_ids):
            if idx == 0:
                job_id = id
            else:
                job_id = str(uuid.uuid4())
            self.__db_connection.execute(
                "INSERT INTO jobs (id, video_id, result_video_id, type, status, data, created_at) VALUES (%(id)s, %(video_id)s, %(result_video_id)s, %(type)s, %(status)s, %(data)s, current_timestamp)",
                {
                    "id": job_id,
                    "video_id": video_id,
                    "result_video_id": result_video_id,
                    "type": job_type,
                    "status": "open",
                    "data": json.dumps(data),
                },
            )

    def fetch_next_job(self, job_type: str):
        # @todo make this nice
        cursor = self.__db_connection.get_cursor()
        jobs = []

        try:
            cursor.execute("BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ")
            cursor.execute(
                "SELECT * FROM jobs WHERE status=%(status)s AND type=%(job_type)s LIMIT 1",
                {"status": "open", "job_type": job_type},
            )
            jobs = cursor.fetchall()

            if len(jobs) > 0:
                cursor.execute(
                    "UPDATE jobs SET status=%(status)s, started_at=current_timestamp WHERE id=%(id)s",
                    {"status": "running", "id": jobs[0][0]},
                )

            cursor.execute("COMMIT")
        except Exception as error:
            cursor.execute("ROLLBACK")
            raise error
        finally:
            cursor.close()

        return None if len(jobs) < 1 else Job(*jobs[0])

    def fetch_job_by_result_video_id(self, result_video_id: str) -> Job:
        job_data_list = self.__db_connection.select_all(
            "SELECT * FROM jobs WHERE result_video_id=%(result_video_id)s",
            {"result_video_id": result_video_id},
        )

        if len(job_data_list) < 1:
            raise Exception("Could not find job for result video " + result_video_id)

        return Job(*job_data_list[0])

    def update_job_progress(self, job_id: str, progress: int):
        self.__db_connection.execute(
            "UPDATE jobs SET progress=%(progress)s WHERE id=%(id)s",
            {"progress": progress, "id": job_id},
        )

    def mark_job_as_finished(self, job_id: str):
        self.__db_connection.execute(
            "UPDATE jobs SET status=%(status)s, finished_at=current_timestamp, progress=100 WHERE id=%(id)s",
            {"status": "finished", "id": job_id},
        )

    def mark_job_as_failed(self, job_id: str):
        self.__db_connection.execute(
            "UPDATE jobs SET status=%(status)s, finished_at=current_timestamp, progress=100 WHERE id=%(id)s",
            {"status": "failed", "id": job_id},
        )
