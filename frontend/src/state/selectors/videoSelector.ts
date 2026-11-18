import { ReduxState } from "../reducer";
import { Video } from "../types/Video";
import { createSelector } from "reselect";
import { ResultVideo } from "../types/ResultVideo";
import { DownloadableResultFile } from "../types/DownloadableResultFile";
import { TrimStatus } from "../reducers/videoReducer";

const videoList = (state: ReduxState): Video[] => state.video.videoList;
const resultVideoLists = (state: ReduxState): Record<string, ResultVideo[]> => state.video.resultVideoLists;
const downloadableResultFileLists = (state: ReduxState): Record<string, DownloadableResultFile[]> => state.video.downloadableResultFileLists;
const blendshapesList = (state: ReduxState): Record<string, any> => state.video.blendshapesList;
const mpKinematicsList = (state: ReduxState): Record<string, any> => state.video.mpKinematicsList;
const trimStatus = (state: ReduxState): TrimStatus => state.video.trimStatus;

const videoNameList = createSelector(
    [videoList],
    videoList => videoList.map(video => video.name),
);

const VideoSelector = {
    videoList,
    resultVideoLists,
    downloadableResultFileLists,
    blendshapesList,
    mpKinematicsList,
    trimStatus,

    videoNameList,
};

export default VideoSelector;
