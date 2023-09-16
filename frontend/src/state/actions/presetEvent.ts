import {createAction} from 'redux-actions';
import {Preset} from "../types/Preset";

const createPresetEvent = <T>(type: string) => createAction<T>('_E/PR/' + type);

export interface PresetListFetchedPayload {
    presetList: Preset[];
}

export interface NewPresetCreatedPayload {
    preset: Preset;
}

export interface PresetDeletedPayload {
    id: string;
}

const PresetEvent = {
    presetListFetched: createPresetEvent<PresetListFetchedPayload>('PRESET_LIST_FETCHED'),
    newPresetCreated: createPresetEvent<NewPresetCreatedPayload>('NEW_PRESET_CREATED'),
    presetDeleted: createPresetEvent<PresetDeletedPayload>('PRESET_DELETED'),
};

export default PresetEvent;
