import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchJobsResponse, ApiFetchVideosResponse} from "../../../api/types";
import {FetchJobListPayload} from "../../actions/jobCommand";
import {Job} from "../../types/Job";

const onFetchJobList = function*(payload: FetchJobListPayload) {
    try {
        const response: ApiFetchJobsResponse = yield call(Api.fetchJobs);

        const jobList: Job[] = response.jobs.map(job => ({
            id: job.id,
        }));

        yield put(Event.Job.jobListFetched({ jobList }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch job list',
        }));
    }
};

export function* fetchJobListFlow() {
    while (true) {
        const action: Action<FetchJobListPayload> = yield take(Command.Job.fetchJobList.toString());
        yield fork(onFetchJobList, action.payload);
    }
}
