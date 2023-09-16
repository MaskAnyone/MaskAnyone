from fastapi import APIRouter, Request

from models import RunParams
from db.worker_manager import WorkerManager
from db.db_connection import DBConnection

worker_manager = WorkerManager(DBConnection())

router = APIRouter(
    prefix='/workers',
)


@router.get("")
def fetch_active_workers():
    workers = worker_manager.fetch_active_workers()

    return {"workers": workers}
