import {createAction} from 'redux-actions';

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: any[];
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
};

export default VideoEvent;
