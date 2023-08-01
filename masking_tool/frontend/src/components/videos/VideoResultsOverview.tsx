import {Box, Paper, Typography, styled} from "@mui/material";
import { useSelector } from "react-redux";
import Selector from "../../state/selector";
import { useNavigate } from "react-router";
import Paths from "../../paths";
import VideoResultCard from "./videoResultsOverview/VideoResultCard";
import React, {useState} from "react";
import VideoResultMenu from "./videoResultsOverview/VideoResultMenu";
import CreatePresetDialog from "../presets/CreatePresetDialog";

interface VideoResultsProps {
    videoId: string;
    resultVideoId?: string;
}

const Item = styled(Paper)(() => ({
    backgroundColor: '#bdc3c7',
    padding: 8,
    textAlign: 'center',
    color: 'black',
    cursor: "pointer",
    '&:hover': {
        background: "#3498db",
    }
}));

const VideoResultsOverview = (props: VideoResultsProps) => {
    const navigate = useNavigate();
    const resultVideoLists = useSelector(Selector.Video.resultVideoLists);
    const [videoResultAnchorEl, setVideoResultAnchorEl] = useState<null|HTMLElement>(null);
    const [createPresetDialogOpen, setCreatePresetDialogOpen] = useState<boolean>(false);

    const resultVideos = resultVideoLists[props.videoId] || [];

    const selectResultVideo = (resultVideoId: string) => {
        navigate(Paths.makeResultVideoDetailsUrl(props.videoId, resultVideoId));
    };

    const openCreatePresetDialog = () => {
        setVideoResultAnchorEl(null);
        setCreatePresetDialogOpen(true);
    };

    return (
        <Box component="div">
            <Box component={'div'}>
                <Typography variant={"h6"} style={{ marginRight: "10px" }}>Processed Results</Typography>
            </Box>
            <Box component={'div'} sx={{ overflowX: 'auto', whiteSpace: 'nowrap', padding: 1.5, margin: '-4px -12px' }}>
                {resultVideos.map(resultVideo => (
                    <VideoResultCard
                        resultVideo={resultVideo}
                        selected={props.resultVideoId === resultVideo.id}
                        onSelect={() => selectResultVideo(resultVideo.id)}
                        onOpenMenu={setVideoResultAnchorEl}
                    />
                ))}
            </Box>

            <VideoResultMenu
                anchorEl={videoResultAnchorEl}
                onClose={() => setVideoResultAnchorEl(null)}
                onCreatePreset={openCreatePresetDialog}
            />
            <CreatePresetDialog
                open={createPresetDialogOpen}
                onClose={() => setCreatePresetDialogOpen(false)}
            />
        </Box>
    )

}

export default VideoResultsOverview
