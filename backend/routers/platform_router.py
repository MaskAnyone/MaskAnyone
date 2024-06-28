from fastapi import APIRouter

from config import MASK_ANYONE_PLATFORM_MODE

router = APIRouter(
    prefix="/platform",
)


@router.get("/mode")
def register_worker():
    return {
        'platform_mode': MASK_ANYONE_PLATFORM_MODE,
    }
