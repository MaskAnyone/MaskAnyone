import { Box } from "@mui/material";
import { useLocation } from "react-router";
import VideoRunParams from "../components/videos/VideoRunParams";

const VideosMaskingPage = () => {
    const { state } = useLocation();
    const { selectedVideos } = state;

    return (
        <Box component="div">
            {selectedVideos.length != 0 && <VideoRunParams videoIds={selectedVideos} />}
        </Box>
    )
}

export default VideosMaskingPage