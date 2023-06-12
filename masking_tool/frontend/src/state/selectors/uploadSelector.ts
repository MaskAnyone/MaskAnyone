import {ReduxState} from "../reducer";

const uploadProgress = (state: ReduxState): Record<string, number> => state.upload.uploadProgress;

const UploadSelector = {
    uploadProgress,
};

export default UploadSelector;
