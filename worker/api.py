import os
import tempfile
import json
import zipfile
import io

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import StreamingResponse
from ultralytics import YOLO

from communication.sam2_client import Sam2Client
from communication.openpose_client import OpenposeClient
from masking.sam2_pose_masker import Sam2PoseMasker
from cli import process_video

app = FastAPI()

# Constants
WORKER_SAM2_BASE_PATH = 'http://sam2:8000/sam2'
WORKER_OPENPOSE_BASE_PATH = 'http://openpose:8000/openpose'

@app.post("/mask-video")
async def mask_video(
    options: str = Form(...),
    video: UploadFile = File(...)
):
    try:
        options = json.loads(options)
        hiding_strategy = options.get("hiding_strategy")
        overlay_strategy = options.get("overlay_strategy")

        valid_hiding_strategies = ['solid_fill', 'transparent_fill', 'blurring', 'pixelation', 'contours', 'none']
        valid_overlay_strategies = ['mp_hand', 'mp_face', 'mp_pose', 'none', 'openpose', 'openpose_body25b',
                                 'openpose_face', 'openpose_body_135']

        if hiding_strategy not in valid_hiding_strategies:
            raise ValueError(f"Invalid hiding_strategy: {hiding_strategy}. Must be one of {valid_hiding_strategies}")
        if overlay_strategy not in valid_overlay_strategies:
            raise ValueError(f"Invalid overlay_strategy: {overlay_strategy}. Must be one of {valid_overlay_strategies}")
        
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )

    sam2_client = Sam2Client(WORKER_SAM2_BASE_PATH)
    openpose_client = OpenposeClient(WORKER_OPENPOSE_BASE_PATH)

    input_tmp_path = None
    output_tmp_path = None
    output_files = []
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as input_tmp:
            input_tmp.write(await video.read())
            input_tmp_path = input_tmp.name
        
        output_tmp_path = os.path.join(tempfile.gettempdir(), os.path.basename(video.filename))

        output_files = process_video(
            input_file=input_tmp_path,
            output_file=output_tmp_path,
            sam2_client=sam2_client,
            openpose_client=openpose_client,
            hiding_strategy=hiding_strategy,
            overlay_strategy=overlay_strategy
        ) 

        zip_stream = io.BytesIO()
        with zipfile.ZipFile(zip_stream, 'w', zipfile.ZIP_DEFLATED) as zip_file:
            for file_path in output_files:
                if os.path.exists(file_path):
                    zip_file.write(file_path, os.path.basename(file_path))
        zip_stream.seek(0)
        
        return StreamingResponse(
            zip_stream,
            media_type='application/zip',
            headers={"Content-Disposition": "attachment; filename=masked_video.zip"}
        )
    finally:
        if input_tmp_path and os.path.exists(input_tmp_path): 
            os.remove(input_tmp_path)
        if output_tmp_path and os.path.exists(output_tmp_path):
            os.remove(output_tmp_path)
        for file in output_files:
            if os.path.exists(file):
                os.remove(file)
       