import {combineReducers} from "redux";
import {videoReducer, VideoState} from "./reducers/videoReducer";
import {uploadReducer, UploadState} from "./reducers/uploadReducer";
import {notificationReducer, NotificationState} from "./reducers/notificationReducer";
import {jobReducer, JobState} from "./reducers/jobReducer";


export interface ReduxState {
    video: VideoState;
    upload: UploadState;
    notification: NotificationState;
    job: JobState;
}

export const rootReducer = combineReducers({
    video: videoReducer,
    upload: uploadReducer,
    notification: notificationReducer,
    job: jobReducer,
});
