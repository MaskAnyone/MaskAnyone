import {createAction} from 'redux-actions';
import {Preset} from "../types/Preset";

const createPresetCommand = <T>(type: string) => createAction<T>('_C/PR/' + type);

export interface FetchPresetListPayload {
}

export interface CreateNewPresetPayload {
    newPreset: Omit<Preset, 'id'>;
}

export interface DeletePresetPayload {
    id: string;
}

const PresetCommand = {
    fetchPresetList: createPresetCommand<FetchPresetListPayload>('FETCH_PRESET_LIST'),
    createNewPreset: createPresetCommand<CreateNewPresetPayload>('CREATE_NEW_PRESET'),
    deletePreset: createPresetCommand<DeletePresetPayload>('DELETE_PRESET'),
};

export default PresetCommand;
