import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import { FetchResultsListPayload } from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import { ApiFetchResultVideosResponse } from "../../../api/types";
import { ResultVideo } from "../../types/ResultVideo";

const onFetchResultsList = function* (payload: FetchResultsListPayload) {
    try {
        const response: ApiFetchResultVideosResponse = yield call(Api.fetchVideoResults, payload.videoId);

        const resultsList: ResultVideo[] = response.result_videos.map(result_video => ({
            videoResultId: result_video.id,
            originalVideoId: result_video.video_id,
            jobId: result_video.job_id,
            createdAt: new Date(result_video.created_at),

            // jobInfo: result_video.job_info,
            jobInfo: {},
            videoInfo: result_video.video_info,
            name: result_video.name
        }));

        yield put(Event.Video.resultsListFetched({ videoId: payload.videoId, resultsList }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch result video list',
        }));
    }
};

export function* fetchResultListFlow() {
    while (true) {
        const action: Action<FetchResultsListPayload> = yield take(Command.Video.fetchResultsList.toString());
        yield fork(onFetchResultsList, action.payload);
    }
}
