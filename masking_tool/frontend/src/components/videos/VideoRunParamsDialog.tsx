
import {Dialog, DialogContent, DialogTitle, Divider} from "@mui/material";
import MaskingForm from "./maskingForm/MaskingForm";

interface VideoRunParamsDialogProps {
    videoId: string;
    open: boolean;
    onClose: () => void;
}

const VideoRunParamsDialog = (props: VideoRunParamsDialogProps) => {
    return (
        <Dialog open={props.open} onClose={props.onClose} fullWidth={true} maxWidth={'xl'}>
            <DialogTitle>Mask Video</DialogTitle>
            <Divider />
            <MaskingForm videoIds={[props.videoId]} />
        </Dialog>
    );
};

export default VideoRunParamsDialog;
