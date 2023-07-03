import {createAction} from 'redux-actions';
import {Video} from "../types/Video";

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: Video[];
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
};

export default VideoEvent;
