import {createAction} from 'redux-actions';

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: any[];
}

export interface VideoMaskingStartedPayload {
    videoName: string;
}

export interface VideoMaskingFailedPayload {
    videoName: string;
}

export interface VideoMaskingFinishedPayload {
    videoName: string;
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
    videoMaskingStarted: createVideoEvent<VideoMaskingStartedPayload>('VIDEO_MASKING_STARTED'),
    videoMaskingFailed: createVideoEvent<VideoMaskingFailedPayload>('VIDEO_MASKING_FAILED'),
    videoMaskingFinished: createVideoEvent<VideoMaskingFinishedPayload>('VIDEO_MASKING_FINISHED'),
};

export default VideoEvent;
