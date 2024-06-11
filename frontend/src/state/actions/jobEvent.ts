import {createAction} from 'redux-actions';
import {Job} from "../types/Job";

const createJobEvent = <T>(type: string) => createAction<T>('_E/JO/' + type);

export interface JobListFetchedPayload {
    jobList: Job[];
}

export interface JobDeletedPayload {
    id: string;
}

const JobEvent = {
    jobListFetched: createJobEvent<JobListFetchedPayload>('JOB_LIST_FETCHED'),
    jobDeleted: createJobEvent<JobDeletedPayload>('JOB_DELETED'),
};

export default JobEvent;
