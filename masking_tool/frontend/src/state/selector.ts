import VideoSelector from "./selectors/videoSelector";
import UploadSelector from "./selectors/uploadSelector";
import NotificationSelector from "./selectors/notificationSelector";
import JobSelector from "./selectors/jobSelector";

export const Selector = {
    Video: VideoSelector,
    Upload: UploadSelector,
    Notification: NotificationSelector,
    Job: JobSelector,
}

export default Selector;
