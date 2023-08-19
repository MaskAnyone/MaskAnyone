import {createAction} from 'redux-actions';
import {Video} from "../types/Video";
import {DownloadableResultFile} from "../types/DownloadableResultFile";

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: Video[];
}

export interface ResultVideoListFetchedPayload {
    videoId: string;
    resultVideoList: any[];
}

export interface DownloadableResultFilesFetchedPayload {
    resultVideoId: string;
    files: DownloadableResultFile[];
}

export interface BlendshapesFetchedPayload {
    resultVideoId: string;
    blendshapes: any;
}

export interface MpKinematicsFetchedPayload {
    resultVideoId: string;
    mpKinematics: any;
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
    resultVideoListFetched: createVideoEvent<ResultVideoListFetchedPayload>('RESULT_VIDEO_LIST_FETCHED'),
    downloadableResultFilesFetched: createVideoEvent<DownloadableResultFilesFetchedPayload>('DOWNLOADABLE_RESULT_FILES_FETCHED'),
    blendshapesFetched: createVideoEvent<BlendshapesFetchedPayload>('BLENDSHAPES_FETCHED'),
    mpKinematicsFetched: createVideoEvent<MpKinematicsFetchedPayload>('MP_KINEMATICS_FETCHED'),
};

export default VideoEvent;
