import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {NotificationDequeuedPayload, NotificationEnqueuedPayload} from "../actions/notificationEvent";

export interface NotificationState {
    notifications: Array<{
        id: string;
        severity: 'error'|'warning'|'info'|'success';
        message: string;
        autoHideDuration: number;
    }>;
}

export const initialState: NotificationState = {
    notifications: [],
};

export const notificationReducer = handleActions<NotificationState, any>(
    {
        [Event.Notification.notificationEnqueued.toString()]:
            (state, action: Action<NotificationEnqueuedPayload>): NotificationState => {
                return {
                    ...state,
                    notifications: [...state.notifications, {
                        id: action.payload.id,
                        severity: action.payload.severity,
                        message: action.payload.message,
                        autoHideDuration: action.payload.autoHideDuration,
                    }],
                };
            },
        [Event.Notification.notificationDequeued.toString()]:
            (state, action: Action<NotificationDequeuedPayload>): NotificationState => {
                return {
                    ...state,
                    notifications: [
                        ...state.notifications.filter(notification => notification.id !== action.payload.id),
                    ],
                };
            },
    },
    initialState,
);
