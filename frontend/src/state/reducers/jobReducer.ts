import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {JobDeletedPayload, JobListFetchedPayload} from "../actions/jobEvent";
import {Job} from "../types/Job";

export interface JobState {
    jobList: Job[];
}

export const jobInitialState: JobState = {
    jobList: [],
};

/* eslint-disable max-len */
export const jobReducer = handleActions<JobState, any>(
    {
        [Event.Job.jobListFetched.toString()]: (state, action: Action<JobListFetchedPayload>): JobState => {
            return {
                ...state,
                jobList: action.payload.jobList,
            };
        },
        [Event.Job.jobDeleted.toString()]: (state, action: Action<JobDeletedPayload>): JobState => {
            return {
                ...state,
                jobList: state.jobList.filter(job => job.id !== action.payload.id),
            };
        },
    },
    jobInitialState,
);
