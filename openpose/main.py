

from fastapi import FastAPI, APIRouter, File, UploadFile

app = FastAPI()

router = APIRouter(
    prefix="/openpose",
)


@router.post("/estimate-pose-on-video")
async def segment_video(
    video: UploadFile = File(...)
):
    video_content = await video.read()
    print('HERE')


app.include_router(router)
