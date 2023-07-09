import VideoRunParams from "./VideoRunParams";
import {Dialog, DialogContent, DialogTitle} from "@mui/material";

interface VideoRunParamsDialogProps {
    videoId: string;
    open: boolean;
    onClose: () => void;
}

const VideoRunParamsDialog = (props: VideoRunParamsDialogProps) => {
    return (
        <Dialog open={props.open} onClose={props.onClose} fullWidth={true} maxWidth={'xl'}>
            <DialogTitle>Mask Video</DialogTitle>
            <DialogContent>
                <VideoRunParams videoId={props.videoId} />
            </DialogContent>
        </Dialog>
    );
};

export default VideoRunParamsDialog;
