import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import { CancelJobPayload } from "../../actions/jobCommand";

const onCancelJob = function* (payload: CancelJobPayload) {
    try {
        yield call(Api.cancelJob, payload.id);

        yield put(Command.Notification.enqueueNotification({
            severity: 'info',
            message: 'Cancellation requested — the worker will stop at the next checkpoint.',
        }));
        // Refresh the list so the UI picks up the new 'cancelled' status.
        yield put(Command.Job.fetchJobList({}));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to cancel job',
        }));
    }
};

export function* cancelJobFlow() {
    while (true) {
        const action: Action<CancelJobPayload> = yield take(Command.Job.cancelJob.toString());
        yield fork(onCancelJob, action.payload);
    }
}
