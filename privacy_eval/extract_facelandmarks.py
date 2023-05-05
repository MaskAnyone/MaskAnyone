# This script extracts face-masks with 478points from a given dataset

import mediapipe as mp #mediapipe
import cv2 #opencv
import math #basic operations
import numpy as np #basic operations
import pandas as pd #data wrangling
import csv #csv saving
import os #some basic functions for inspecting folder structure etc.
from PIL import Image

from os import listdir
from os.path import isfile, join
images_folder = "/home/rohan/Documents/Uni/Sem4/MP/Datasets/img_align_celeba"
images = [f for f in listdir(images_folder) if isfile(join(images_folder, f))] 
output_folder = "./out_images/"

mp_holistic = mp.solutions.holistic
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_face_mesh = mp.solutions.face_mesh

facemarks = [str(x) for x in range(478)] #there are 478 points for the face mesh (see google holistic face mesh info for landmarks)
for image_p in images:
    with mp_face_mesh.FaceMesh(
            static_image_mode=True,
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.5) as face_mesh:
        
        image = cv2.imread(os.path.join(images_folder, image_p))
        results = face_mesh.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
        face_found = bool(results.multi_face_landmarks)
        if face_found:
            out_image = np.zeros((image.shape), dtype = np.uint8)
            mp_drawing.draw_landmarks(
                image=out_image,
                landmark_list=results.multi_face_landmarks[0],
                connections=mp_face_mesh.FACEMESH_TESSELATION,
                landmark_drawing_spec=None,
                connection_drawing_spec=mp_drawing_styles.get_default_face_mesh_tesselation_style())

            out_path = os.path.join(output_folder, image_p)
            cv2.imwrite(out_path, out_image)
