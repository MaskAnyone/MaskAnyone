import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {FetchVideoListPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";

const onFetchVideoList = function*(payload: FetchVideoListPayload) {
    try {
        const videoList: any[] = yield call(Api.fetchVideos);
        yield put(Event.Video.videoListFetched({ videoList }));
    } catch (e) {
        console.error(e);
    }
};

export function* fetchVideoListFlow() {
    while (true) {
        const action: Action<FetchVideoListPayload> = yield take(Command.Video.fetchVideoList.toString());
        yield fork(onFetchVideoList, action.payload);
    }
}
