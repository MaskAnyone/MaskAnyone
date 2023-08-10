import os
from huggingface_hub import hf_hub_download

"""if not os.path.exists("/app/Retrieval-based-Voice-Conversion-WebUI"):
    raise Exception("RVC not installed properly")

os.mkdir(
    "/app/Retrieval-based-Voice-Conversion-WebUI/uvr5_weights/onnx_dereverb_By_FoxJoy"
)"""

repo_id = "lj1995/VoiceConversionWebUI"
# model_base_path = "/app/Retrieval-based-Voice-Conversion-WebUI"
model_base_path = "/home/rohan/Documents/model"

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
