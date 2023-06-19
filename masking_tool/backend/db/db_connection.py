import psycopg2
import os


class DBConnection:
    def __init__(self):
        self.__connection = psycopg2.connect(
            database=os.environ['BACKEND_PG_DATABASE'],
            user=os.environ['BACKEND_PG_USER'],
            password=os.environ['BACKEND_PG_PASSWORD'],
            host=os.environ['BACKEND_PG_HOST'],
            port=os.environ['BACKEND_PG_PORT']
        )

    def execute(self, sql: str):
        cursor = self.__connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall()
