import os

import cv2
import numpy as np
import mediapipe as mp
from utils.drawing_utils import draw_segment_mask, overlay

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
    vid_out_path = os.path.join("results", "bg_video_temp.mp4")
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
    vid_out_path = os.path.join("results", "bg_video_temp.mp4")
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
    mp_holistic = mp.solutions.holistic
    capture = cv2.VideoCapture(video_path) #load in the videocapture
    frameWidth = capture.get(cv2.CAP_PROP_FRAME_WIDTH) #check frame width
    frameHeight = capture.get(cv2.CAP_PROP_FRAME_HEIGHT) #check frame height
    samplerate = capture.get(cv2.CAP_PROP_FPS)   #fps = frames per second
    fourcc = cv2.VideoWriter_fourcc(*'MP4V') #for different video formats you could use e.g., *'XVID'
    vid_out_path = os.path.join("results", "bg_video_temp.mp4")
    out = cv2.VideoWriter(vid_out_path, fourcc, 
                          fps = samplerate, frameSize = (int(frameWidth), int(frameHeight)))

    # Run MediaPipe frame by frame using Holistic with `enable_segmentation=True` to get pose segmentation.
    time = 0
    with mp_holistic.Holistic(
        static_image_mode=True, enable_segmentation=True, refine_face_landmarks=True) as holistic:
        while (True):
            ret, image = capture.read() #read frame
            if ret == True: #if there is a frame
                image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB) #make sure the image is in RGB format
                results = holistic.process(image) #apply Mediapipe holistic processing
                # Draw pose segmentation
                h, w, c = image.shape
                if  np.all(results.segmentation_mask) != None: #check if there is a pose found
                    masked_img = draw_segment_mask(image, results.segmentation_mask)
                out.write(masked_img) #save the frame to the new masked video
                time = time+(1000/samplerate)#update the time variable  for the next frame
            else:
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
    vid_out_path = os.path.join("results", "bg_video_temp.mp4")
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
    vid_out_path = os.path.join("results", os.path.split(video_path)[1])
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