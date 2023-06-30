import {call, fork, put, take} from 'redux-saga/effects';
import {Action} from 'redux-actions';
import {FetchVideoListPayload} from "../../actions/videoCommand";
import Command from "../../actions/command";
import Api from "../../../api";
import Event from "../../actions/event";
import {ApiFetchVideosResponse} from "../../../api/types";
import {Video} from "../../types/Video";

const onFetchVideoList = function*(payload: FetchVideoListPayload) {
    try {
        const response: ApiFetchVideosResponse = yield call(Api.fetchVideos);

        const videoList: Video[] = response.videos.map(video => ({
            id: video.id,
            name: video.name,
            status: video.status,
            videoInfo: {
                fps: video.video_info.fps,
                codec: video.video_info.codec,
                duration: video.video_info.duration,
                frameCount: video.video_info.frame_count,
                frameWidth: video.video_info.frame_width,
                frameHeight: video.video_info.frame_height,
            },
        }));

        yield put(Event.Video.videoListFetched({ videoList }));
    } catch (e) {
        console.error(e);
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: 'Failed to fetch video list',
        }));
    }
};

export function* fetchVideoListFlow() {
    while (true) {
        const action: Action<FetchVideoListPayload> = yield take(Command.Video.fetchVideoList.toString());
        yield fork(onFetchVideoList, action.payload);
    }
}
