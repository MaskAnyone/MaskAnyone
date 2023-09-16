import shutil
import cv2
import os
import numpy as np

from config import RESULT_BASE_PATH, VIDEOS_BASE_PATH


def setup_video_processing(video_in_path: str, video_out_path: str):
    video_cap = cv2.VideoCapture(video_in_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)

    """
    vp09 seems to be a reasonable compromise that doesn't require a custom build, works in most modern browsers
    and is comparably efficient

    H264 and avc1 aren't supported without a custom build of ffmpeg and python-opencv; See: https://www.swiftlane.com/blog/generating-mp4s-using-opencv-python-with-the-avc1-codec/
    mp4v is not supported by browsers
    """
    fourcc = cv2.VideoWriter_fourcc(*"vp09")
    out = cv2.VideoWriter(
        video_out_path,
        fourcc,
        fps=samplerate,
        frameSize=(int(frameWidth), int(frameHeight)),
    )

    return video_cap, out


def merge_results(
    original_video_path: str, diff_video_path: str, hidden_video_path: str
):
    new_hidden_path = os.path.splitext(hidden_video_path)[0] + "_copy.mp4"
    out_path = hidden_video_path
    shutil.move(hidden_video_path, new_hidden_path)
    cap1 = cv2.VideoCapture(original_video_path)
    cap2 = cv2.VideoCapture(diff_video_path)
    cap3 = cv2.VideoCapture(new_hidden_path)

    # Check if videos are opened successfully
    if not (cap1.isOpened() and cap2.isOpened() and cap3.isOpened()):
        print("Error opening video files!")
        return

    # Get video properties
    frame_width = int(cap1.get(3))
    frame_height = int(cap1.get(4))
    fps = cap1.get(cv2.CAP_PROP_FPS)

    # Define the codec and create VideoWriter object
    fourcc = cv2.VideoWriter_fourcc(*"XVID")
    out = cv2.VideoWriter(out_path, fourcc, fps, (frame_width, frame_height))
    count = 0

    while True:
        ret1, frame1 = cap1.read()
        ret2, frame2 = cap2.read()
        ret3, frame3 = cap3.read()

        if not (ret1 and ret2 and ret3):
            break

        # Compute the difference between video1 and video2 frames
        diff = cv2.absdiff(frame1, frame2)

        # Create a mask where the difference is significant
        _, mask = cv2.threshold(
            cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY), 5, 255, cv2.THRESH_BINARY
        )

        # Expand dimensions of mask to match the frame dimensions
        mask = cv2.cvtColor(mask, cv2.COLOR_GRAY2BGR)

        # Use the mask to copy the modified part from video2 to video3
        np.copyto(frame3, frame2, where=mask.astype(bool))

        out.write(frame3)

    # Release everything
    cap1.release()
    cap2.release()
    cap3.release()
    out.release()
    cv2.destroyAllWindows()
    print("Done merging results")

    return hidden_video_path
