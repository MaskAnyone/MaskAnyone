import {ReduxState} from "../reducer";
import {Video} from "../types/Video";

const videoList = (state: ReduxState): Video[] => state.video.videoList;

const VideoSelector = {
    videoList,
};

export default VideoSelector;
