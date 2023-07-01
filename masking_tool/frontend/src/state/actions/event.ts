import VideoEvent from "./videoEvent";
import UploadEvent from "./uploadEvent";
import JobEvent from "./jobEvent";
import NotificationEvent from "./notificationEvent";

const Event = {
    Video: VideoEvent,
    Upload: UploadEvent,
    Job: JobEvent,
    Notification: NotificationEvent,
}

export default Event;
