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

const videoActiveJobCountRecord = createSelector(
    [jobList],
    (jobList): Record<string, number> => {
        const jobRecord: Record<string, number> = {};
        const activeJobList = jobList.filter(job => job.status === 'open' || job.status === 'running');

        for (const job of activeJobList) {
            if (!jobRecord[job.videoId]) {
                jobRecord[job.videoId] = 0;
            }

            jobRecord[job.videoId] = jobRecord[job.videoId] + 1;
        }

        return jobRecord;
    },
);

const JobSelector = {
    jobList,

    openAndRunningJobCount,
    videoActiveJobCountRecord,
};

export default JobSelector;
