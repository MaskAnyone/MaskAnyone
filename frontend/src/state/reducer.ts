import {combineReducers} from "redux";
import {videoReducer, VideoState} from "./reducers/videoReducer";
import {uploadReducer, UploadState} from "./reducers/uploadReducer";
import {notificationReducer, NotificationState} from "./reducers/notificationReducer";
import {jobReducer, JobState} from "./reducers/jobReducer";
import {workerReducer, WorkerState} from "./reducers/workerReducer";
import {presetReducer, PresetState} from "./reducers/presetReducer";
import {authReducer, AuthState} from "./reducers/authReducer";

export interface ReduxState {
    video: VideoState;
    upload: UploadState;
    notification: NotificationState;
    job: JobState;
    worker: WorkerState;
    preset: PresetState;
    auth: AuthState;
}

export const rootReducer = combineReducers({
    video: videoReducer,
    upload: uploadReducer,
    notification: notificationReducer,
    job: jobReducer,
    worker: workerReducer,
    preset: presetReducer,
    auth: authReducer,
});
