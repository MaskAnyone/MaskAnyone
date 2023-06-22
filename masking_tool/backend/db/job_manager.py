from db.db_connection import DBConnection
from db.model.job import Job
import json


class JobManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def create_new_job(self, id: str, video_id: str, data: dict):
        self.__db_connection.execute(
            'INSERT INTO jobs (id, video_id, type, status, data, created_at) VALUES (%(id)s, %(video_id)s, %(type)s, %(status)s, %(data)s, current_timestamp)',
            {'id': id, 'video_id': video_id, 'type': 'basic_masking', 'status': 'open', 'data': json.dumps(data)}
        )

    def fetch_next_job(self):
        # @todo For multiple workers this must be a transaction!

        jobs = self.__db_connection.select_all(
            'SELECT * FROM jobs WHERE status=%(status)s LIMIT 1',
            {'status': 'open'}
        )

        if len(jobs) < 1:
            return None

        self.__db_connection.execute(
            'UPDATE jobs SET status=%(status)s, started_at=current_timestamp WHERE id=%(id)s',
            {'status': 'running', 'id': jobs[0][0]}
        )

        return Job(*jobs[0])
