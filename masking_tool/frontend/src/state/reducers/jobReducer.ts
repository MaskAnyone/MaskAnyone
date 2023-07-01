import {Action, handleActions} from 'redux-actions';
import Event from "../actions/event";
import {JobListFetchedPayload} from "../actions/jobEvent";
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
    },
    jobInitialState,
);
