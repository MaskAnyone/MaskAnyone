import argparse
import os

from person_removal import bboxes_to_masks, get_bboxes_yolo, inpaint_e2fgvi, inpaint_mat

# Remove Persons from Video (Person detection (bbox or silhouette), Background estimation)
def remove_persons(video_in_path, output_path, detection_method="bbox", inpaint_method="e2fgvi") -> None:
    if detection_method == "bbox":
        bboxes = get_bboxes_yolo(video_in_path)
        masks_path = bboxes_to_masks(bboxes, video_in_path)
    elif detection_method == "silhouette":
        pass
    else:
        raise Exception("Invalid method for person removal given")
    
    inpaint_mat(video_in_path, masks_path)

# Extract Person Poses (3D Pose Estimation)
def extract_poses(video_in_path):
    pass

# Input to blender & get animated character
def animate(poses, rig_file):
    pass

# Insert Character into Video
def combine(animated_character, background_video, output_path) -> None:
    pass

if __name__ == '__main__':
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-v','--video', help='path to the video to be processed', default='data/input/ted_kid.mp4')
    argparser.add_argument('-r','--rigfile', help='path to the character-rig file', default='data/rigs/rig')
    args = argparser.parse_args()
    video_path = args.video
    rigfile = args.rigfile

    anonymized_video_path = os.path.join("data", "temp", os.path.basename(video_path))
    result_output_path = os.path.join("data", "output", os.path.basename(video_path))
    remove_persons(video_path, anonymized_video_path, "bbox", "e2fgvi")
    poses = extract_poses(video_path)
    animated_character = animate(poses, rigfile)
    combine(animated_character, anonymized_video_path, result_output_path)