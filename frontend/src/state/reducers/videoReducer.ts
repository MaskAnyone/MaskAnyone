import { Action, handleActions } from 'redux-actions';
import Event from "../actions/event";
import {
    BlendshapesFetchedPayload,
    DownloadableResultFilesFetchedPayload, MpKinematicsFetchedPayload,
    ResultsListFetchedPayload, ResultVideoDeletedPayload,
    VideoDeletedPayload,
    VideoListFetchedPayload,
} from "../actions/videoEvent";
import { Video } from "../types/Video";
import { ResultVideo } from "../types/ResultVideo";
import { DownloadableResultFile } from "../types/DownloadableResultFile";

export interface VideoState {
    videoList: Video[];
    resultVideoLists: Record<string, ResultVideo[]>;
    downloadableResultFileLists: Record<string, DownloadableResultFile[]>;
    blendshapesList: Record<string, any>;
    mpKinematicsList: Record<string, any>;
}

export const videoInitialState: VideoState = {
    videoList: [],
    resultVideoLists: {},
    downloadableResultFileLists: {},
    blendshapesList: {},
    mpKinematicsList: {},
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
        [Event.Video.resultsListFetched.toString()]: (state, action: Action<ResultsListFetchedPayload>): VideoState => {
            return {
                ...state,
                resultVideoLists: {
                    ...state.resultVideoLists,
                    [action.payload.videoId]: action.payload.resultsList,
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
        },
        [Event.Video.blendshapesFetched.toString()]: (state, action: Action<BlendshapesFetchedPayload>): VideoState => {
            return {
                ...state,
                blendshapesList: {
                    ...state.blendshapesList,
                    [action.payload.resultVideoId]: action.payload.blendshapes,
                }
            };
        },
        [Event.Video.mpKinematicsFetched.toString()]: (state, action: Action<MpKinematicsFetchedPayload>): VideoState => {
            return {
                ...state,
                mpKinematicsList: {
                    ...state.mpKinematicsList,
                    [action.payload.resultVideoId]: action.payload.mpKinematics,
                }
            };
        },
        [Event.Video.resultVideoDeleted.toString()]: (state, action: Action<ResultVideoDeletedPayload>): VideoState => {
            const resultVideos = state.resultVideoLists[action.payload.videoId];

            return {
                ...state,
                resultVideoLists: {
                    ...state.resultVideoLists,
                    [action.payload.videoId]: resultVideos.filter(
                        resultVideo => resultVideo.videoResultId !== action.payload.resultVideoId
                    ),
                },
            };
        },
        [Event.Video.videoDeleted.toString()]: (state, action: Action<VideoDeletedPayload>): VideoState => {
            return {
                ...state,
                videoList: state.videoList.filter(video => video.id !== action.payload.videoId),
                resultVideoLists: Object.fromEntries(
                    Object.entries(state.resultVideoLists).filter(([key]) => key !== action.payload.videoId)
                ),
            };
        },
    },
    videoInitialState,
);
