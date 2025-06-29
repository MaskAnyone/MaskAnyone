import torch
import sys
import os

sys.path.append('/workspace/segment-anything-2')
from sam2.build_sam import build_sam2_video_predictor

predictor = None

SAM2_OFFLOAD_VIDEO_TO_CPU = os.environ["SAM2_OFFLOAD_VIDEO_TO_CPU"] == "true"
SAM2_OFFLOAD_STATE_TO_CPU = os.environ["SAM2_OFFLOAD_STATE_TO_CPU"] == "true"


def perform_sam2_segmentation(frame_dir_path: str, pose_prompts):
    video_segments = {}
    for frame_idx, frame_masks in perform_sam2_segmentation_yielding(frame_dir_path, pose_prompts):
        video_segments[frame_idx] = frame_masks
    return video_segments


def perform_sam2_segmentation_yielding(video_path: str, pose_prompts):
    global predictor

    configure_torch()
    torch.cuda.empty_cache()
    if predictor is None:
        sam2_checkpoint = "/workspace/sam2/checkpoints/sam2.1_hiera_small.pt"
        model_cfg = "configs/sam2.1/sam2.1_hiera_s.yaml"
        predictor = build_sam2_video_predictor(model_cfg, sam2_checkpoint)

    print(f"Initializing SAM2 predictor with flags: "
          f"offload_video_to_cpu={SAM2_OFFLOAD_VIDEO_TO_CPU}, "
          f"offload_state_to_cpu={SAM2_OFFLOAD_STATE_TO_CPU}, "
          f"async_loading_frames=True")

    inference_state = predictor.init_state(
        video_path=video_path,
        offload_video_to_cpu=SAM2_OFFLOAD_VIDEO_TO_CPU,
        offload_state_to_cpu=SAM2_OFFLOAD_STATE_TO_CPU,
        async_loading_frames=True,
    )

    predictor.reset_state(inference_state)
    torch.cuda.empty_cache()

    for frame_idx, frame_pose_prompts in pose_prompts.items():
        obj_id_list, points_list, labels_list = extract_points_and_labels(frame_pose_prompts)

        for obj_id, points, labels in zip(obj_id_list, points_list, labels_list):
            _, out_obj_ids, out_mask_logits = predictor.add_new_points(
                inference_state=inference_state,
                frame_idx=int(frame_idx),
                obj_id=obj_id,
                points=points,
                labels=labels,
            )

    for out_frame_idx, out_obj_ids, out_mask_logits in predictor.propagate_in_video(inference_state):
        frame_masks = {
            out_obj_id: (out_mask_logits[i] > 0.0).cpu().numpy()
            for i, out_obj_id in enumerate(out_obj_ids)
        }
        yield out_frame_idx, frame_masks

    predictor.reset_state(inference_state)
    torch.cuda.empty_cache()


def configure_torch():
    # use bfloat16
    torch.autocast(device_type="cuda", dtype=torch.bfloat16).__enter__()

    if torch.cuda.get_device_properties(0).major >= 8:
        # turn on tfloat32 for Ampere GPUs (https://pytorch.org/docs/stable/notes/cuda.html#tensorfloat-32-tf32-on-ampere-devices)
        torch.backends.cuda.matmul.allow_tf32 = True
        torch.backends.cudnn.allow_tf32 = True


def extract_points_and_labels(pose_prompts):
    # Initialize two empty lists to store the separated data
    obj_ids = []
    points = []
    labels = []

    obj_id = 0
    # Iterate through each sublist in the input list
    for pose_prompt in pose_prompts:
        # Separate coordinates and labels in each sublist
        points_sublist = []
        labels_sublist = []
        obj_id += 1

        for point in pose_prompt:
            points_sublist.append(point[:2])  # Take the first two elements
            labels_sublist.append(point[2])   # Take the last element

        # If the prompt is empty (no points) we ignore it and do not pass it to the model
        if len(points_sublist) < 1:
            continue

        # Append the processed sublists to the main lists
        points.append(points_sublist)
        labels.append(labels_sublist)
        obj_ids.append(obj_id)

    return obj_ids, points, labels
