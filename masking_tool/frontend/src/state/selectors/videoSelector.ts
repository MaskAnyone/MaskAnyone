import {ReduxState} from "../reducer";
import {Video} from "../types/Video";
import {createSelector} from "reselect";

const videoList = (state: ReduxState): Video[] => state.video.videoList;

const videoNameList = createSelector(
    [videoList],
    videoList => videoList.map(video => video.name),
);

const VideoSelector = {
    videoList,

    videoNameList,
};

export default VideoSelector;
