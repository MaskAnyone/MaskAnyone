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

export interface FetchResultsListPayload {
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

export interface DeleteResultVideoPayload {
    videoId: string;
    resultVideoId: string;
}

const VideoCommand = {
    fetchVideoList: createVideoCommand<FetchVideoListPayload>('FETCH_VIDEO_LIST'),
    maskVideo: createVideoCommand<MaskVideoPayload>('MASK_VIDEO'),
    fetchResultsList: createVideoCommand<FetchResultsListPayload>('FETCH_RESULT_VIDEO_LIST'),
    fetchDownloadableResultFiles: createVideoCommand<FetchDownloadableResultFilesPayload>('FETCH_DOWNLOADABLE_RESULT_FILES'),
    fetchBlendshapes: createVideoCommand<FetchBlendshapesPayload>('FETCH_BLENDSHAPES'),
    fetchMpKinematics: createVideoCommand<FetchMpKinematicsPayload>('FETCH_MP_KINEMATICS'),
    deleteResultVideo: createVideoCommand<DeleteResultVideoPayload>('DELETE_RESULT_VIDEO'),
};

export default VideoCommand;
