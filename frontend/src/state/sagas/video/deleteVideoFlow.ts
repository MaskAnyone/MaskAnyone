import { call, fork, put, take } from 'redux-saga/effects';
import { Action } from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import { DeleteVideoPayload } from "../../actions/videoCommand";

const onDeleteVideo = function* (payload: DeleteVideoPayload) {
    try {
        yield call(Api.deleteVideo, payload.videoId);

        yield put(Event.Video.videoDeleted({
            videoId: payload.videoId,
        }));

        yield put(Command.Notification.enqueueNotification({
            severity: 'success',
            message: 'Video deleted successfully',
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to delete video',
        }));
    }
};

export function* deleteVideoFlow() {
    while (true) {
        const action: Action<DeleteVideoPayload> = yield take(Command.Video.deleteVideo.toString());
        yield fork(onDeleteVideo, action.payload);
    }
}
