import os
import gdown
from huggingface_hub import hf_hub_download
from zipfile import ZipFile
import shutil

if not os.path.exists("/Retrieval-based-Voice-Conversion-WebUI"):
    raise Exception("RVC not installed properly")

os.mkdir("/Retrieval-based-Voice-Conversion-WebUI/uvr5_weights/onnx_dereverb_By_FoxJoy")

repo_id = "lj1995/VoiceConversionWebUI"
model_base_path = "/Retrieval-based-Voice-Conversion-WebUI"

hf_hub_download(
    repo_id=repo_id,
    filename="hubert_base.pt",
    local_dir=os.path.join(model_base_path),
)
pretrained_files = [
    "D48k.pth",
    "f0G48k.pth",
    "f0D40k.pth",
    "f0G32k.pth",
    "G48k.pth",
    "D32k.pth",
    "f0D48k.pth",
    "D40k.pth",
    "G40k.pth",
    "f0G40k.pth",
    "G32k.pth",
    "f0D32k.pth",
]


for f in pretrained_files:
    hf_hub_download(
        repo_id=repo_id,
        filename=f,
        subfolder="pretrained",
        local_dir=os.path.join(model_base_path),
    )

uvr5_weights_files = [
    "HP3_all_vocals.pth",
    "HP5-主旋律人声vocals+其他instrumentals.pth",
    "VR-DeEchoDeReverb.pth",
    "VR-DeEchoNormal.pth",
    "HP2_all_vocals.pth",
    "VR-DeEchoAggressive.pth",
    "HP2-人声vocals+非人声instrumentals.pth",
    "HP5_only_main_vocal.pth",
]


for f in uvr5_weights_files:
    hf_hub_download(
        repo_id=repo_id,
        filename=f,
        subfolder="uvr5_weights",
        local_dir=os.path.join(model_base_path),
    )

onnx_dereverb_files = ["vocals.onnx"]
for f in onnx_dereverb_files:
    hf_hub_download(
        repo_id=repo_id,
        filename=f,
        subfolder="uvr5_weights/onnx_dereverb_By_FoxJoy",
        local_dir=os.path.join(model_base_path),
    )

id = "1yCb7d9RH-8GV0rH8fllqLeoBqF5bgBz0"  # ariana grande voice
output_path = os.path.join(model_base_path, "weights", "voice.zip")
gdown.download(id=id, output=output_path, quiet=False)
store_path = os.path.join(model_base_path, "weights", "arianaGrande")
os.mkdir(store_path)
with ZipFile(output_path, "r") as zObject:
    zObject.extractall(store_path)
    os.rename(
        os.path.join(store_path, "arianagrandev2.pth"),
        os.path.join(store_path, "model.pth"),
    )
    os.rename(
        os.path.join(store_path, "added_IVF1033_Flat_nprobe_1_v2.index"),
        os.path.join(store_path, "index_file.pth"),
    )

id = "1JNV7cleePeQZRSoz4xTtei_QbZ0SPr0X"  # kanye
output_path = os.path.join(model_base_path, "weights", "voice2.zip")
gdown.download(id=id, output=output_path, quiet=False)
store_path = os.path.join(model_base_path, "weights", "kanyeWest")
os.mkdir(store_path)
with ZipFile(output_path, "r") as zObject:
    zObject.extractall(store_path)
    shutil.copyfile(
        os.path.join(store_path, "weights", "KanyeV2_Redux_40khz.pth"),
        os.path.join(store_path, "model.pth"),
    )
    shutil.copyfile(
        os.path.join(
            store_path,
            "logs",
            "KanyeV2_Redux_40khz",
            "added_IVF1663_Flat_nprobe_1_KanyeV2_Redux_40khz_v2.index",
        ),
        os.path.join(
            store_path,
            "index_file.index",
        ),
    )

id = "1Ny2aZ5xea1mIS92EPyfuDpcl4a5niaZN"  # mrKrabs
output_path = os.path.join(model_base_path, "weights", "voice3.zip")
gdown.download(id=id, output=output_path, quiet=False)
store_path = os.path.join(model_base_path, "weights", "mrKrabs")
os.mkdir(store_path)
with ZipFile(output_path, "r") as zObject:
    zObject.extractall(store_path)
    shutil.copyfile(
        os.path.join(store_path, "MrKrabs", "weights", "MrKrabs.pth"),
        os.path.join(store_path, "model.pth"),
    )
    shutil.copyfile(
        os.path.join(
            store_path,
            "MrKrabs",
            "logs",
            "MrKrabs",
            "added_IVF1490_Flat_nprobe_1.index",
        ),
        os.path.join(store_path, "index_file.index"),
    )

id = "1Q5dJ9w_H2RG1vMLHBx4UsAlmcrgmN6_e"  # donald trump
output_path = os.path.join(model_base_path, "weights", "voice4.zip")
gdown.download(id=id, output=output_path, quiet=False)
store_path = os.path.join(model_base_path, "weights", "donaldTrump")
os.mkdir(store_path)
with ZipFile(output_path, "r") as zObject:
    zObject.extractall(store_path)
    os.rename(
        os.path.join(store_path, "trump.pth"),
        os.path.join(store_path, "model.pth"),
    )
    os.rename(
        os.path.join(store_path, "added_IVF2572_Flat_nprobe_1_v2.index"),
        os.path.join(store_path, "index_file.pth"),
    )
