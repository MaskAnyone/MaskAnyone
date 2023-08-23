import os
import gdown

model_base_path = "/AlphaPose"

id = "1D47msNOOiJKvPOXlnpyzdKA3k6E97NTC"
output_path = os.path.join(
    model_base_path, "detector", "yolo", "data", "yolov3-spp.weights"
)
gdown.download(id=id, output=output_path, quiet=False)

id = "1Bb3kPoFFt-M0Y3ceqNO8DTXi1iNDd4gI"  # multidomain fast pose
output_path = os.path.join(
    model_base_path, "pretrained_models", "multi_domain_fast50_regression_256x192.pth"
)
gdown.download(id=id, output=output_path, quiet=False)


id = "16Y_MGUynFeEzV8GVtKTE5AtkHSi3xsF9"  # hybrIK
output_path = os.path.join(model_base_path, "pretrained_models", "pretrained_w_cam.pth")
gdown.download(id=id, output=output_path, quiet=False)
