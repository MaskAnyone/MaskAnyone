import UploadCommand from "./uploadCommand";
import VideoCommand from "./videoCommand";
import JobCommand from "./jobCommand";

const Command = {
    Video: VideoCommand,
    Upload: UploadCommand,
    Job: JobCommand,
}

export default Command;
