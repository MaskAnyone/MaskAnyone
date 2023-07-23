import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {DeletePresetPayload} from "../../actions/presetCommand";

const onDeletePreset = function*(payload: DeletePresetPayload) {
    try {
        yield call(Api.deletePreset, payload.id);

        yield put(Event.Preset.presetDeleted({ id: payload.id }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to delete preset',
        }));
    }
};

export function* deletePresetFlow() {
    while (true) {
        const action: Action<DeletePresetPayload> = yield take(Command.Preset.deletePreset.toString());
        yield fork(onDeletePreset, action.payload);
    }
}
