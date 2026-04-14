import logging
import os
import shutil

import requests as http_requests
from fastapi import APIRouter

from config import MASK_ANYONE_PLATFORM_MODE

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/platform",
)

_SERVICES = {
    'sam2':     'http://sam2:8000/',
    'rtmpose':  'http://rtmpose:8000/',
    'openpose': 'http://openpose:8000/',
}


@router.get("/mode")
def register_worker():
    return {
        'platform_mode': MASK_ANYONE_PLATFORM_MODE,
    }


@router.get("/resources")
def get_system_resources():
    resources: dict = {
        'gpu': None,
        'ram_total_gb': None,
        'cpu_model': None,
        'cpu_count': os.cpu_count(),
        'disk_free_gb': None,
        'services': {},
    }

    # GPU info via pynvml (talks directly to NVIDIA driver, no CUDA needed)
    try:
        import pynvml
        pynvml.nvmlInit()
        handle = pynvml.nvmlDeviceGetHandleByIndex(0)
        gpu_name = pynvml.nvmlDeviceGetName(handle)
        if isinstance(gpu_name, bytes):
            gpu_name = gpu_name.decode('utf-8')
        mem_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
        gpu_vram_gb = round(mem_info.total / (1024 ** 3), 1)
        resources['gpu'] = {
            'name': gpu_name,
            'vram_gb': gpu_vram_gb,
        }
        pynvml.nvmlShutdown()
    except Exception as e:
        logger.debug(f"Could not detect GPU: {e}")

    # RAM from /proc/meminfo (Linux containers)
    try:
        with open('/proc/meminfo', 'r') as f:
            for line in f:
                if line.startswith('MemTotal:'):
                    mem_kb = int(line.split()[1])
                    resources['ram_total_gb'] = round(mem_kb / (1024 ** 2), 1)
                    break
    except Exception as e:
        logger.debug(f"Could not read /proc/meminfo: {e}")

    # CPU model from /proc/cpuinfo
    try:
        with open('/proc/cpuinfo', 'r') as f:
            for line in f:
                if line.startswith('model name'):
                    resources['cpu_model'] = line.split(':')[1].strip()
                    break
    except Exception as e:
        logger.debug(f"Could not read /proc/cpuinfo: {e}")

    # Disk free space on the data volume
    try:
        usage = shutil.disk_usage('/var/lib/maskanyone/data')
        resources['disk_free_gb'] = round(usage.free / (1024 ** 3), 1)
    except Exception as e:
        logger.debug(f"Could not read disk usage: {e}")

    # Service health — quick HEAD/GET with short timeout
    for name, url in _SERVICES.items():
        try:
            r = http_requests.get(url, timeout=2)
            resources['services'][name] = r.status_code < 500
        except Exception:
            resources['services'][name] = False

    return resources
