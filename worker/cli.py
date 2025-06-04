import os
import argparse
import cv2
import numpy as np
from tqdm import tqdm
from ultralytics import YOLO

from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.sam2_pose_masker import Sam2PoseMasker

WORKER_SAM2_BASE_PATH = 'http://sam2:8000/sam2'
WORKER_OPENPOSE_BASE_PATH = 'http://openpose:8000/openpose'

model = YOLO('/worker_models/yolo11x-pose.pt')

def get_mp4_files(directory):
    """Returns a set of .mp4 filenames (without extension) in the given directory."""
    return {os.path.splitext(f)[0] for f in os.listdir(directory) if f.endswith('.mp4')}


def validate_directories(input_dir, output_dir):
    """Validates the existence of input and output directories."""
    if not os.path.isdir(input_dir):
        raise FileNotFoundError(f"Error: Input directory '{input_dir}' does not exist.")
    if not os.path.isdir(output_dir):
        raise FileNotFoundError(f"Error: Output directory '{output_dir}' does not exist.")


def duplicate_strategies(strategies: str | list, max_size: int):
    """Duplicates the strategies to match the max size of pose prompts."""
    if type(strategies) == str: # without this, if a string is passed, it is trimmed to max_size instead of the list
        strategies = [strategies] 

    if len(strategies) < max_size:
        factor = (max_size // len(strategies)) + 1  # Calculate how many times to repeat the strategies
        strategies = strategies * factor  # Repeat the strategies
    return strategies[:max_size]  # Trim to the max size


def is_valid(point):
    return point[0] >= 1 and point[1] >= 1


def average_points(points):
    valid_points = [point for point in points if is_valid(point)]
    if valid_points:
        avg_x = round(sum(point[0] for point in valid_points) / len(valid_points))
        avg_y = round(sum(point[1] for point in valid_points) / len(valid_points))
        return [avg_x, avg_y]
    else:
        return [0, 0]


def extract_pose_points(pose):
    #return [point.tolist() + [1] for point in pose]

    points_0_to_4 = [pose[j] for j in range(5)]
    merged_head_point = average_points(points_0_to_4)

    points_5_and_6 = [pose[j] for j in range(5, 7)]
    merged_upper_body_point = average_points(points_5_and_6)

    points_11_and_12 = [pose[j] for j in range(11, 13)]
    merged_lower_body_point = average_points(points_11_and_12)

    new_pose = []

    if is_valid(merged_head_point):
        new_pose.append(merged_head_point + [1])
    if is_valid(merged_upper_body_point):
        new_pose.append(merged_upper_body_point + [1])
    if is_valid(merged_lower_body_point):
        new_pose.append(merged_lower_body_point + [1])

    # Check if we have less than 2 points and add points from indices 7-10 and 13-end if valid
    for j in list(range(7, 11)) + list(range(13, len(pose))):
        if len(new_pose) >= 2:
            break
        if is_valid(pose[j]):
            new_pose.append(pose[j].tolist() + [1])

    return new_pose

def get_first_frame_pose_prompts(input_file):
    capture = cv2.VideoCapture(input_file)
    frame_number = 0 # to note the 1st frame with a person is detected 
    poses = None 
    confs = None
    
    while True:
        success, frame = capture.read()
        if not success:
            break

        result = model.predict(source=frame, device='cpu', verbose=False)[0] # 1st frame

        if ((result.keypoints is not None) and 
            (result.keypoints.xy is not None) and 
            (result.keypoints.conf is not None) and 
            (len(result.keypoints.xy) > 0)):
                poses = result.keypoints.xy.cpu().numpy().astype(int)
                confs = result.keypoints.conf.cpu().numpy()
                break
        
        frame_number += 1

    capture.release()

    if (poses is None) or (confs is None) or (poses.size == 0) or (confs.size == 0):
        raise ValueError(f"No valid poses found. Ensure the video contains a person and is not empty.")

    return poses, confs, frame_number

def process_video(input_file, output_file, sam2_client, openpose_client, hiding_strategy, overlay_strategy):
    video_output_path = output_file
    pose_output_path = output_file.replace('.mp4', '.poses.json')
    masks_output_path = output_file.replace('.mp4', '.masks.npz')

    sam2_pose_masker = Sam2PoseMasker(
        sam2_client,
        openpose_client,
        input_file,
        video_output_path,
        masks_output_path,
        pose_output_path,
        lambda _: _
    )
    poses, confs, frame_number = get_first_frame_pose_prompts(input_file)

    poses = np.array([[point if conf > 0.8 else (0, 0)
                                for point, conf in zip(keypoints, confidences)]
                               for keypoints, confidences in zip(poses, confs)])

    poses = np.array([pose for pose in poses if not np.all(pose == (0, 0))])
    first_frame_pose_prompts = [extract_pose_points(pose) for pose in poses]

    # Here we always only have the first frame prompted, but the system can handle multi-frame prompts
    pose_prompts = {
        str(frame_number): first_frame_pose_prompts
    }

    # Duplicate strategies based on the number of pose prompt entries
    max_size = max(len(p) for p in pose_prompts[str(frame_number)])  # Get the max length of pose prompt entries
    hiding_strategies = duplicate_strategies(hiding_strategy, max_size)
    overlay_strategies = duplicate_strategies(overlay_strategy, max_size)

    # Apply the strategies to the mask function
    sam2_pose_masker.mask({
        'posePrompts': pose_prompts,
        'hidingStrategies': hiding_strategies,  # Use duplicated hiding strategies
        'overlayStrategies': overlay_strategies  # Use duplicated overlay strategies
    })

    return [video_output_path, pose_output_path, masks_output_path]


def process_videos(input_dir, output_dir, hiding_strategy, overlay_strategy):
    """Handles video processing workflow."""
    input_files = get_mp4_files(input_dir)
    output_files = get_mp4_files(output_dir)

    print(f"Found {len(input_files)} .mp4 files in input directory.")
    print(f"Found {len(output_files)} .mp4 files in output directory (already processed).")

    if output_files:
        print(
            "Warning: The output directory contains processed files. If this was unexpected, consider checking its contents before proceeding.")

    files_to_process = input_files - output_files
    print(f"Processing {len(files_to_process)} files...")

    sam2_client = Sam2Client(WORKER_SAM2_BASE_PATH)
    openpose_client = OpenposeClient(WORKER_OPENPOSE_BASE_PATH)

    for file in tqdm(files_to_process, desc="Processing videos"):
        input_file = os.path.join(input_dir, file + ".mp4")
        output_file = os.path.join(output_dir, file + ".mp4")
        process_video(input_file, output_file, sam2_client, openpose_client, hiding_strategy, overlay_strategy)

    print("Processing complete.")


def parse_arguments():
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(description="Bulk video de-identification CLI")
    parser.add_argument("--input-path", required=True, help="Path to the input directory")
    parser.add_argument("--output-path", required=True, help="Path to the output directory")

    # Adding new arguments for hidingStrategies and overlayStrategies
    parser.add_argument("--hiding-strategy",
                        required=True,
                        nargs='+',
                        choices=['solid_fill', 'transparent_fill', 'blurring', 'pixelation', 'contours', 'none'],
                        help="List of hiding strategies to be applied to the video (space-separated).")
    parser.add_argument("--overlay-strategy",
                        required=True,
                        nargs='+',
                        choices=['mp_hand', 'mp_face', 'mp_pose', 'none', 'openpose', 'openpose_body25b',
                                 'openpose_face', 'openpose_body_135'],
                        help="List of overlay strategies to be applied to the video (space-separated).")

    return parser.parse_args()


def main():
    args = parse_arguments()
    try:
        validate_directories(args.input_path, args.output_path)
        # Pass the strategies as arguments to process_videos
        process_videos(args.input_path, args.output_path, args.hiding_strategy, args.overlay_strategy)
    except FileNotFoundError as e:
        print(e)
        raise e


if __name__ == "__main__":
    main()
