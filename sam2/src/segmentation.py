import torch
import sys

sys.path.append('/workspace/segment-anything-2')
from sam2.build_sam import build_sam2_video_predictor

predictor = None


def perform_sam2_segmentation(frame_dir_path: str, pose_prompts):
    global predictor

    if predictor is None:
        configure_torch()
        torch.cuda.empty_cache()

        sam2_checkpoint = "/workspace/segment-anything-2/checkpoints/sam2_hiera_large.pt"
        model_cfg = "sam2_hiera_l.yaml"
        predictor = build_sam2_video_predictor(model_cfg, sam2_checkpoint)

    inference_state = predictor.init_state(
        video_path=frame_dir_path,
        offload_video_to_cpu=True,
        offload_state_to_cpu=False,
        async_loading_frames=True,
    )

    predictor.reset_state(inference_state)
    torch.cuda.empty_cache()

    for frame_idx, frame_pose_prompts in pose_prompts.items():
        points_list, labels_list = extract_points_and_labels(frame_pose_prompts)

        obj_id = 1
        for points, labels in zip(points_list, labels_list):
            _, out_obj_ids, out_mask_logits = predictor.add_new_points(
                inference_state=inference_state,
                frame_idx=int(frame_idx),
                obj_id=obj_id,
                points=points,
                labels=labels,
            )
            obj_id += 1

    video_segments = {}
    for out_frame_idx, out_obj_ids, out_mask_logits in predictor.propagate_in_video(inference_state):
        video_segments[out_frame_idx] = {
            out_obj_id: (out_mask_logits[i] > 0.0).cpu().numpy()
            for i, out_obj_id in enumerate(out_obj_ids)
        }

    predictor.reset_state(inference_state)
    torch.cuda.empty_cache()

    return video_segments


def configure_torch():
    # use bfloat16
    torch.autocast(device_type="cuda", dtype=torch.bfloat16).__enter__()

    if torch.cuda.get_device_properties(0).major >= 8:
        # turn on tfloat32 for Ampere GPUs (https://pytorch.org/docs/stable/notes/cuda.html#tensorfloat-32-tf32-on-ampere-devices)
        torch.backends.cuda.matmul.allow_tf32 = True
        torch.backends.cudnn.allow_tf32 = True


def extract_points_and_labels(pose_prompts):
    # Initialize two empty lists to store the separated data
    points = []
    labels = []

    # Iterate through each sublist in the input list
    for pose_prompt in pose_prompts:
        # Separate coordinates and labels in each sublist
        points_sublist = []
        labels_sublist = []
        for point in pose_prompt:
            points_sublist.append(point[:2])  # Take the first two elements
            labels_sublist.append(point[2])   # Take the last element

        if len(points_sublist) < 1:
            continue

        # Append the processed sublists to the main lists
        points.append(points_sublist)
        labels.append(labels_sublist)

    return points, labels
