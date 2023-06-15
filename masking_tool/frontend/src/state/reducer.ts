import {combineReducers} from "redux";
import {videoReducer, VideoState} from "./reducers/videoReducer";
import {uploadReducer, UploadState} from "./reducers/uploadReducer";


export interface ReduxState {
    video: VideoState;
    upload: UploadState;
}

export const rootReducer = combineReducers({
    video: videoReducer,
    upload: uploadReducer,
});
