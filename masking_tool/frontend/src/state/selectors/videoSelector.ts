import {ReduxState} from "../reducer";
import {Video} from "../types/Video";
import {createSelector} from "reselect";
import {ResultVideo} from "../types/ResultVideo";

const videoList = (state: ReduxState): Video[] => state.video.videoList;
const resultVideoLists = (state: ReduxState): Record<string, ResultVideo[]> => state.video.resultVideoLists;

const videoNameList = createSelector(
    [videoList],
    videoList => videoList.map(video => video.name),
);

const VideoSelector = {
    videoList,
    resultVideoLists,

    videoNameList,
};

export default VideoSelector;
