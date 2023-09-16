import {createAction} from 'redux-actions';

const createJobCommand = <T>(type: string) => createAction<T>('_C/JO/' + type);

export interface FetchJobListPayload {
}

const JobCommand = {
    fetchJobList: createJobCommand<FetchJobListPayload>('FETCH_JOB_LIST'),
};

export default JobCommand;
