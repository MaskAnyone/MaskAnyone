import os


class LocalDataManager:
    __base_dir: str

    def __init__(self, base_dir: str):
        self.__base_dir = base_dir

        if not os.path.exists(self.__base_dir):
            os.makedirs(self.__base_dir)

    def write_binary(self, file_name: str, content):
        file = open(os.path.join(self.__base_dir, file_name), 'wb')
        file.write(content)
        file.close()
