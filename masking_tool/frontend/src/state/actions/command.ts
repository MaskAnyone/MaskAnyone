import UploadCommand from "./uploadCommand";
import VideoCommand from "./videoCommand";
import JobCommand from "./jobCommand";
import NotificationCommand from "./notificationCommand";

const Command = {
    Video: VideoCommand,
    Upload: UploadCommand,
    Job: JobCommand,
    Notification: NotificationCommand,
}

export default Command;
