import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {Preset} from "../types/Preset";
import {PresetListFetchedPayload} from "../actions/presetEvent";

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
    },
    presetInitialState,
);
