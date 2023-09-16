import {ReduxState} from "../reducer";
import {Worker} from "../types/Worker";

const workerList = (state: ReduxState): Worker[] => state.worker.workerList;

const WorkerSelector = {
    workerList,
};

export default WorkerSelector;
