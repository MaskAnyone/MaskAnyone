import {call, fork, put, take} from 'redux-saga/effects';
import {channel} from 'redux-saga';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Event from "../../actions/event";
import Config from "../../../config";
import {UploadVideosPayload} from "../../actions/uploadCommand";
import Api from "../../../api";

interface FileUpload {
    file: File;
    id: string;
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

const formatVideoName = (fileName: string): string => {
    const nameWithoutExt = fileName.replace(/\.[^.]+$/, '');
    const now = new Date();
    const date = now.toLocaleDateString('en-CA'); // YYYY-MM-DD
    const time = now.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' }); // HH:MM
    return `${nameWithoutExt} - ${date} ${time}`;
};

const onUploadVideo = function*(file: FileUpload) {
    yield call(Api.requestVideoUpload, file.id, formatVideoName(file.file.name));

    // Pass the File directly — axios streams it from disk, fires upload progress
    // events from byte 0, and avoids loading the whole file into the JS heap
    // (which previously doubled browser RAM and silently blocked for ~5–15 s
    // on multi-hundred-MB files).
    yield call(Api.uploadVideo, file.id, file.file, percentage => {
        uploadProgressChannel.put(
            Event.Upload.videoUploadProgressChanged({ videoId: file.id, progress: percentage }),
        );
    });

    yield call(Api.finalizeVideoUpload, file.id);

    yield put(Event.Upload.videoUploadFinished({ videoId: file.id }));
    yield put(Command.Video.fetchVideoList({}));
};

const onUploadVideos = function*(files: Array<FileUpload>) {
    for (const file of files) {
        yield put(uploadChannel, { file });
        yield put(Event.Upload.videoUploadStarted({ videoId: file.id }));
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
