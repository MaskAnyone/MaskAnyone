import {call, fork, put, take, delay, select} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchJobsResponse} from "../../../api/types";
import {FetchJobListPayload} from "../../actions/jobCommand";
import {Job} from "../../types/Job";

let pollingRunning = false;

const onStartPollingJobListUpdates = function*() {
    if (pollingRunning) {
        return;
    }

    pollingRunning = true;

    while (pollingRunning) {
        yield delay(10000);
        yield put(Command.Job.fetchJobList({}));

        if (!pollingRunning) {
            break;
        }
    }
}

const onFetchJobList = function*(payload: FetchJobListPayload) {
    try {
        const response: ApiFetchJobsResponse = yield call(Api.fetchJobs);

        const jobList: Job[] = response.jobs.map(job => ({
            id: job.id,
            videoId: job.video_id,
            type: job.type,
            status: job.status,
            data: job.data,
            createdAt: new Date(job.created_at),
            startedAt: job.started_at ? new Date(job.started_at) : undefined,
            finishedAt: job.finished_at ? new Date(job.finished_at) : undefined,
        }));

        yield put(Event.Job.jobListFetched({ jobList }));

        if (jobList.some(job => job.status === 'running' || job.status === 'open')) {
            yield fork(onStartPollingJobListUpdates);
        } else {
            pollingRunning = false;
        }
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
