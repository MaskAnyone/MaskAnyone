import {createAction} from 'redux-actions';
import {Video} from "../types/Video";

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: Video[];
}

export interface VideoMaskingStartedPayload {
    videoId: string;
}

export interface VideoMaskingFailedPayload {
    videoId: string;
}

export interface VideoMaskingFinishedPayload {
    videoId: string;
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
    videoMaskingStarted: createVideoEvent<VideoMaskingStartedPayload>('VIDEO_MASKING_STARTED'),
    videoMaskingFailed: createVideoEvent<VideoMaskingFailedPayload>('VIDEO_MASKING_FAILED'),
    videoMaskingFinished: createVideoEvent<VideoMaskingFinishedPayload>('VIDEO_MASKING_FINISHED'),
};

export default VideoEvent;
