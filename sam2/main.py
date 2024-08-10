import numpy as np
import io
import os
import json

from PIL import Image
from fastapi import FastAPI, APIRouter, File, Form, UploadFile, HTTPException
from pydantic import BaseModel
from segmentation import perform_sam2_segmentation

app = FastAPI()

router = APIRouter(
    prefix="/platform",
)


class Sam2Params(BaseModel):
    pose_prompts: list[list[list[int]]]
    video_id: str


@router.post("/mode")
async def register_worker(
    pose_prompts = Form(...),
    image: UploadFile = File(...)
):
    image_content = await image.read()

    pose_prompts = json.loads(pose_prompts)

    # Save the image if needed
    with open("tmp/000000.jpg", "wb") as f:
        f.write(image_content)

    perform_sam2_segmentation('tmp', pose_prompts)

    return {
        'test': 1,
    }


app.include_router(router)
