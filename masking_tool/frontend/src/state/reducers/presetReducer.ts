import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {Preset} from "../types/Preset";
import {NewPresetCreatedPayload, PresetDeletedPayload, PresetListFetchedPayload} from "../actions/presetEvent";

export interface PresetState {
    presetList: Preset[];
}

export const presetInitialState: PresetState = {
    presetList: [],
};

/* eslint-disable max-len */
export const presetReducer = handleActions<PresetState, any>(
    {
        [Event.Preset.presetListFetched.toString()]: (state, action: Action<PresetListFetchedPayload>): PresetState => {
            return {
                ...state,
                presetList: action.payload.presetList,
            };
        },
        [Event.Preset.newPresetCreated.toString()]: (state, action: Action<NewPresetCreatedPayload>): PresetState => {
            return {
                ...state,
                presetList: [
                    ...state.presetList,
                    action.payload.preset,
                ],
            };
        },
        [Event.Preset.presetDeleted.toString()]: (state, action: Action<PresetDeletedPayload>): PresetState => {
            return {
                ...state,
                presetList: state.presetList.filter(preset => preset.id !== action.payload.id),
            };
        }
    },
    presetInitialState,
);
