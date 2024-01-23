import VideoEvent from "./videoEvent";
import UploadEvent from "./uploadEvent";
import JobEvent from "./jobEvent";
import NotificationEvent from "./notificationEvent";
import WorkerEvent from "./workerEvent";
import PresetEvent from "./presetEvent";
import AuthEvent from "./authEvent";

const Event = {
    Video: VideoEvent,
    Upload: UploadEvent,
    Job: JobEvent,
    Notification: NotificationEvent,
    Worker: WorkerEvent,
    Preset: PresetEvent,
    Auth: AuthEvent,
}

export default Event;
