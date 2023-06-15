import {ReduxState} from "../reducer";
import {Video} from "../types/Video";
import {createSelector} from "reselect";

const videoList = (state: ReduxState): Video[] => state.video.videoList;
const videoMaskingJobs = (state: ReduxState): Record<string, boolean> => state.video.maskingJobs;

const videoNameList = createSelector(
    [videoList],
    videoList => videoList.map(video => video.name),
);

const VideoSelector = {
    videoList,
    videoMaskingJobs,

    videoNameList,
};

export default VideoSelector;
