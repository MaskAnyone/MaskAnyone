import UploadCommand from "./uploadCommand";
import VideoCommand from "./videoCommand";
import JobCommand from "./jobCommand";
import NotificationCommand from "./notificationCommand";
import WorkerCommand from "./workerCommand";
import PresetCommand from "./presetCommand";

const Command = {
    Video: VideoCommand,
    Upload: UploadCommand,
    Job: JobCommand,
    Notification: NotificationCommand,
    Worker: WorkerCommand,
    Preset: PresetCommand,
}

export default Command;
