import logging
import os
import time

import psycopg2

logger = logging.getLogger(__name__)


class DBConnection:
    def __init__(self):
        last_error = None
        for attempt in range(10):
            try:
                self.__connection = psycopg2.connect(
                    database=os.environ["BACKEND_PG_DATABASE"],
                    user=os.environ["BACKEND_PG_USER"],
                    password=os.environ["BACKEND_PG_PASSWORD"],
                    host=os.environ["BACKEND_PG_HOST"],
                    port=os.environ["BACKEND_PG_PORT"],
                )
                return
            except psycopg2.OperationalError as e:
                last_error = e
                logger.warning(f"Postgres not ready (attempt {attempt + 1}/10), retrying in 3s...")
                time.sleep(3)
        raise last_error

    def execute(self, sql: str, bindings: dict | None = None):
        if bindings is None:
            bindings = {}
        cursor = self.__connection.cursor()

        try:
            cursor.execute(sql, bindings)
            self.__connection.commit()
        except psycopg2.Error as e:
            self.__connection.rollback()
            logger.error(f"Database execute error: {e}")
            raise
        finally:
            cursor.close()

    def select_all(self, sql: str, bindings: dict | None = None) -> list:
        if bindings is None:
            bindings = {}
        cursor = self.__connection.cursor()

        try:
            cursor.execute(sql, bindings)
            result = cursor.fetchall()
            return result
        except psycopg2.Error as e:
            self.__connection.rollback()
            logger.error(f"Database select error: {e}")
            raise
        finally:
            cursor.close()

    def get_cursor(self):
        return self.__connection.cursor()
