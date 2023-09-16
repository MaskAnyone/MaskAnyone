import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import { FetchResultsListPayload } from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import { ApiFetchAllResultsResponse } from "../../../api/types";
import { ResultVideo } from "../../types/ResultVideo";

const onFetchResultsList = function* (payload: FetchResultsListPayload) {
    try {
        const response: ApiFetchAllResultsResponse = yield call(Api.fetchAllResultsForVideo, payload.videoId);

        const resultsList: ResultVideo[] = response.results.map(result_video => ({
            videoResultId: result_video.video_result_id,
            originalVideoId: result_video.original_video_id,
            jobId: result_video.job_id,
            createdAt: new Date(result_video.created_at),
            jobInfo: result_video.job_info,
            videoResultExists: result_video.video_result_exists,
            kinematicResultsExists: result_video.kinematic_results_exists,
            audioResultsExists: result_video.audio_results_exists,
            blendshapeResultsExists: result_video.blendshape_results_exists,
            extraFileResultsExists: result_video.extra_file_results_exists,
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
