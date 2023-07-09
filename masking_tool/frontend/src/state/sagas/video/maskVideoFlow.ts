import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {MaskVideoPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";

const onMaskVideo = function*(payload: MaskVideoPayload) {
    try {
        yield call(
            Api.createBasicMaskingJob,
            payload.id,
            payload.videoId,
            payload.resultVideoId,
            payload.runData
        );

        yield put(Command.Job.fetchJobList({}));

        yield put(Command.Notification.enqueueNotification({
            severity: 'success',
            message: 'Video masking process started',
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Video masking could not be started',
        }));
    }
};

export function* maskVideoFlow() {
    while (true) {
        const action: Action<MaskVideoPayload> = yield take(Command.Video.maskVideo.toString());
        yield fork(onMaskVideo, action.payload);
    }
}
