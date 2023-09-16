from db.db_connection import DBConnection
from db.model.preset import Preset
import json


class PresetManager:
    def __init__(self, db_connection: DBConnection):
        self.__db_connection = db_connection

    def fetch_presets(self):
        result = []

        preset_data_list = self.__db_connection.select_all(
            "SELECT * FROM presets"
        )

        for preset_data in preset_data_list:
            result.append(Preset(*preset_data))

        return result

    def create_new_preset(self, id: str, name: str, description: str, data: dict):
        self.__db_connection.execute(
            "INSERT INTO presets (id, name, description, data) VALUES (%(id)s, %(name)s, %(description)s, %(data)s)",
            {
                "id": id,
                "name": name,
                "description": description,
                "data": json.dumps(data),
            },
        )

    def delete_preset(self, id: str):
        self.__db_connection.execute(
            "DELETE FROM presets WHERE id=%(id)s",
            {
                "id": id,
            }
        )
