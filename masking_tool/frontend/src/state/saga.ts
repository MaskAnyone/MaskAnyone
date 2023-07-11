import { all, call, delay, spawn } from 'redux-saga/effects';
import {uploadFilesFlow, uploadProgressWatcherFlow} from "./sagas/upload/uploadFilesFlow";
import {fetchVideoListFlow} from "./sagas/video/fetchVideoListFlow";
import {maskVideoFlow} from "./sagas/video/maskVideoFlow";
import {fetchJobListFlow} from "./sagas/job/fetchJobListFlow";
import {enqueueNotificationFlow} from "./sagas/notification/enqueueNotificationFlow";
import {fetchResultVideoListFlow} from "./sagas/video/fetchResultVideoListFlow";
import {fetchDownloadableResultFilesFlow} from "./sagas/video/fetchDownloadableResultFilesFlow";
import {fetchWorkerListFlow} from "./sagas/worker/fetchWorkerListFlow";

/**
 * Prevents the root saga from terminating entirely due to some error in another saga
 *
 * @param saga
 */
const makeRestartable = (saga: any) => {
    return function*() {
        yield spawn(function*() {
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
    fetchResultVideoListFlow,
    fetchDownloadableResultFilesFlow,

    uploadFilesFlow,
    uploadProgressWatcherFlow,

    fetchJobListFlow,

    fetchWorkerListFlow,

    enqueueNotificationFlow,
].map(makeRestartable);

export default function* rootSaga() {
    /* eslint-disable-next-line no-console */
    console.log('Root saga started');

    yield all(sagas.map((saga: any) => call(saga)));
};
