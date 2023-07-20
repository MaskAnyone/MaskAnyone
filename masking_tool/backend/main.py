from fastapi import FastAPI

import routers.jobs_router as jobs_router
import routers.videos_router as videos_router
import routers.workers_router as workers_router
import routers.worker_router as worker_router
import routers.results_router as results_router
import routers.presets_router as presets_router


app = FastAPI()

# /videos
app.include_router(videos_router.router)

# /jobs
app.include_router(jobs_router.router)

# /workers
app.include_router(workers_router.router)

# /_worker
app.include_router(worker_router.router)

# /results
app.include_router(results_router.router)

# /presets
app.include_router(presets_router.router)
