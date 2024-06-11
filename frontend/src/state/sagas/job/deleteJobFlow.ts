import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import {DeleteJobPayload} from "../../actions/jobCommand";
import Event from "../../actions/event";

const onDeleteJob = function* (payload: DeleteJobPayload) {
    try {
        yield call(Api.deleteJob, payload.id);

        yield put(Event.Job.jobDeleted({ id: payload.id }));
        yield put(Command.Notification.enqueueNotification({
            severity: 'success',
            message: 'Job deleted successfully',
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to delete job',
        }));
    }
};

export function* deleteJobFlow() {
    while (true) {
        const action: Action<DeleteJobPayload> = yield take(Command.Job.deleteJob.toString());
        yield fork(onDeleteJob, action.payload);
    }
}
