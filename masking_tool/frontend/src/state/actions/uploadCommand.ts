import {createAction} from 'redux-actions';

const createUploadCommand = <T>(type: string) => createAction<T>('_C/UP/' + type);

export interface UploadVideosPayload {
    videos: Array<{ file: File, tags: string[] }>;
}

const UploadCommand = {
    uploadVideos: createUploadCommand<UploadVideosPayload>('UPLOAD_VIDEOS'),
};

export default UploadCommand;
