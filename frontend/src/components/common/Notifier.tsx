import React, {useEffect, useState} from 'react';
import {useDispatch, useSelector} from 'react-redux';
import {Alert, Snackbar} from '@mui/material';
import Selector from "../../state/selector";
import Event from "../../state/actions/event";

const Notifier = () => {
    const dispatch = useDispatch();
    const notification = useSelector(Selector.Notification.currentNotification);
    const [open, setOpen] = useState<boolean>(false);

    const closeNotification = () => {
        if (notification) {
            dispatch(Event.Notification.notificationDequeued({id: notification.id}));
        }
    };

    useEffect(() => {
        setOpen(false);

        if (notification) {
            setTimeout(() => setOpen(true), 70);
            setTimeout(closeNotification, notification.autoHideDuration);
        }
    }, [notification]);

    return (
        <Snackbar
            key={notification?.id + (open ? 'open' : 'closed')}
            open={open}
            anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
            children={(
                <Alert
                    severity={notification?.severity}
                    onClose={closeNotification}
                    variant={'filled'}
                >
                    {notification?.message}
                </Alert>
            )}
        />
    );
};

export default Notifier;
