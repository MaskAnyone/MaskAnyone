import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchPresetsResponse} from "../../../api/types";
import {FetchPresetListPayload} from "../../actions/presetCommand";
import {Preset} from "../../types/Preset";

const onFetchPresetList = function*(payload: FetchPresetListPayload) {
    try {
        const response: ApiFetchPresetsResponse = yield call(Api.fetchPresets);

        const presetList: Preset[] = response.presets.map(preset => ({
            id: preset.id,
            name: preset.name,
            description: preset.description,
            data: preset.data
        }));

        yield put(Event.Preset.presetListFetched({ presetList }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch preset list',
        }));
    }
};

export function* fetchPresetListFlow() {
    while (true) {
        const action: Action<FetchPresetListPayload> = yield take(Command.Preset.fetchPresetList.toString());
        yield fork(onFetchPresetList, action.payload);
    }
}
