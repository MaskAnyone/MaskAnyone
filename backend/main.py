from fastapi import FastAPI, Depends

import routers.jobs_router as jobs_router
import routers.videos_router as videos_router
import routers.workers_router as workers_router
import routers.worker_router as worker_router
import routers.results_router as results_router
import routers.presets_router as presets_router
from auth.jwt_bearer import JWTBearer

app = FastAPI()

# /videos
app.include_router(videos_router.router, dependencies=[Depends(JWTBearer())])

# /jobs
app.include_router(jobs_router.router, dependencies=[Depends(JWTBearer())])

# /workers
app.include_router(workers_router.router, dependencies=[Depends(JWTBearer())])

# /_worker
app.include_router(worker_router.router)

# /results
app.include_router(results_router.router, dependencies=[Depends(JWTBearer())])

# /presets
app.include_router(presets_router.router, dependencies=[Depends(JWTBearer())])
