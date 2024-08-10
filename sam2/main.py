import numpy as np
import io
import os
import json
import cv2

from PIL import Image
from fastapi import FastAPI, APIRouter, File, Form, UploadFile, HTTPException, Response
from pydantic import BaseModel
from segmentation import perform_sam2_segmentation

app = FastAPI()

router = APIRouter(
    prefix="/platform",
)


colors = [
    (0, 0, 255),   # Red
    (0, 255, 0),   # Green
    (255, 0, 0),   # Blue
    (0, 255, 255), # Yellow
    (255, 0, 255), # Magenta
    (255, 255, 0), # Cyan
    # Add more colors if needed
]


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

    masks = perform_sam2_segmentation('tmp', pose_prompts)

    output_image = cv2.imread("tmp/000000.jpg")
    for object_id in range(1, len(masks) + 1):
        mask = masks[object_id]
        mask = np.squeeze(mask)

        print(output_image.shape, mask.shape)

        color = colors[(object_id - 1) % len(colors)]
        overlay = np.zeros_like(output_image)
        overlay[:, :, 0] = color[0]
        overlay[:, :, 1] = color[1]
        overlay[:, :, 2] = color[2]
        alpha = 0.7
        output_image[mask] = (alpha * overlay[mask] + (1 - alpha) * output_image[mask]).astype(np.uint8)

    _, output_buffer = cv2.imencode('.jpg', output_image)
    return Response(content=output_buffer.tobytes(), media_type="image/jpeg")


app.include_router(router)
