import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {FetchResultVideoListPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchResultVideosResponse} from "../../../api/types";
import {ResultVideo} from "../../types/ResultVideo";

const onFetchResultVideoList = function*(payload: FetchResultVideoListPayload) {
    try {
        const response: ApiFetchResultVideosResponse = yield call(Api.fetchVideoResults, payload.videoId);

        const resultVideoList: ResultVideo[] = response.result_videos.map(result_video => ({
            id: result_video.id,
            videoId: result_video.video_id,
            jobId: result_video.job_id,
            name: result_video.name,
            videoInfo: {},
            createdAt: new Date(result_video.created_at),
        }));

        yield put(Event.Video.resultVideoListFetched({ videoId: payload.videoId, resultVideoList }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch result video list',
        }));
    }
};

export function* fetchResultVideoListFlow() {
    while (true) {
        const action: Action<FetchResultVideoListPayload> = yield take(Command.Video.fetchResultVideoList.toString());
        yield fork(onFetchResultVideoList, action.payload);
    }
}
