from fastapi import APIRouter, Request

from models import CreatePresetParams
from db.preset_manager import PresetManager
from db.db_connection import DBConnection

preset_manager = PresetManager(DBConnection())

router = APIRouter(
    prefix="/presets",
)


@router.get("")
def fetch_presets():
    presets = preset_manager.fetch_presets()

    return {"presets": presets}


@router.post("/create")
def create_preset(params: CreatePresetParams):
    preset_manager.create_new_preset(
        params.id,
        params.name,
        params.description,
        params.data,
    )


@router.post("/{preset_id}/delete")
def delete_preset(preset_id: str):
    preset_manager.delete_preset(preset_id)
