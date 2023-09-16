import VideoSelector from "./selectors/videoSelector";
import UploadSelector from "./selectors/uploadSelector";
import NotificationSelector from "./selectors/notificationSelector";
import JobSelector from "./selectors/jobSelector";
import WorkerSelector from "./selectors/workerSelector";
import PresetSelector from "./selectors/presetSelector";

export const Selector = {
    Video: VideoSelector,
    Upload: UploadSelector,
    Notification: NotificationSelector,
    Job: JobSelector,
    Worker: WorkerSelector,
    Preset: PresetSelector,
}

export default Selector;
