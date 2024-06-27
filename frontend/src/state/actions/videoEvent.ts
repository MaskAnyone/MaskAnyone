import { createAction } from 'redux-actions';
import { Video } from "../types/Video";
import { DownloadableResultFile } from "../types/DownloadableResultFile";

const createVideoEvent = <T>(type: string) => createAction<T>('_E/VD/' + type);

export interface VideoListFetchedPayload {
    videoList: Video[];
}

export interface ResultsListFetchedPayload {
    videoId: string;
    resultsList: any[];
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

export interface ResultVideoDeletedPayload {
    videoId: string;
    resultVideoId: string;
}

const VideoEvent = {
    videoListFetched: createVideoEvent<VideoListFetchedPayload>('VIDEO_LIST_FETCHED'),
    resultsListFetched: createVideoEvent<ResultsListFetchedPayload>('RESULTS_LIST_FETCHED'),
    downloadableResultFilesFetched: createVideoEvent<DownloadableResultFilesFetchedPayload>('DOWNLOADABLE_RESULT_FILES_FETCHED'),
    blendshapesFetched: createVideoEvent<BlendshapesFetchedPayload>('BLENDSHAPES_FETCHED'),
    mpKinematicsFetched: createVideoEvent<MpKinematicsFetchedPayload>('MP_KINEMATICS_FETCHED'),
    resultVideoDeleted: createVideoEvent<ResultVideoDeletedPayload>('RESULT_VIDEO_DELETED'),
};

export default VideoEvent;
