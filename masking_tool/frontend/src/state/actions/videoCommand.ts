import {createAction} from 'redux-actions';

const createVideoCommand = <T>(type: string) => createAction<T>('_C/VD/' + type);

export interface FetchVideoListPayload {
}

export interface MaskVideoPayload {
    videoId: string;
    extractPersonOnly: boolean;
    headOnlyHiding: boolean;
    hidingStrategy: number;
    headOnlyMasking: boolean;
    maskCreationStrategy: number;
    detailedFingers: boolean;
    detailedFaceMesh: boolean;
}

const VideoCommand = {
    fetchVideoList: createVideoCommand<FetchVideoListPayload>('FETCH_VIDEO_LIST'),
    maskVideo: createVideoCommand<MaskVideoPayload>('MASK_VIDEO'),
};

export default VideoCommand;
