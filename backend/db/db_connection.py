import psycopg2
import os


class DBConnection:
    def __init__(self):
        self.__connection = psycopg2.connect(
            database=os.environ["BACKEND_PG_DATABASE"],
            user=os.environ["BACKEND_PG_USER"],
            password=os.environ["BACKEND_PG_PASSWORD"],
            host=os.environ["BACKEND_PG_HOST"],
            port=os.environ["BACKEND_PG_PORT"],
        )

    def execute(self, sql: str, bindings: dict = {}):
        cursor = self.__connection.cursor()

        try:
            cursor.execute(sql, bindings)
            self.__connection.commit()
        except psycopg2.Error as e:
            self.__connection.rollback()
            raise e
        finally:
            cursor.close()

    def select_all(self, sql: str, bindings: dict = {}):
        cursor = self.__connection.cursor()

        try:
            cursor.execute(sql, bindings)
            result = cursor.fetchall()
            return result
        except psycopg2.Error as e:
            self.__connection.rollback()
            raise e
        finally:
            cursor.close()

    def get_cursor(self):
        return self.__connection.cursor()
