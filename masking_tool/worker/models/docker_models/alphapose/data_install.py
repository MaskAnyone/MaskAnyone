from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
from google.colab import auth
from oauth2client.client import GoogleCredentials

# Authenticate and create the PyDrive client.
# This only needs to be done once per notebook.
auth.authenticate_user()
gauth = GoogleAuth()
gauth.credentials = GoogleCredentials.get_application_default()
drive = GoogleDrive(gauth)

file_id = "1D47msNOOiJKvPOXlnpyzdKA3k6E97NTC"
downloaded = drive.CreateFile({"id": file_id})
downloaded.GetContentFile("/content/AlphaPose/detector/yolo/data/yolov3-spp.weights")

file_id = "1nlnuYfGNuHWZztQHXwVZSL_FvfE551pA"
downloaded = drive.CreateFile({"id": file_id})
downloaded.GetContentFile(
    "/content/AlphaPose/detector/tracker/data/JDE-1088x608-uncertainty"
)

file_id = "1kQhnMRURFiy7NsdS8EFL-8vtqEXOgECn"
downloaded = drive.CreateFile({"id": file_id})
downloaded.GetContentFile("/content/AlphaPose/pretrained_models/fast_res50_256x192.pth")
