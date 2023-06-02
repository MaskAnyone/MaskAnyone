import os
import cv2
from typing import BinaryIO

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.responses import StreamingResponse

from runner import run_masking
from models import RunParams



def send_bytes_range_requests(
    file_obj: BinaryIO, start: int, end: int, chunk_size: int = 10_000
):
    """Send a file in chunks using Range Requests specification RFC7233

    `start` and `end` parameters are inclusive due to specification
    """
    with file_obj as f:
        f.seek(start)
        while (pos := f.tell()) <= end:
            read_size = min(chunk_size, end + 1 - pos)
            yield f.read(read_size)


def _get_range_header(range_header: str, file_size: int) -> tuple[int, int]:
    def _invalid_range():
        return HTTPException(
            status.HTTP_416_REQUESTED_RANGE_NOT_SATISFIABLE,
            detail=f"Invalid request range (Range:{range_header!r})",
        )

    try:
        h = range_header.replace("bytes=", "").split("-")
        start = int(h[0]) if h[0] != "" else 0
        end = int(h[1]) if h[1] != "" else file_size - 1
    except ValueError:
        raise _invalid_range()

    if start > end or start < 0 or end > file_size - 1:
        raise _invalid_range()
    return start, end


def range_requests_response(
    request: Request, file_path: str, content_type: str
):
    """Returns StreamingResponse using Range Requests of a given file"""

    file_size = os.stat(file_path).st_size
    range_header = request.headers.get("range")

    headers = {
        "content-type": content_type,
        "accept-ranges": "bytes",
        "content-encoding": "identity",
        "content-length": str(file_size),
        "access-control-expose-headers": (
            "content-type, accept-ranges, content-length, "
            "content-range, content-encoding"
        ),
    }
    start = 0
    end = file_size - 1
    status_code = status.HTTP_200_OK

    if range_header is not None:
        start, end = _get_range_header(range_header, file_size)
        size = end - start + 1
        headers["content-length"] = str(size)
        headers["content-range"] = f"bytes {start}-{end}/{file_size}"
        status_code = status.HTTP_206_PARTIAL_CONTENT

    return StreamingResponse(
        send_bytes_range_requests(open(file_path, mode="rb"), start, end),
        headers=headers,
        status_code=status_code,
    )



app = FastAPI()

@app.get("/videos")
def get_videos():
    videos = []

    videos_path = "videos"
    for video_name in os.listdir(videos_path):
        capture = cv2.VideoCapture(videos_path + '/' + video_name)

        frame_width = round(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
        frame_height = round(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = capture.get(cv2.CAP_PROP_FPS)
        frame_count = capture.get(cv2.CAP_PROP_FRAME_COUNT)
        duration = frame_count / fps

        videos.append({
            'name': video_name,
            'frameWidth': frame_width,
            'frameHeight': frame_height,
            'fps': round(fps),
            'duration': duration,
        })

    return {
        "videos": videos,
    }

@app.get('/videos/{video_name}')
def get_video_stream(video_name, request: Request):
    video_path = 'videos/' + video_name

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )

@app.get('/results/{video_name}')
def get_result_video_stream(video_name, request: Request):
    video_path = 'results/' + video_name

    return range_requests_response(
        request, file_path=video_path, content_type="video/mp4"
    )

@app.get("/results")
def results():
    results_path = "results"
    if not os.path.exists(results_path):
        os.mkdir(results_path)
    return {"results": os.path.listdir(results_path)}

@app.post("/run")
def run(run_params: RunParams):
    result_path = run_masking(run_params)
    return {"result_video_path": result_path}