
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
            <DialogContent sx={{ minHeight: 550, padding: '20px 32px' }}>
                <MaskingForm videoIds={[props.videoId]} />
            </DialogContent>
        </Dialog>
    );
};

export default VideoRunParamsDialog;
