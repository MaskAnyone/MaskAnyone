import {fork, put, take} from 'redux-saga/effects';
import {v4 as uuidv4} from 'uuid';
import {Action} from 'redux-actions';
import Event from "../../actions/event";
import {EnqueueNotificationPayload} from "../../actions/notificationCommand";
import Command from "../../actions/command";

const DEFAULT_DURATIONS: Record<string, number> = {
    error: 8000,
    warning: 6000,
    success: 4000,
    info: 4000,
};

const onEnqueueSnackbar = function*(
    severity: 'error' | 'warning' | 'success' | 'info',
    message: string,
    autoHideDuration?: number,
) {
    yield put(Event.Notification.notificationEnqueued({
        id: uuidv4(),
        severity,
        message,
        autoHideDuration: autoHideDuration ?? DEFAULT_DURATIONS[severity],
    }));
};

export function* enqueueNotificationFlow() {
    while (true) {
        const action: Action<EnqueueNotificationPayload> = yield take(
            Command.Notification.enqueueNotification.toString(),
        );

        yield fork(
            onEnqueueSnackbar,
            action.payload.severity,
            action.payload.message,
            action.payload.autoHideDuration,
        );
    }
}
