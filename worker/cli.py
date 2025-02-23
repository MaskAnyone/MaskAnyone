import os
import argparse
from tqdm import tqdm

from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.sam2_pose_masker import Sam2PoseMasker

WORKER_SAM2_BASE_PATH = 'http://sam2:8000/sam2'
WORKER_OPENPOSE_BASE_PATH = 'http://openpose:8000/openpose'

def get_mp4_files(directory):
    """Returns a set of .mp4 filenames (without extension) in the given directory."""
    return {os.path.splitext(f)[0] for f in os.listdir(directory) if f.endswith('.mp4')}

def validate_directories(input_dir, output_dir):
    """Validates the existence of input and output directories."""
    if not os.path.isdir(input_dir):
        raise FileNotFoundError(f"Error: Input directory '{input_dir}' does not exist.")
    if not os.path.isdir(output_dir):
        raise FileNotFoundError(f"Error: Output directory '{output_dir}' does not exist.")

def process_video(input_file, output_file, sam2_client, openpose_client):
    sam2_pose_masker = Sam2PoseMasker(
        sam2_client,
        openpose_client,
        input_file,
        output_file,
        output_file.replace('.mp4', '.masks.npz'),
        output_file.replace('mp4', '.poses.json'),
        lambda _: _
    )

    sam2_pose_masker.mask({
        'posePrompts': {
            "0": [
                [
                    [
                        557,
                        242,
                        1
                    ],
                    [
                        560,
                        295,
                        1
                    ],
                    [
                        566,
                        428,
                        1
                    ]
                ],
                [
                    [
                        775,
                        230,
                        1
                    ],
                    [
                        792,
                        282,
                        1
                    ],
                    [
                        790,
                        413,
                        1
                    ]
                ]
            ]
        },
        'hidingStrategies': [
            "transparent_fill",
            "transparent_fill"
        ],
        'overlayStrategies': [
            "mp_pose",
            "mp_pose"
        ]
    })

def process_videos(input_dir, output_dir):
    """Handles video processing workflow."""
    input_files = get_mp4_files(input_dir)
    output_files = get_mp4_files(output_dir)

    print(f"Found {len(input_files)} .mp4 files in input directory.")
    print(f"Found {len(output_files)} .mp4 files in output directory (already processed).")

    if output_files:
        print("Warning: The output directory contains processed files. If this was unexpected, consider checking its contents before proceeding.")

    files_to_process = input_files - output_files
    print(f"Processing {len(files_to_process)} files...")

    sam2_client = Sam2Client(WORKER_SAM2_BASE_PATH)
    openpose_client = OpenposeClient(WORKER_OPENPOSE_BASE_PATH)

    for file in tqdm(files_to_process, desc="Processing videos"):
        input_file = os.path.join(input_dir, file + ".mp4")
        output_file = os.path.join(output_dir, file + ".mp4")
        process_video(input_file, output_file, sam2_client, openpose_client)

    print("Processing complete.")

def parse_arguments():
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(description="Bulk video de-identification CLI")
    parser.add_argument("--input-path", required=True, help="Path to the input directory")
    parser.add_argument("--output-path", required=True, help="Path to the output directory")
    return parser.parse_args()

def main():
    args = parse_arguments()
    try:
        validate_directories(args.input_path, args.output_path)
        process_videos(args.input_path, args.output_path)
    except FileNotFoundError as e:
        print(e)
        raise e

if __name__ == "__main__":
    main()
