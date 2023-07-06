from fastapi import FastAPI

import routers.jobs_router as jobs_router
import routers.videos_router as videos_router


app = FastAPI()

# /videos
app.include_router(videos_router.router)

# /jobs
app.include_router(jobs_router.router)
