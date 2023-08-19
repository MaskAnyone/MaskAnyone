import { createAction } from 'redux-actions';
import { RunParams } from '../types/Run';

const createVideoCommand = <T>(type: string) => createAction<T>('_C/VD/' + type);

export interface FetchVideoListPayload {
}

export interface MaskVideoPayload {
    id: string;
    videoIds: string[];
    resultVideoId: string;
    runData: RunParams
}

export interface FetchResultVideoListPayload {
    videoId: string;
}

export interface FetchDownloadableResultFilesPayload {
    videoId: string;
    resultVideoId: string;
}

export interface FetchBlendshapesPayload {
    resultVideoId: string;
}

export interface FetchMpKinematicsPayload {
    resultVideoId: string;
}

const VideoCommand = {
    fetchVideoList: createVideoCommand<FetchVideoListPayload>('FETCH_VIDEO_LIST'),
    maskVideo: createVideoCommand<MaskVideoPayload>('MASK_VIDEO'),
    fetchResultVideoList: createVideoCommand<FetchResultVideoListPayload>('FETCH_RESULT_VIDEO_LIST'),
    fetchDownloadableResultFiles: createVideoCommand<FetchDownloadableResultFilesPayload>('FETCH_DOWNLOADABLE_RESULT_FILES'),
    fetchBlendshapes: createVideoCommand<FetchBlendshapesPayload>('FETCH_BLENDSHAPES'),
    fetchMpKinematics: createVideoCommand<FetchMpKinematicsPayload>('FETCH_MP_KINEMATICS'),
};

export default VideoCommand;
