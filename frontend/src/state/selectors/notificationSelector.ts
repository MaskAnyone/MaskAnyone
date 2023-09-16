import {ReduxState} from '../reducer';

const currentNotification = (state: ReduxState) => state.notification.notifications[0] || undefined;

const NotificationSelector = {
    currentNotification,
};

export default NotificationSelector;
