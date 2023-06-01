import {combineReducers} from "redux";
import {videoReducer, VideoState} from "./reducers/videoReducer";


export interface ReduxState {
    video: VideoState;
}

export const rootReducer = combineReducers({
    video: videoReducer,
});
