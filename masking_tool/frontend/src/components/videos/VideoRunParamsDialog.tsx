import {Box, Dialog, DialogTitle, Divider, IconButton} from "@mui/material";
import MaskingForm from "./maskingForm/MaskingForm";
import CloseIcon from '@mui/icons-material/Close';

const styles = {
    dialog: {
        "& .MuiDialog-container": {
            "& .MuiPaper-root": {
                width: "100%",
                maxWidth: "1416px",
            },
        },
    },
}

interface VideoRunParamsDialogProps {
    videoId: string;
    open: boolean;
    onClose: () => void;
}

const VideoRunParamsDialog = (props: VideoRunParamsDialogProps) => {
    return (
        <Dialog open={props.open} onClose={props.onClose} fullWidth={true} sx={styles.dialog}>
            <DialogTitle>
                <Box component={'div'} display="flex" alignItems="center">
                    <Box component={'div'} flexGrow={1}>Mask Video</Box>
                    <Box component={'div'}>
                        <IconButton onClick={props.onClose} sx={{ margin: -0.75 }}>
                            <CloseIcon />
                        </IconButton>
                    </Box>
                </Box>
            </DialogTitle>
            <Divider />
            <MaskingForm videoIds={[props.videoId]} onClose={props.onClose} />
        </Dialog>
    );
};

export default VideoRunParamsDialog;
