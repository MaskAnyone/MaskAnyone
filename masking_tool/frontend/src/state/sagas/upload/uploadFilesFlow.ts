import {call, fork, put, select, take} from 'redux-saga/effects';
import {channel} from 'redux-saga';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Event from "../../actions/event";
import Config from "../../../config";
import {readFileArrayBuffer} from "../../../util/readFile";
import {UploadVideosPayload} from "../../actions/uploadCommand";
import Api from "../../../api";

interface FileUpload {
    file: File;
    tags: string[];
}

const uploadChannel = channel();
const uploadProgressChannel = channel();

const onStartFileUploadWatcher = function*() {
    while (true) {
        const payload: { file: FileUpload } = yield take(uploadChannel);
        yield call(onUploadVideo, payload.file);
    }
};

const onUploadVideo = function*(file: FileUpload) {
    yield call(Api.requestVideoUpload, file.file.name);

    const fileContent: ArrayBuffer = yield call(readFileArrayBuffer, file.file);
    yield call(Api.uploadVideo, file.file.name, fileContent, percentage => {
        uploadProgressChannel.put(
            Event.Upload.videoUploadProgressChanged({ videoName: file.file.name, progress: percentage }),
        );
    });

    yield call(Api.finalizeVideoUpload, file.file.name);

    yield put(Event.Upload.videoUploadFinished({ videoName: file.file.name }));
    yield put(Command.Video.fetchVideoList({}));
};

const onUploadVideos = function*(files: Array<FileUpload>) {
    for (const file of files) {
        yield put(uploadChannel, { file });
        yield put(Event.Upload.videoUploadStarted({ videoName: file.file.name }));
    }
};

export function* uploadFilesFlow() {
    for (let i = 0; i < Config.upload.concurrency; i++) {
        yield fork(onStartFileUploadWatcher);
    }

    while (true) {
        const action: Action<UploadVideosPayload> = yield take(Command.Upload.uploadVideos);
        yield fork(onUploadVideos, action.payload.videos);
    }
}

export function* uploadProgressWatcherFlow() {
    while (true) {
        const action: Action<any> = yield take(uploadProgressChannel);
        yield put(action);
    }
}
