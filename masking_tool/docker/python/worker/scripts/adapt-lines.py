import os

model_base_path = "/Retrieval-based-Voice-Conversion-WebUI"
f_path = os.path.join(model_base_path, "infer_cli.py")

with open(f_path, "r") as file:
    data = file.readlines()

data[45] = "    print(os.path.exists(input_path))\n"
data[46] = "    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxx')\n"
data[47] = "    print(os.listdir('/app/'))\n"

with open(f_path, "w") as file:
    file.writelines(data)
