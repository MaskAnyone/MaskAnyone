import psycopg2


class DBConnection:
    def __init__(self):
        # @todo move to env
        self.__connection = psycopg2.connect(
            database="prototype",
            user="dev",
            password="dev",
            host="postgres",
            port='5432'
        )

    def execute(self, sql: str):
        cursor = self.__connection.cursor()
        cursor.execute(sql)
        return cursor.fetchall()
