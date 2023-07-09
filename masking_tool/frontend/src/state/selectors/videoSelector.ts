import {ReduxState} from "../reducer";
import {Video} from "../types/Video";
import {createSelector} from "reselect";
import {ResultVideo} from "../types/ResultVideo";
import {DownloadableResultFile} from "../types/DownloadableResultFile";

const videoList = (state: ReduxState): Video[] => state.video.videoList;
const resultVideoLists = (state: ReduxState): Record<string, ResultVideo[]> => state.video.resultVideoLists;
const downloadableResultFileLists = (state: ReduxState): Record<string, DownloadableResultFile[]> => state.video.downloadableResultFileLists;

const videoNameList = createSelector(
    [videoList],
    videoList => videoList.map(video => video.name),
);

const VideoSelector = {
    videoList,
    resultVideoLists,
    downloadableResultFileLists,

    videoNameList,
};

export default VideoSelector;
