import {createAction} from 'redux-actions';
import {Video} from "../types/Video";

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: Video[];
}

export interface ResultVideoListFetchedPayload {
    videoId: string;
    resultVideoList: any[];
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
    resultVideoListFetched: createVideoEvent<ResultVideoListFetchedPayload>('RESULT_VIDEO_LIST_FETCHED'),
};

export default VideoEvent;
