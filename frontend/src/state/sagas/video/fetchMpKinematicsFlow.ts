import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {FetchMpKinematicsPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";

const onFetchMpKinematics = function*(payload: FetchMpKinematicsPayload) {
    try {
        // @ts-ignore
        const response: any = yield call(
            Api.fetchMpKinematics,
            payload.resultVideoId,
        );

        yield put(Event.Video.mpKinematicsFetched({
            mpKinematics: response,
            resultVideoId: payload.resultVideoId,
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch mp kinematics',
        }));
    }
};

export function* fetchMpKinematicsFlow() {
    while (true) {
        const action: Action<FetchMpKinematicsPayload> = yield take(Command.Video.fetchMpKinematics.toString());
        yield fork(onFetchMpKinematics, action.payload);
    }
}
