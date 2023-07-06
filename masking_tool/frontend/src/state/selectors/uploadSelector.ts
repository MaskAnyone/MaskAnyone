import {ReduxState} from "../reducer";

const dialogOpen = (state: ReduxState): boolean => state.upload.dialogOpen;
const uploadProgress = (state: ReduxState): Record<string, number> => state.upload.uploadProgress;

const UploadSelector = {
    dialogOpen,
    uploadProgress,
};

export default UploadSelector;
