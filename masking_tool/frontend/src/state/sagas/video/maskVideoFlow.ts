import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {MaskVideoPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";

const onMaskVideo = function*(payload: MaskVideoPayload) {
    try {
        yield put(Event.Video.videoMaskingStarted({ videoId: payload.videoId }));

        yield call(
            Api.maskVideo,
            payload.id,
            payload.videoId,
            payload.extractPersonOnly,
            payload.headOnlyHiding,
            payload.hidingStrategy,
            payload.headOnlyMasking,
            payload.maskCreationStrategy,
            payload.detailedFingers,
            payload.detailedFaceMesh
        );

        yield put(Event.Video.videoMaskingFinished({ videoId: payload.videoId }));
    } catch (e) {
        console.error(e);
        yield put(Event.Video.videoMaskingFailed({ videoId: payload.videoId }));
    }
};

export function* maskVideoFlow() {
    while (true) {
        const action: Action<MaskVideoPayload> = yield take(Command.Video.maskVideo.toString());
        yield fork(onMaskVideo, action.payload);
    }
}
