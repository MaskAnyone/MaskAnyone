import os

import cv2
import numpy as np
import mediapipe as mp
from mediapipe import solutions
from mediapipe.framework.formats import landmark_pb2
from utils.drawing_utils import draw_segment_mask, overlay
from config import RESULT_BASE_PATH

from ultralytics import YOLO

def remove_person_bbox(video_path: str, face_only: bool, confidence_treshold: float):
    if face_only:
        model = YOLO(os.path.join("models","yolov8n-face.pt"))
    else:
        model = YOLO(os.path.join("models", "yolov8n.pt"))

    video_cap = cv2.VideoCapture(video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join(RESULT_BASE_PATH, "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

    while True:
        ret, frame = video_cap.read()
        if not ret:
            break
        if not face_only:
            results = model.predict(frame, classes=[0], conf=confidence_treshold)
        else:
            results = model.predict(frame, conf=confidence_treshold)
        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = [int(val) for val in box.xyxy[0].tolist()]
                frame  = cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 0), -1)
        out.write(frame)
    
    out.release()
    video_cap.release()
    return vid_out_path


def remove_person_silhoutte(video_path: str):
    model_path = os.path.join("models", "yolov8n-seg.pt")
    model = YOLO(model_path)
    video_cap = cv2.VideoCapture(video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join(RESULT_BASE_PATH, "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))
    count = 0
    while True:
        count += 1
        ret, frame = video_cap.read()
        if not ret:
            break
        h, w, _ = frame.shape
        results = model.predict(frame, classes=[0])
        masks = results[0].masks
        if masks is not None:
            masks = masks.data.cpu()
            for seg in masks.data.cpu().numpy():
                seg = cv2.resize(seg, (w, h))
                frame = overlay(frame, seg, (0,0,0), 1)

        out.write(frame)

    out.release()
    video_cap.release()
    return vid_out_path

def remove_person_silhoutte_mp(video_path: str):
    model_path = os.path.join("models", "pose_landmarker_heavy.task")

    BaseOptions = mp.tasks.BaseOptions
    PoseLandmarker = mp.tasks.vision.PoseLandmarker
    PoseLandmarkerOptions = mp.tasks.vision.PoseLandmarkerOptions
    VisionRunningMode = mp.tasks.vision.RunningMode

    options = PoseLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=model_path),
        running_mode=VisionRunningMode.VIDEO,
        output_segmentation_masks=True,
        num_poses=2)

    capture = cv2.VideoCapture(video_path) #load in the videocapture
    frameWidth = capture.get(cv2.CAP_PROP_FRAME_WIDTH) #check frame width
    frameHeight = capture.get(cv2.CAP_PROP_FRAME_HEIGHT) #check frame height
    samplerate = capture.get(cv2.CAP_PROP_FPS)   #fps = frames per second
    fourcc = cv2.VideoWriter_fourcc(*'MP4V') #for different video formats you could use e.g., *'XVID'
    vid_out_path = os.path.join(RESULT_BASE_PATH, "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc,
                          fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

    with PoseLandmarker.create_from_options(options) as landmarker:
        while capture.isOpened():
            ret, frame = capture.read()

            if ret:
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                frame_timestamp_ms = capture.get(cv2.CAP_PROP_POS_MSEC)
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)

                pose_landmarker_result = landmarker.detect_for_video(mp_image, int(frame_timestamp_ms))

                output_image = cv2.cvtColor(mp_image.numpy_view(), cv2.COLOR_RGB2BGR)
                if pose_landmarker_result.segmentation_masks:
                    for segmentation_mask in pose_landmarker_result.segmentation_masks:
                        mask = segmentation_mask.numpy_view()
                        seg_mask = np.repeat(mask[:, :, np.newaxis], 3, axis=2)

                        output_image[seg_mask > 0.3] = 0
                        interpolation_mask = (seg_mask > 0.1) & (seg_mask <= 0.3)
                        interpolation_factor = (seg_mask - 0.1) / (0.3 - 0.1)
                        output_image[interpolation_mask] = (1 - interpolation_factor[interpolation_mask]) * output_image[interpolation_mask] + interpolation_factor[interpolation_mask] * 0

                out.write(output_image)
            else:
                # Break the loop if no frames are left
                break

    out.release()
    capture.release()
    return vid_out_path


def remove_person_estimate_bg(video_path: str, hiding_model: str):
    video_cap = cv2.VideoCapture(video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join(RESULT_BASE_PATH, "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))
    model = None
    while True:
        ret, frame = video_cap.read()
        if not ret:
            break
        h, w, _ = frame.shape
        results = model.predict(frame, classes=[0])
        masks = results[0].masks
        if masks is not None:
            masks = masks.data.cpu()
            for seg in masks.data.cpu().numpy():
                seg = cv2.resize(seg, (w, h))
                frame = overlay(frame, seg, (0,0,0), 1)

        out.write(frame)

    out.release()
    video_cap.release()
    return vid_out_path

def blur(video_path: str, face_only: bool, confidence_treshold: float) -> str:
    if face_only:
        model = YOLO(os.path.join("models","yolov8n-face.pt"))
    else:
        model = YOLO(os.path.join("models", "yolov8n.pt"))

    video_cap = cv2.VideoCapture(video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join(RESULT_BASE_PATH, os.path.split(video_path)[1])
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

    while True:
        ret, frame = video_cap.read()
        if not ret:
            break     
        if not face_only:
            results = model.predict(frame, classes=[0], conf=confidence_treshold)
        else:
            results = model.predict(frame, conf=confidence_treshold)
        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = [int(val) for val in box.xyxy[0].tolist()]
                frame[y1:y2, x1:x2] = cv2.GaussianBlur(frame[y1:y2, x1:x2], (23, 23), 30)
        out.write(frame)

    out.release()
    video_cap.release()
    return vid_out_path