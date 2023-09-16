import { Box } from "@mui/material";
import { useLocation } from "react-router";
import MaskingForm from "../components/videos/maskingForm/MaskingForm";

const VideosMaskingPage = () => {
    const { state } = useLocation();
    const { selectedVideos } = state;

    return (
        <Box component="div">
            {selectedVideos.length != 0 && <MaskingForm videoIds={selectedVideos} onClose={() => {}} />}
        </Box>
    )
}

export default VideosMaskingPage
