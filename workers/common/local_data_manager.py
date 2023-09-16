import os
import json


class LocalDataManager:
    __base_dir: str

    def __init__(self, base_dir: str):
        self.__base_dir = base_dir

        if not os.path.exists(self.__base_dir):
            os.makedirs(self.__base_dir)
            os.makedirs(os.path.join(self.__base_dir, "original"))
            os.makedirs(os.path.join(self.__base_dir, "results"))
            os.makedirs(os.path.join(self.__base_dir, "timeseries"))

    def path_exists(self, path):
        return os.path.exists(os.path.join(self.__base_dir, path))

    def write_binary(self, file_path: str, content):
        to_path = os.path.join(self.__base_dir, file_path)
        file = open(to_path, "wb")
        file.write(content)
        file.close()
        return to_path

    def read_binary(self, file_path: str):
        file = open(os.path.join(self.__base_dir, file_path), "rb")
        content = file.read()
        file.close()
        return content

    def read_json(self, file_path: str):
        with open(os.path.join(self.__base_dir, file_path), "r") as f:
            content = json.load(f)
            return content

    def delete_file(self, file_path: str):
        os.remove(os.path.join(self.__base_dir, file_path))
