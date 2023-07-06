import {createAction} from 'redux-actions';
import { RunParams } from '../types/Run';

const createVideoCommand = <T>(type: string) => createAction<T>('_C/VD/' + type);

export interface FetchVideoListPayload {
}

export interface MaskVideoPayload {
    id: string;
    videoId: string;
    runData: RunParams
}

const VideoCommand = {
    fetchVideoList: createVideoCommand<FetchVideoListPayload>('FETCH_VIDEO_LIST'),
    maskVideo: createVideoCommand<MaskVideoPayload>('MASK_VIDEO'),
};

export default VideoCommand;
