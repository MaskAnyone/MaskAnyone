import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {UploadDialogClosedPayload, UploadDialogOpenedPayload} from "../actions/uploadEvent";

export interface UploadState {
    dialogOpen: boolean;
    uploadProgress: Record<string, number>;
}

export const uploadInitialState: UploadState = {
    dialogOpen: false,
    uploadProgress: {},
};

/* eslint-disable max-len */
export const uploadReducer = handleActions<UploadState, any>(
    {
        [Event.Upload.uploadDialogOpened.toString()]: (state, action: Action<UploadDialogOpenedPayload>): UploadState => {
            return {
                ...state,
                dialogOpen: true,
            };
        },
        [Event.Upload.uploadDialogClosed.toString()]: (state, action: Action<UploadDialogClosedPayload>): UploadState => {
            return {
                ...state,
                dialogOpen: false,
            };
        },
    },
    uploadInitialState,
);
