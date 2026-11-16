import {call, fork, put, take} from 'redux-saga/effects';
import {channel} from 'redux-saga';
import {Action} from 'redux-actions';
import Command from "../../actions/command";
import Event from "../../actions/event";
import Config from "../../../config";
import {UploadVideosPayload} from "../../actions/uploadCommand";
import Api from "../../../api";
import axios from "axios";

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

const describeUploadError = (error: unknown): string => {
    if (axios.isAxiosError(error)) {
        // The backend's message is user-facing (e.g. it states the upload size limit).
        const detail = (error.response?.data as { detail?: unknown } | undefined)?.detail;
        if (typeof detail === 'string') {
            return detail;
        }
        if (error.response?.status === 413) {
            // Rejected by nginx before reaching the backend, so there is no detail.
            return 'the file is too large for the server.';
        }
        if (!error.response) {
            return 'the connection to the server was lost.';
        }
        return `the server responded with status ${error.response.status}.`;
    }
    return error instanceof Error ? error.message : String(error);
};

const onUploadVideo = function*(file: FileUpload) {
    let pendingVideoCreated = false;

    try {
        yield call(Api.requestVideoUpload, file.id, formatVideoName(file.file.name), file.file.size);
        pendingVideoCreated = true;

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
    } catch (error) {
        const message = describeUploadError(error);
        console.error(`Upload of "${file.file.name}" failed`, error);

        // Remove the half-created video (DB row + partial file) so it doesn't linger as "pending".
        if (pendingVideoCreated) {
            try {
                yield call(Api.deleteVideo, file.id);
            } catch (cleanupError) {
                console.error(`Cleanup of failed upload "${file.file.name}" failed`, cleanupError);
            }
        }

        yield put(Event.Upload.videoUploadFailed({ videoId: file.id, error: message }));
        yield put(Command.Notification.enqueueNotification({
            severity: 'error',
            message: `Upload of "${file.file.name}" failed: ${message}`,
        }));
    }

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
