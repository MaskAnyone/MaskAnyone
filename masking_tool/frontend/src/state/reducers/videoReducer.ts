import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {
    DownloadableResultFilesFetchedPayload,
    ResultVideoListFetchedPayload,
    VideoListFetchedPayload,
} from "../actions/videoEvent";
import {Video} from "../types/Video";
import {ResultVideo} from "../types/ResultVideo";
import {DownloadableResultFile} from "../types/DownloadableResultFile";

export interface VideoState {
    videoList: Video[];
    resultVideoLists: Record<string, ResultVideo[]>;
    downloadableResultFileLists: Record<string, DownloadableResultFile[]>;
}

export const videoInitialState: VideoState = {
    videoList: [],
    resultVideoLists: {},
    downloadableResultFileLists: {},
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
        [Event.Video.resultVideoListFetched.toString()]: (state, action: Action<ResultVideoListFetchedPayload>): VideoState => {
            return {
                ...state,
                resultVideoLists: {
                    ...state.resultVideoLists,
                    [action.payload.videoId]: action.payload.resultVideoList,
                },
            };
        },
        [Event.Video.downloadableResultFilesFetched.toString()]: (state, action: Action<DownloadableResultFilesFetchedPayload>): VideoState => {
            return {
                ...state,
                downloadableResultFileLists: {
                    ...state.downloadableResultFileLists,
                    [action.payload.resultVideoId]: action.payload.files,
                },
            };
        }
    },
    videoInitialState,
);
