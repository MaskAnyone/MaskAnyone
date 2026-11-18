import {createAction} from 'redux-actions';

const createUploadEvent = <T>(type: string) => createAction<T>('_E/UP/' + type);

export interface UploadDialogOpenedPayload {
}

export interface UploadDialogClosedPayload {
}

export interface VideoUploadStartedPayload {
    videoId: string;
}

export interface VideoUploadProgressChangedPayload {
    videoId: string;
    progress: number;
}

export interface VideoUploadFinishedPayload {
    videoId: string;
}

export interface VideoUploadFailedPayload {
    videoId: string;
    error: string;
}

const UploadEvent = {
    uploadDialogOpened: createUploadEvent<UploadDialogOpenedPayload>('UPLOAD_DIALOG_OPENED'),
    uploadDialogClosed: createUploadEvent<UploadDialogClosedPayload>('UPLOAD_DIALOG_CLOSED'),
    videoUploadStarted: createUploadEvent<VideoUploadStartedPayload>('VIDEO_UPLOAD_STARTED'),
    videoUploadProgressChanged: createUploadEvent<VideoUploadProgressChangedPayload>('VIDEO_UPLOAD_PROGRESS_CHANGED'),
    videoUploadFinished: createUploadEvent<VideoUploadFinishedPayload>('VIDEO_UPLOAD_FINISHED'),
    videoUploadFailed: createUploadEvent<VideoUploadFailedPayload>('VIDEO_UPLOAD_FAILED'),
};

export default UploadEvent;
