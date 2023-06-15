import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {
    VideoListFetchedPayload,
    VideoMaskingFailedPayload,
    VideoMaskingFinishedPayload,
    VideoMaskingStartedPayload
} from "../actions/videoEvent";
import {Video} from "../types/Video";

export interface VideoState {
    videoList: Video[];
    maskingJobs: Record<string, boolean>;
}

export const videoInitialState: VideoState = {
    videoList: [],
    maskingJobs: {},
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
        [Event.Video.videoMaskingStarted.toString()]: (state, action: Action<VideoMaskingStartedPayload>): VideoState => {
            return {
                ...state,
                maskingJobs: {
                    ...state.maskingJobs,
                    [action.payload.videoName]: true,
                },
            };
        },
        [Event.Video.videoMaskingFailed.toString()]: (state, action: Action<VideoMaskingFailedPayload>): VideoState => {
            return {
                ...state,
                maskingJobs: {
                    ...state.maskingJobs,
                    [action.payload.videoName]: false,
                },
            };
        },
        [Event.Video.videoMaskingFinished.toString()]: (state, action: Action<VideoMaskingFinishedPayload>): VideoState => {
            return {
                ...state,
                maskingJobs: {
                    ...state.maskingJobs,
                    [action.payload.videoName]: false,
                },
            };
        }
    },
    videoInitialState,
);
