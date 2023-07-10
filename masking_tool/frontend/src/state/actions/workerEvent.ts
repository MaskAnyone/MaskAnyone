import {createAction} from 'redux-actions';
import {Worker} from "../types/Worker";

const createWorkerEvent = <T>(type: string) => createAction<T>('_E/WO/' + type);

export interface WorkerListFetchedPayload {
    workerList: Worker[];
}

const WorkerEvent = {
    workerListFetched: createWorkerEvent<WorkerListFetchedPayload>('WORKER_LIST_FETCHED'),
};

export default WorkerEvent;
