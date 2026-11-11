import {createAction} from 'redux-actions';

const createJobCommand = <T>(type: string) => createAction<T>('_C/JO/' + type);

export interface FetchJobListPayload {
}

export interface DeleteJobPayload {
    id: string;
}

export interface CancelJobPayload {
    id: string;
}

const JobCommand = {
    fetchJobList: createJobCommand<FetchJobListPayload>('FETCH_JOB_LIST'),
    deleteJob: createJobCommand<DeleteJobPayload>('DELETE_JOB'),
    cancelJob: createJobCommand<CancelJobPayload>('CANCEL_JOB'),
};

export default JobCommand;
