import {createAction} from 'redux-actions';

const createPresetCommand = <T>(type: string) => createAction<T>('_C/PR/' + type);

export interface FetchPresetListPayload {
}

export interface CreateNewPresetPayload {
}

export interface DeletePresetPayload {
}

const PresetCommand = {
    fetchPresetList: createPresetCommand<FetchPresetListPayload>('FETCH_PRESET_LIST'),
    createNewPreset: createPresetCommand<CreateNewPresetPayload>('CREATE_NEW_PRESET'),
    deletePreset: createPresetCommand<DeletePresetPayload>('DELETE_PRESET'),
};

export default PresetCommand;
