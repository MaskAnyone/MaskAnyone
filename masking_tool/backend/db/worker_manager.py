from db.db_connection import DBConnection
from db.model.worker import Worker
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

    def fetch_active_workers(self):
        result = []

        worker_data_list = self.__db_connection.select_all(
            "SELECT * FROM workers where last_activity > NOW() - INTERVAL '3 minutes'"
        )

        for worker_data in worker_data_list:
            result.append(Worker(*worker_data))

        return result
