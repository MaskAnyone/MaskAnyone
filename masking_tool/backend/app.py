import os

from fastapi import FastAPI

from masking_tool.backend.masking import run_masking
from masking_tool.backend.models import RunParams

app = FastAPI()

@app.get("/results")
async def results():
    results_path = "results"
    if not os.path.exists(results_path):
        os.mkdir(results_path)
    return {"results": os.path.listdir(results_path)}

@app.post("/run")
async def run(run_params: RunParams):
    result_path = run_masking(run_params)
    return {"result_video_path": result_path}