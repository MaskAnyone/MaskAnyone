import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {MaskVideoPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";

const onMaskVideo = function*(payload: MaskVideoPayload) {
    try {
        yield put(Event.Video.videoMaskingStarted({ videoName: payload.videoName }));

        yield call(
            Api.maskVideo,
            payload.videoName,
            payload.extractPersonOnly,
            payload.headOnlyHiding,
            payload.hidingStrategy,
            payload.headOnlyMasking,
            payload.maskCreationStrategy,
            payload.detailedFingers,
            payload.detailedFaceMesh
        );

        yield put(Event.Video.videoMaskingFinished({ videoName: payload.videoName }));
    } catch (e) {
        console.error(e);
        yield put(Event.Video.videoMaskingFailed({ videoName: payload.videoName }));
    }
};

export function* maskVideoFlow() {
    while (true) {
        const action: Action<MaskVideoPayload> = yield take(Command.Video.maskVideo.toString());
        yield fork(onMaskVideo, action.payload);
    }
}
