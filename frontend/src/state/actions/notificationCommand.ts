import {createAction} from 'redux-actions';

const createNotificationCommand = <T>(type: string) => createAction<T>('_C/NO/' + type);

export interface EnqueueNotificationPayload {
    severity: 'error'|'warning'|'info'|'success';
    message: string;
    autoHideDuration?: number;
}

/* eslint-disable max-len */
const NotificationCommand = {
    enqueueNotification: createNotificationCommand<EnqueueNotificationPayload>('ENQUEUE_NOTIFICATION'),
};

export default NotificationCommand;
