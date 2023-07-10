import VideoEvent from "./videoEvent";
import UploadEvent from "./uploadEvent";
import JobEvent from "./jobEvent";
import NotificationEvent from "./notificationEvent";
import WorkerEvent from "./workerEvent";

const Event = {
    Video: VideoEvent,
    Upload: UploadEvent,
    Job: JobEvent,
    Notification: NotificationEvent,
    Worker: WorkerEvent,
}

export default Event;
