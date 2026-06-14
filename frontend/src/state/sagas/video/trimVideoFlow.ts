import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import { TrimVideoPayload } from "../../actions/videoCommand";

const onTrimVideo = function* (payload: TrimVideoPayload) {
    try {
        yield put(Event.Video.videoTrimStarted({}));

        yield call(
            Api.trimVideo,
            payload.videoId,
            payload.newVideoId,
            payload.newVideoName,
            payload.startTime,
            payload.endTime,
        );

        yield put(Event.Video.videoTrimFinished({}));

        // Refresh the video list so the new trimmed video appears in the sidebar
        yield put(Command.Video.fetchVideoList({}));

        yield put(Command.Notification.enqueueNotification({
            severity: 'success',
            message: 'Video trimmed successfully',
        }));
    } catch (e) {
        console.error(e);
        yield put(Event.Video.videoTrimFailed({}));
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to trim video',
        }));
    }
};

export function* trimVideoFlow() {
    while (true) {
        const action: Action<TrimVideoPayload> = yield take(Command.Video.trimVideo.toString());
        yield fork(onTrimVideo, action.payload);
    }
}
