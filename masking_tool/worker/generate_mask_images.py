import cv2
import os


def video_to_images(video_path, output_folder):
    # Create output folder if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Open the video file
    cap = cv2.VideoCapture(video_path)

    frame_count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        # Save the frame as a PNG image
        image_path = os.path.join(output_folder, f"{frame_count:04d}.png")
        cv2.imwrite(image_path, frame, [cv2.IMWRITE_PNG_COMPRESSION, 0])  # Use PNG format

        frame_count += 1

    # Release the video capture object
    cap.release()


if __name__ == "__main__":
    video_path = "ted_kid_super_small_masked.mp4"  # Path to your input video file
    output_folder = "ted_kid_super_small_masked"  # Path to the output folder

    video_to_images(video_path, output_folder)
    print("Video frames converted to PNG images successfully.")
