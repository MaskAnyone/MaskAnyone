import {combineReducers} from "redux";
import {videoReducer, VideoState} from "./reducers/videoReducer";
import {uploadReducer, UploadState} from "./reducers/uploadReducer";
import {notificationReducer, NotificationState} from "./reducers/notificationReducer";
import {jobReducer, JobState} from "./reducers/jobReducer";
import {workerReducer, WorkerState} from "./reducers/workerReducer";


export interface ReduxState {
    video: VideoState;
    upload: UploadState;
    notification: NotificationState;
    job: JobState;
    worker: WorkerState;
}

export const rootReducer = combineReducers({
    video: videoReducer,
    upload: uploadReducer,
    notification: notificationReducer,
    job: jobReducer,
    worker: workerReducer,
});
