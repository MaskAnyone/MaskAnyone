import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {FetchBlendshapesPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";

const onFetchBlendshapes = function*(payload: FetchBlendshapesPayload) {
    try {
        // @ts-ignore
        const response: any = yield call(
            Api.fetchBlendshapes,
            payload.resultVideoId,
        );

        yield put(Event.Video.blendshapesFetched({
            blendshapes: response,
            resultVideoId: payload.resultVideoId,
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch blendshapes',
        }));
    }
};

export function* fetchBlendshapesFlow() {
    while (true) {
        const action: Action<FetchBlendshapesPayload> = yield take(Command.Video.fetchBlendshapes.toString());
        yield fork(onFetchBlendshapes, action.payload);
    }
}
