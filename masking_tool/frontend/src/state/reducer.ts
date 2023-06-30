import {combineReducers} from "redux";
import {videoReducer, VideoState} from "./reducers/videoReducer";
import {uploadReducer, UploadState} from "./reducers/uploadReducer";
import {notificationReducer, NotificationState} from "./reducers/notificationReducer";


export interface ReduxState {
    video: VideoState;
    upload: UploadState;
    notification: NotificationState;
}

export const rootReducer = combineReducers({
    video: videoReducer,
    upload: uploadReducer,
    notification: notificationReducer,
});
