import { all, call, delay, spawn } from 'redux-saga/effects';
import {uploadFilesFlow, uploadProgressWatcherFlow} from "./sagas/upload/uploadFilesFlow";
import {fetchVideoListFlow} from "./sagas/video/fetchVideoListFlow";
import {maskVideoFlow} from "./sagas/video/maskVideoFlow";

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

    uploadFilesFlow,
    uploadProgressWatcherFlow,
].map(makeRestartable);

export default function* rootSaga() {
    /* eslint-disable-next-line no-console */
    console.log('Root saga started');

    yield all(sagas.map((saga: any) => call(saga)));
};
