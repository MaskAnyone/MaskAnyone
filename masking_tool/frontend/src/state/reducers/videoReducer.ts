import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {
    VideoListFetchedPayload,
} from "../actions/videoEvent";
import {Video} from "../types/Video";

export interface VideoState {
    videoList: Video[];
}

export const videoInitialState: VideoState = {
    videoList: [],
};

/* eslint-disable max-len */
export const videoReducer = handleActions<VideoState, any>(
    {
        [Event.Video.videoListFetched.toString()]: (state, action: Action<VideoListFetchedPayload>): VideoState => {
            return {
                ...state,
                videoList: action.payload.videoList,
            };
        },
    },
    videoInitialState,
);
