import torch
import sys

#sys.path.append('/workspace')
sys.path.append('/workspace/segment-anything-2')
#sys.path.append('/workspace/segment-anything-2/sam2')

from sam2.build_sam import build_sam2_video_predictor


def perform_sam2_segmentation(frame_dir_path: str, sam2_prompt):
    configure_torch()

    sam2_checkpoint = "/workspace/segment-anything-2/checkpoints/sam2_hiera_tiny.pt"
    model_cfg = "sam2_hiera_t.yaml"
    predictor = build_sam2_video_predictor(model_cfg, sam2_checkpoint)

    try:
        inference_state = predictor.init_state(video_path=frame_dir_path)
        predictor.reset_state(inference_state)

        _, out_obj_ids, out_mask_logits = predictor.add_new_points(
            inference_state=inference_state,
            frame_idx=0,
            obj_id=1,
            points=[[100, 100]],
            labels=[1],
        )

        print(out_obj_ids, out_mask_logits)
    finally:
        pass


def configure_torch():
    # use bfloat16
    torch.autocast(device_type="cuda", dtype=torch.bfloat16).__enter__()

    if torch.cuda.get_device_properties(0).major >= 8:
        # turn on tfloat32 for Ampere GPUs (https://pytorch.org/docs/stable/notes/cuda.html#tensorfloat-32-tf32-on-ampere-devices)
        torch.backends.cuda.matmul.allow_tf32 = True
        torch.backends.cudnn.allow_tf32 = True
