import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {WorkerListFetchedPayload} from "../actions/workerEvent";
import {Worker} from "../types/Worker";

export interface WorkerState {
    workerList: Worker[];
}

export const workerInitialState: WorkerState = {
    workerList: [],
};

/* eslint-disable max-len */
export const workerReducer = handleActions<WorkerState, any>(
    {
        [Event.Worker.workerListFetched.toString()]: (state, action: Action<WorkerListFetchedPayload>): WorkerState => {
            return {
                ...state,
                workerList: action.payload.workerList,
            };
        },
    },
    workerInitialState,
);
