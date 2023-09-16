import {fork, put, take} from 'redux-saga/effects';
import {v4 as uuidv4} from 'uuid';
import {Action} from 'redux-actions';
import Event from "../../actions/event";
import {EnqueueNotificationPayload} from "../../actions/notificationCommand";
import Command from "../../actions/command";

const onEnqueueErrorSnackbar = function*(message: string, autoHideDuration: number = 4000) {
    yield put(Event.Notification.notificationEnqueued({
        id: uuidv4(),
        severity: 'error',
        message: message,
        autoHideDuration,
    }));
};

const onEnqueueSuccessSnackbar = function*(message: string, autoHideDuration: number = 4000) {
    yield put(Event.Notification.notificationEnqueued({
        id: uuidv4(),
        severity: 'success',
        message: message,
        autoHideDuration,
    }));
};

const onEnqueueWarningSnackbar = function*(message: string, autoHideDuration: number = 4000) {
    yield put(Event.Notification.notificationEnqueued({
        id: uuidv4(),
        severity: 'warning',
        message: message,
        autoHideDuration,
    }));
};

const onEnqueueInfoSnackbar = function*(message: string, autoHideDuration: number = 4000) {
    yield put(Event.Notification.notificationEnqueued({
        id: uuidv4(),
        severity: 'info',
        message: message,
        autoHideDuration,
    }));
};

export function* enqueueNotificationFlow() {
    while (true) {
        const action: Action<EnqueueNotificationPayload> = yield take(
            Command.Notification.enqueueNotification.toString(),
        );

        switch (action.payload.severity) {
            case 'error':
                yield fork(onEnqueueErrorSnackbar, action.payload.message, action.payload.autoHideDuration);
                break;
            case 'success':
                yield fork(onEnqueueSuccessSnackbar, action.payload.message, action.payload.autoHideDuration);
                break;
            case 'warning':
                yield fork(onEnqueueWarningSnackbar, action.payload.message, action.payload.autoHideDuration);
                break;
            case 'info':
                yield fork(onEnqueueInfoSnackbar, action.payload.message, action.payload.autoHideDuration);
                break;
        }
    }
}
