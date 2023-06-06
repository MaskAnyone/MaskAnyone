import cv2
import os
from typing import Literal

import mediapipe as mp
import numpy as np

from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
from ultralytics import YOLO

from helpers import draw_landmarks_on_image, draw_landmarks_on_image_face


def blur(video_path: str, background_video_path: str, part_to_blur: Literal["body", "face"], confidence_treshold: float) -> str:
    if part_to_blur == "body":
        model = YOLO(os.path.join("models", "yolov8n.pt"))
    elif part_to_blur == "face":
        model = YOLO(os.path.join("models","yolov8n-face.pt"))

    video_cap = cv2.VideoCapture(video_path)
    capture_bg = cv2.VideoCapture(background_video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join("results", os.path.split(video_path)[1])
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

    if int(video_cap.get(cv2.CAP_PROP_FRAME_COUNT)) != int(capture_bg.get(cv2.CAP_PROP_FRAME_COUNT)):
        raise Exception("Background Video not same length as Video to mask")

    while True:
        ret, frame = video_cap.read()
        _, frame_bg = capture_bg.read()
        if not ret:
            break     
        if part_to_blur == "body":
            results = model.predict(frame, classes=[0], conf=confidence_treshold)
        else:
            results = model.predict(frame, conf=confidence_treshold)
        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = [int(val) for val in box.xyxy[0].tolist()]
                frame_bg[y1:y2, x1:x2] = cv2.GaussianBlur(frame[y1:y2, x1:x2], (23, 23), 30)
        out.write(frame_bg)

    out.release()
    video_cap.release()
    return vid_out_path

def extract_skeleton(video_path: str, background_video_path: str, framework: Literal["mediapipe"]) -> str:
    model_path = os.path.join("models", "pose_landmarker_lite.task")

    BaseOptions = mp.tasks.BaseOptions
    PoseLandmarker = mp.tasks.vision.PoseLandmarker
    PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
    VisionRunningMode = mp.tasks.vision.RunningMode

    options = PoseLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=model_path),
        running_mode=VisionRunningMode.VIDEO,
        output_segmentation_masks=True,
        num_poses=2)


    with PoseLandmarker.create_from_options(options) as landmarker:
        output_path = os.path.join("results", os.path.split(video_path)[1])
        capture = cv2.VideoCapture(video_path)

        frameWidth = capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frameHeight = capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        samplerate = capture.get(cv2.CAP_PROP_FPS)
        capture = cv2.VideoCapture(video_path)
        capture_bg = cv2.VideoCapture(background_video_path)

        if int(capture.get(cv2.CAP_PROP_FRAME_COUNT)) != int(capture_bg.get(cv2.CAP_PROP_FRAME_COUNT)):
            raise Exception("Background Video not same length as Video to mask")

        """
        vp09 seems to be a reasonable compromise that doesn't require a custom build, works in most modern browsers
        and is comparably efficient
        
        H264 and avc1 aren't supported without a custom build of ffmpeg and python-opencv; See: https://www.swiftlane.com/blog/generating-mp4s-using-opencv-python-with-the-avc1-codec/
        mp4v is not supported by browsers
        """
        fourcc = cv2.VideoWriter_fourcc(*'vp09')
        out = cv2.VideoWriter(output_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

        first = True
        while capture.isOpened():
            ret, frame = capture.read()
            _, frame_bg = capture_bg.read()

            if ret:
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame_timestamp_ms = capture.get(cv2.CAP_PROP_POS_MSEC)

                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
                mp_image_bg = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame_bg)

                if not first and frame_timestamp_ms == 0: # Fallback for videos with bad codec
                    print("Bad coded probably - can't properly processsome frames")
                    continue

                pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

                output_image = cv2.cvtColor(mp_image_bg.numpy_view(), cv2.COLOR_RGB2BGR)
                output_image = draw_landmarks_on_image(frame_bg, pose_landmarker_result)

                out.write(output_image)
                first = False
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            else:
                break

        out.release()
        capture.release()
        capture_bg.release()
        cv2.destroyAllWindows()
    return output_path

def extract_face(video_path: str, background_video_path: str, framework: Literal["mediapipe"]) -> str:
    model_path = os.path.join("models", "face_landmarker.task")

    BaseOptions = mp.tasks.BaseOptions
    FaceLandmarker = mp.tasks.vision.FaceLandmarker
    FaceLandmarkerOptions = mp.tasks.vision.FaceLandmarkerOptions
    VisionRunningMode = mp.tasks.vision.RunningMode

    options = FaceLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=model_path),
        running_mode=VisionRunningMode.VIDEO,
        output_face_blendshapes=True,
        output_facial_transformation_matrixes=True,
        num_faces=1)

    with FaceLandmarker.create_from_options(options) as landmarker:
        output_path = os.path.join("results", os.path.split(video_path)[1])
        capture = cv2.VideoCapture(video_path)

        frameWidth = capture.get(cv2.CAP_PROP_FRAME_WIDTH)
        frameHeight = capture.get(cv2.CAP_PROP_FRAME_HEIGHT)
        samplerate = capture.get(cv2.CAP_PROP_FPS)
        capture = cv2.VideoCapture(video_path)
        capture_bg = cv2.VideoCapture(background_video_path)

        if int(capture.get(cv2.CAP_PROP_FRAME_COUNT)) != int(capture_bg.get(cv2.CAP_PROP_FRAME_COUNT)):
            raise Exception("Background Video not same length as Video to mask")

        fourcc = cv2.VideoWriter_fourcc(*'MP4V')
        out = cv2.VideoWriter(output_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

        first = True
        while capture.isOpened():
            ret, frame = capture.read()
            _, frame_bg = capture_bg.read()

            if ret:
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame_timestamp_ms = capture.get(cv2.CAP_PROP_POS_MSEC)

                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
                mp_image_bg = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame_bg)

                if not first and frame_timestamp_ms == 0: # Fallback for videos with bad codec
                    print("Bad coded probably - can't properly processsome frames")
                    continue

                face_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))
                print(face_landmarker_result)

                output_image = cv2.cvtColor(mp_image_bg.numpy_view(), cv2.COLOR_RGB2BGR)
                output_image = draw_landmarks_on_image_face(frame_bg, face_landmarker_result)

                out.write(output_image)
                first = False
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            else:
                break

        out.release()
        capture.release()
        capture_bg.release()
        cv2.destroyAllWindows()
    return output_path
