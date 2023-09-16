import {createAction} from 'redux-actions';
import {Job} from "../types/Job";

const createJobEvent = <T>(type: string) => createAction<T>('_E/JO/' + type);

export interface JobListFetchedPayload {
    jobList: Job[];
}

const JobEvent = {
    jobListFetched: createJobEvent<JobListFetchedPayload>('JOB_LIST_FETCHED'),
};

export default JobEvent;
