import {ReduxState} from "../reducer";
import {createSelector} from "reselect";
import {Job} from "../types/Job";

const jobList = (state: ReduxState): Job[] => state.job.jobList;

const openAndRunningJobCount = createSelector(
    [jobList],
    (jobList): number => jobList
        .filter(job => job.status === 'open' || job.status === 'running')
        .length,
);

const VideoSelector = {
    jobList,

    openAndRunningJobCount,
};

export default VideoSelector;
