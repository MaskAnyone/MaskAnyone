import torch
import sys

#sys.path.append('/workspace')
sys.path.append('/workspace/segment-anything-2')
#sys.path.append('/workspace/segment-anything-2/sam2')

from sam2.build_sam import build_sam2_video_predictor


def perform_sam2_segmentation(frame_dir_path: str, pose_prompts):
    configure_torch()

    sam2_checkpoint = "/workspace/segment-anything-2/checkpoints/sam2_hiera_tiny.pt"
    model_cfg = "sam2_hiera_t.yaml"
    predictor = build_sam2_video_predictor(model_cfg, sam2_checkpoint)

    try:
        inference_state = predictor.init_state(video_path=frame_dir_path)
        predictor.reset_state(inference_state)

        points_list, labels_list = extract_points_and_labels(pose_prompts)

        obj_id = 1
        for points, labels in zip(points_list, labels_list):
            print('-->', points, labels)

            _, out_obj_ids, out_mask_logits = predictor.add_new_points(
                inference_state=inference_state,
                frame_idx=0,
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

        return video_segments[0]
    finally:
        pass


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

        # Append the processed sublists to the main lists
        points.append(points_sublist)
        labels.append(labels_sublist)

    return points, labels
