import { all, call, delay, spawn } from 'redux-saga/effects';
import { uploadFilesFlow, uploadProgressWatcherFlow } from "./sagas/upload/uploadFilesFlow";
import { fetchVideoListFlow } from "./sagas/video/fetchVideoListFlow";
import { maskVideoFlow } from "./sagas/video/maskVideoFlow";
import { fetchJobListFlow } from "./sagas/job/fetchJobListFlow";
import { enqueueNotificationFlow } from "./sagas/notification/enqueueNotificationFlow";
import { fetchResultListFlow } from "./sagas/video/fetchResultVideoListFlow";
import { fetchDownloadableResultFilesFlow } from "./sagas/video/fetchDownloadableResultFilesFlow";
import { fetchWorkerListFlow } from "./sagas/worker/fetchWorkerListFlow";
import { fetchPresetListFlow } from "./sagas/preset/fetchPresetListFlow";
import { deletePresetFlow } from "./sagas/preset/deletePresetFlow";
import { createNewPresetFlow } from "./sagas/preset/createNewPresetFlow";
import { fetchBlendshapesFlow } from "./sagas/video/fetchBlendshapesFlow";
import { fetchMpKinematicsFlow } from "./sagas/video/fetchMpKinematicsFlow";
import {deleteJobFlow} from "./sagas/job/deleteJobFlow";

/**
 * Prevents the root saga from terminating entirely due to some error in another saga
 *
 * @param saga
 */
const makeRestartable = (saga: any) => {
    return function* () {
        yield spawn(function* () {
            while (true) {
                try {
                    yield call(saga);

                    /* eslint-disable-next-line no-console */
                    console.error(
                        'Unexpected root saga termination. The root sagas should live during the whole app lifetime!',
                        saga,
                    );
                } catch (e) {
                    /* eslint-disable-next-line no-console */
                    console.error('Saga error, the saga will be restarted', e);
                }
                yield delay(1000); // Workaround to avoid infinite error loops
            }
        });
    };
};

const sagas: any[] = [
    fetchVideoListFlow,
    maskVideoFlow,
    fetchResultListFlow,
    fetchDownloadableResultFilesFlow,
    fetchBlendshapesFlow,
    fetchMpKinematicsFlow,

    uploadFilesFlow,
    uploadProgressWatcherFlow,

    fetchJobListFlow,
    deleteJobFlow,

    fetchWorkerListFlow,

    fetchPresetListFlow,
    deletePresetFlow,
    createNewPresetFlow,

    enqueueNotificationFlow,
].map(makeRestartable);

export default function* rootSaga() {
    /* eslint-disable-next-line no-console */
    console.log('Root saga started');

    yield all(sagas.map((saga: any) => call(saga)));
};
