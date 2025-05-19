import json
import time
import requests

# Define the endpoint and container name
DOCKER_CONTAINER_NAME = "api"
ENDPOINT = f"http://{DOCKER_CONTAINER_NAME}:8000/mask-video"

# Example usage
def call_docker_container(video_file_path, options):
    """
    Calls the Docker container on the specified endpoint with the given video file and options.

    :param video_file_path: Path to the video file to be processed.
    :param options: Dictionary containing the options for processing.
    :return: Response from the API.
    """
    with open(video_file_path, "rb") as video_file:
        files = {
            "video": video_file
        }
        data = {
            "options": json.dumps(options)
        }
        response = requests.post(ENDPOINT, files=files, data=data)
        return response

# Example call
if __name__ == "__main__":
    video_path = "/data/backend/videos/original.mp4"
    options = {
        "hiding_strategy": "blurring",
        "overlay_strategy": "mp_pose"
    }
    for _ in range(30): # Wait until API is up
        try:
            response = call_docker_container(video_path, options)
            if response.status_code == 200:
                break
        except requests.ConnectionError:
            time.sleep(1)
    else:
        raise RuntimeError("API not reachable after waiting 20 seconds")

    if response.status_code == 200:
        with open("/data/backend/results/processed_video.mp4", "wb") as output_file:
            output_file.write(response.content)
        print("Video processed successfully. Saved as 'processed_video.mp4'.")
    else:
        print(f"Error: {response.status_code}, {response.text}")