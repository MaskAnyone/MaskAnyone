import {createAction} from 'redux-actions';

const createWorkerCommand = <T>(type: string) => createAction<T>('_C/WO/' + type);

export interface FetchWorkerListPayload {
}

const WorkerCommand = {
    fetchWorkerList: createWorkerCommand<FetchWorkerListPayload>('FETCH_WORKER_LIST'),
};

export default WorkerCommand;
