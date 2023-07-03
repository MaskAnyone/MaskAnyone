import {createAction} from 'redux-actions';

const createNotificationEvent = <T>(type: string) => createAction<T>('_E/NO/' + type);

export interface NotificationEnqueuedPayload {
    id: string;
    severity: 'error'|'warning'|'info'|'success';
    message: string;
    autoHideDuration: number;
}

export interface NotificationDequeuedPayload {
    id: string;
}

/* eslint-disable max-len */
const NotificationEvent = {
    notificationEnqueued: createNotificationEvent<NotificationEnqueuedPayload>('NOTIFICATION_ENQUEUED'),
    notificationDequeued: createNotificationEvent<NotificationDequeuedPayload>('NOTIFICATION_DEQUEUED'),
};

export default NotificationEvent;
