import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {FetchDownloadableResultFilesPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchDownloadableResultFilesResponse} from "../../../api/types";
import {DownloadableResultFile} from "../../types/DownloadableResultFile";

const onFetchDownloadableResultFiles = function*(payload: FetchDownloadableResultFilesPayload) {
    try {
        const response: ApiFetchDownloadableResultFilesResponse = yield call(
            Api.fetchDownloadableResultFiles,
            payload.videoId,
            payload.resultVideoId,
        );

        const downloadableResultFiles: DownloadableResultFile[] = response.files;

        yield put(Event.Video.downloadableResultFilesFetched({
            resultVideoId: payload.resultVideoId,
            files: downloadableResultFiles,
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch downloadable result files',
        }));
    }
};

export function* fetchDownloadableResultFilesFlow() {
    while (true) {
        const action: Action<FetchDownloadableResultFilesPayload> = yield take(Command.Video.fetchDownloadableResultFiles.toString());
        yield fork(onFetchDownloadableResultFiles, action.payload);
    }
}
