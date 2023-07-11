import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchWorkersResponse} from "../../../api/types";
import {FetchWorkerListPayload} from "../../actions/workerCommand";
import {Worker} from "../../types/Worker";


const onFetchWorkerList = function*(payload: FetchWorkerListPayload) {
    try {
        const response: ApiFetchWorkersResponse = yield call(Api.fetchWorkers);

        const workerList: Worker[] = response.workers.map(worker => ({
            id: worker.id,
            jobId: worker.job_id,
            lastActivity: new Date(worker.last_activity),
        }));

        yield put(Event.Worker.workerListFetched({ workerList }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch worker list',
        }));
    }
};

export function* fetchWorkerListFlow() {
    while (true) {
        const action: Action<FetchWorkerListPayload> = yield take(Command.Worker.fetchWorkerList.toString());
        yield fork(onFetchWorkerList, action.payload);
    }
}
