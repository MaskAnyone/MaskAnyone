import {createAction} from 'redux-actions';

const createUploadEvent = <T>(type: string) => createAction<T>('_E/UP/' + type);

export interface UploadDialogOpenedPayload {
}

export interface UploadDialogClosedPayload {
}

const UploadEvent = {
    uploadDialogOpened: createUploadEvent<UploadDialogOpenedPayload>('UPLOAD_DIALOG_OPENED'),
    uploadDialogClosed: createUploadEvent<UploadDialogClosedPayload>('UPLOAD_DIALOG_CLOSED'),
};

export default UploadEvent;
