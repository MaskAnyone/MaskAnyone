import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {
    UploadDialogClosedPayload,
    UploadDialogOpenedPayload, VideoUploadFinishedPayload,
    VideoUploadProgressChangedPayload,
    VideoUploadStartedPayload
} from "../actions/uploadEvent";

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
        [Event.Upload.videoUploadStarted.toString()]: (state, action: Action<VideoUploadStartedPayload>): UploadState => {
            return {
                ...state,
                uploadProgress: {
                    ...state.uploadProgress,
                    [action.payload.videoId]: 0,
                },
            };
        },
        [Event.Upload.videoUploadProgressChanged.toString()]: (state, action: Action<VideoUploadProgressChangedPayload>): UploadState => {
            return {
                ...state,
                uploadProgress: {
                    ...state.uploadProgress,
                    [action.payload.videoId]: action.payload.progress,
                },
            };
        },
        [Event.Upload.videoUploadFinished.toString()]: (state, action: Action<VideoUploadFinishedPayload>): UploadState => {
            const { [action.payload.videoId]: _, ...newUploadProgress } = state.uploadProgress;

            return {
                ...state,
                uploadProgress: newUploadProgress,
            };
        },
    },
    uploadInitialState,
);
