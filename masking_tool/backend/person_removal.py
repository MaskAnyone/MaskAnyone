import os

import cv2
import numpy as np
from helpers import overlay

from ultralytics import YOLO

def remove_person_bbox(video_path: str, confidence_treshold: float):
    model = YOLO(os.path.join("models", "yolov8n.pt"))
    video_cap = cv2.VideoCapture(video_path)
    frameWidth = video_cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    frameHeight = video_cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    samplerate = video_cap.get(cv2.CAP_PROP_FPS)
    fourcc = cv2.VideoWriter_fourcc(*'MP4V')
    vid_out_path = os.path.join("results", "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

    while True:
        ret, frame = video_cap.read()
        if not ret:
            break
        results = model.predict(frame, classes=[0], conf=confidence_treshold)
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
    vid_out_path = os.path.join("results", "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

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