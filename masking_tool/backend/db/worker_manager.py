from db.db_connection import DBConnection
from db.model.job import Job
import json


class WorkerManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def register_worker(self, id: str):
        self.__db_connection.execute(
            "INSERT INTO workers (id, last_activity) VALUES (%(id)s, current_timestamp)",
            {
                "id": id,
            },
        )

    def update_worker_activity(self,  id: str):
        self.__db_connection.execute(
            "UPDATE workers SET last_activity=current_timestamp WHERE id=%(id)s",
            {
                "id": id,
            },
        )
