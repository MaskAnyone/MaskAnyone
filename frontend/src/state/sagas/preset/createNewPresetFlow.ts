import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {CreateNewPresetPayload} from "../../actions/presetCommand";
import {v4 as uuidv4} from "uuid";

const onCreateNewPreset = function*(payload: CreateNewPresetPayload) {
    try {
        const presetId = uuidv4();

        yield call(
            Api.createNewPreset,
            presetId,
            payload.newPreset.name,
            payload.newPreset.description,
            payload.newPreset.data,
            payload.videoId,
            payload.resultVideoId,
        );

        yield put(Event.Preset.newPresetCreated({
            preset: {
                id: presetId,
                ...payload.newPreset,
            },
        }));

        yield put(Command.Notification.enqueueNotification({
            severity: 'success',
            message: 'The preset has been created.',
        }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to create new preset',
        }));
    }
};

export function* createNewPresetFlow() {
    while (true) {
        const action: Action<CreateNewPresetPayload> = yield take(Command.Preset.createNewPreset.toString());
        yield fork(onCreateNewPreset, action.payload);
    }
}
