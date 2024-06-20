import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {DeleteResultVideoPayload} from "../../actions/videoCommand";

const onDeleteResultVideo = function* (payload: DeleteResultVideoPayload) {
    try {
        yield call(Api.deleteResultVideo, payload.resultVideoId);

        yield put(Event.Video.resultVideoDeleted({ resultVideoId: payload.resultVideoId }));
        yield put(Command.Notification.enqueueNotification({
            severity: 'success',
            message: 'Result video deleted successfully',
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to delete result video',
        }));
    }
};

export function* deleteResultVideoFlow() {
    while (true) {
        const action: Action<DeleteResultVideoPayload> = yield take(Command.Video.deleteResultVideo.toString());
        yield fork(onDeleteResultVideo, action.payload);
    }
}
