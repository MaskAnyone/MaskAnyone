import math
import os
import shutil

from fastapi import APIRouter

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


@router.get("/recommendation")
def get_worker_recommendation():
    """Suggest how many worker containers the host can comfortably run, based on
    CPU cores / RAM / VRAM available. Single-GPU services (SAM2, OpenPose) cap the
    practical benefit around 4; adding more gives diminishing returns because each
    call queues on the shared model.
    """
    cpu_count = os.cpu_count() or 1

    ram_gb = 0.0
    try:
        with open('/proc/meminfo', 'r') as f:
            for line in f:
                if line.startswith('MemTotal:'):
                    ram_gb = int(line.split()[1]) / (1024 ** 2)
                    break
    except Exception:
        pass

    vram_gb = 0.0
    try:
        import pynvml
        pynvml.nvmlInit()
        handle = pynvml.nvmlDeviceGetHandleByIndex(0)
        mem_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
        vram_gb = mem_info.total / (1024 ** 3)
        pynvml.nvmlShutdown()
    except Exception:
        pass

    # Per-worker budget: 4 cores, 8 GB RAM, 10 GB VRAM headroom.
    # Hard cap at 4 — adding more only helps if multiple jobs are queued AND pipeline
    # phases (CPU render + GPU segment) overlap. Beyond 4 the shared GPU services
    # bottleneck. Minimum 1.
    caps = [
        math.floor(cpu_count / 4),
        math.floor(ram_gb / 8),
    ]
    if vram_gb > 0:
        caps.append(math.floor(vram_gb / 10))
    recommended = max(1, min(*caps, 4)) if caps else 1

    return {
        'current': len(worker_manager.fetch_active_workers()),
        'recommended': recommended,
        'max': 4,
        'basis': {
            'cpu_count': cpu_count,
            'ram_gb': round(ram_gb, 1),
            'vram_gb': round(vram_gb, 1),
        },
        'note': (
            'SAM2 and OpenPose hold a single GPU model each and serialize requests. '
            'Extra workers help pipeline overlapping CPU render + GPU segment stages '
            'when multiple jobs are queued; expect ~1.4-1.7x speedup at 2 workers, '
            'diminishing returns beyond.'
        ),
    }
