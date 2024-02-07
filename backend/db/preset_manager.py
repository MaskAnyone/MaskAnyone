from db.db_connection import DBConnection
from db.model.preset import Preset
import json


class PresetManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_presets(self, user_id: str):
        result = []

        preset_data_list = self.__db_connection.select_all(
            "SELECT * FROM presets WHERE user_id=%(user_id)s",
            {"user_id": user_id}
        )

        for preset_data in preset_data_list:
            result.append(Preset(*preset_data))

        return result

    def create_new_preset(self, id: str, name: str, description: str, data: dict, user_id: str):
        self.__db_connection.execute(
            "INSERT INTO presets (id, name, description, data, user_id) VALUES (%(id)s, %(name)s, %(description)s, %(data)s, %(user_id)s)",
            {
                "id": id,
                "name": name,
                "description": description,
                "data": json.dumps(data),
                "user_id": user_id,
            },
        )

    def delete_preset(self, id: str):
        self.__db_connection.execute(
            "DELETE FROM presets WHERE id=%(id)s",
            {
                "id": id,
            }
        )

    def assert_user_has_preset(self, id: str, user_id: str):
        result = self.__db_connection.select_all(
            "SELECT id FROM presets WHERE id=%(id)s AND user_id=%(user_id)s", {"id": id, "user_id": user_id}
        )

        if len(result) == 0:
            raise Exception("User does not have preset with id " + id)
