import torch
import sys
import os

sys.path.append('/workspace/segment-anything-2')
from sam2.build_sam import build_sam2_video_predictor

predictors = {}

SAM2_OFFLOAD_VIDEO_TO_CPU = os.environ["SAM2_OFFLOAD_VIDEO_TO_CPU"] == "true"
SAM2_OFFLOAD_STATE_TO_CPU = os.environ["SAM2_OFFLOAD_STATE_TO_CPU"] == "true"

MODEL_CONFIGS = {
    "sam2.1_hiera_tiny": {
        "checkpoint": "/workspace/sam2/checkpoints/sam2.1_hiera_tiny.pt",
        "config": "configs/sam2.1/sam2.1_hiera_t.yaml",
    },
    "sam2.1_hiera_small": {
        "checkpoint": "/workspace/sam2/checkpoints/sam2.1_hiera_small.pt",
        "config": "configs/sam2.1/sam2.1_hiera_s.yaml",
    },
    "sam2.1_hiera_base_plus": {
        "checkpoint": "/workspace/sam2/checkpoints/sam2.1_hiera_base_plus.pt",
        "config": "configs/sam2.1/sam2.1_hiera_b+.yaml",
    },
    "sam2.1_hiera_large": {
        "checkpoint": "/workspace/sam2/checkpoints/sam2.1_hiera_large.pt",
        "config": "configs/sam2.1/sam2.1_hiera_l.yaml",
    },
}

DEFAULT_MODEL = "sam2.1_hiera_small"


def perform_sam2_segmentation(
    frame_dir_path: str,
    pose_prompts,
    model_variant: str = DEFAULT_MODEL,
    initial_masks: dict = None,
):
    """Segment a video (or chunk) using SAM2.

    Args:
        frame_dir_path: Path to the video file.
        pose_prompts: Dict of {frame_idx: [[x, y, label], ...]} point prompts.
                      Used for the first chunk (or single-pass jobs).
        model_variant: Which SAM2 model to use.
        initial_masks: Optional dict of {obj_id: numpy_bool_array} mask prompts.
                       When provided, these are injected at frame 0 instead of
                       point prompts — used for chunk N+1 onwards to maintain
                       tracking continuity from the previous chunk's last frame.
                       Must be 2D boolean arrays matching the video frame dimensions.
    """
    global predictors

    if model_variant not in MODEL_CONFIGS:
        raise ValueError(f"Unknown model variant '{model_variant}'. Choose from: {list(MODEL_CONFIGS.keys())}")

    if model_variant not in predictors:
        configure_torch()
        torch.cuda.empty_cache()

        cfg = MODEL_CONFIGS[model_variant]
        predictors[model_variant] = build_sam2_video_predictor(cfg["config"], cfg["checkpoint"])

    predictor = predictors[model_variant]

    print(f"Initializing SAM2 predictor with flags: "
          f"offload_video_to_cpu={SAM2_OFFLOAD_VIDEO_TO_CPU}, "
          f"offload_state_to_cpu={SAM2_OFFLOAD_STATE_TO_CPU}, "
          f"async_loading_frames=True"
          f"{' [mask-prompt chunk]' if initial_masks else ' [point-prompt]'}")

    inference_state = predictor.init_state(
        video_path=frame_dir_path,
        offload_video_to_cpu=SAM2_OFFLOAD_VIDEO_TO_CPU,
        offload_state_to_cpu=SAM2_OFFLOAD_STATE_TO_CPU,
        async_loading_frames=True,
    )

    predictor.reset_state(inference_state)
    torch.cuda.empty_cache()

    if initial_masks:
        # Chunk continuation: seed each object from its previous-chunk boundary mask.
        # add_new_mask() requires a 2D boolean numpy array at frame 0.
        for obj_id, mask_array in initial_masks.items():
            assert mask_array.ndim == 2 and mask_array.dtype == bool, (
                f"initial_masks[{obj_id}] must be a 2D boolean numpy array, "
                f"got shape={mask_array.shape} dtype={mask_array.dtype}"
            )
            predictor.add_new_mask(
                inference_state=inference_state,
                frame_idx=0,
                obj_id=int(obj_id),
                mask=mask_array,
            )
    else:
        # First chunk (or single-pass): use user-supplied point prompts.
        for frame_idx, frame_pose_prompts in pose_prompts.items():
            obj_id_list, points_list, labels_list = extract_points_and_labels(frame_pose_prompts)

            for obj_id, points, labels in zip(obj_id_list, points_list, labels_list):
                predictor.add_new_points(
                    inference_state=inference_state,
                    frame_idx=int(frame_idx),
                    obj_id=obj_id,
                    points=points,
                    labels=labels,
                )

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
