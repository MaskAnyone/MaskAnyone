import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {VideoListFetchedPayload} from "../actions/videoEvent";
import {Video} from "../types/Video";

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
        [Event.Video.videoListFetched.toString()]: (state, action: Action<VideoListFetchedPayload>): UploadState => {
            return {
                ...state,
            };
        },
    },
    uploadInitialState,
);
