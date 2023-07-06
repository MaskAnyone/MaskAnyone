import os


class LocalDataManager:
    __base_dir: str

    def __init__(self, base_dir: str):
        self.__base_dir = base_dir

        if not os.path.exists(self.__base_dir):
            os.makedirs(self.__base_dir)
            os.makedirs(os.path.join(self.__base_dir, "original"))
            os.makedirs(os.path.join(self.__base_dir, "results"))

    def write_binary(self, file_path: str, content):
        file = open(os.path.join(self.__base_dir, file_path), "wb")
        file.write(content)
        file.close()

    def read_binary(self, file_path: str):
        file = open(os.path.join(self.__base_dir, file_path), "rb")
        content = file.read()
        file.close()
        return content

    def delete_file(self, file_path: str):
        os.remove(os.path.join(self.__base_dir, file_path))
