import {createAction} from 'redux-actions';

const createVideoCommand = <T>(type: string) => createAction<T>('_C/VD/' + type);

export interface FetchVideoListPayload {
}

const VideoCommand = {
    fetchVideoList: createVideoCommand<FetchVideoListPayload>('FETCH_VIDEO_LIST'),
};

export default VideoCommand;
