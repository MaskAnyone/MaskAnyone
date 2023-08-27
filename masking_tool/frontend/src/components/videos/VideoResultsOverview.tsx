import { Box, Typography } from "@mui/material";
import { useDispatch, useSelector } from "react-redux";
import Selector from "../../state/selector";
import { useNavigate } from "react-router";
import Paths from "../../paths";
import VideoResultCard from "./videoResultsOverview/VideoResultCard";
import React, { useState } from "react";
import VideoResultMenu from "./videoResultsOverview/VideoResultMenu";
import CreatePresetDialog from "../presets/CreatePresetDialog";
import Command from "../../state/actions/command";

interface VideoResultsProps {
    videoId: string;
    resultVideoId?: string;
}

const VideoResultsOverview = (props: VideoResultsProps) => {
    const navigate = useNavigate();
    const dispatch = useDispatch();
    const resultVideoLists = useSelector(Selector.Video.resultVideoLists);
    const jobList = useSelector(Selector.Job.jobList);
    const [videoResultAnchorEl, setVideoResultAnchorEl] = useState<null | HTMLElement>(null);
    const [createPresetDialogOpen, setCreatePresetDialogOpen] = useState<boolean>(false);
    const [activeResultVideoId, setActiveResultVideoId] = useState<string>();

    const resultVideos = resultVideoLists[props.videoId] || [];

    const selectResultVideo = (resultVideoId: string) => {
        navigate(Paths.makeResultVideoDetailsUrl(props.videoId, resultVideoId));
    };

    const openVideoResultMenu = (anchorEl: HTMLElement, resultVideoId: string) => {
        setVideoResultAnchorEl(anchorEl);
        setActiveResultVideoId(resultVideoId);
    };

    const openCreatePresetDialog = () => {
        setVideoResultAnchorEl(null);
        setCreatePresetDialogOpen(true);
    };

    const createPreset = (name: string, description: string) => {
        const activeResultVideo = resultVideos.find(resultVideo => resultVideo.videoResultId === activeResultVideoId);
        if (!activeResultVideo) {
            return;
        }

        const job = jobList.find(job => job.id === activeResultVideo.jobId);
        if (!job) {
            return;
        }

        dispatch(Command.Preset.createNewPreset({
            newPreset: {
                name,
                description,
                data: job.data,
            },
        }));

        setCreatePresetDialogOpen(false);
        setActiveResultVideoId(undefined);
    };

    return (
        <Box component="div">
            <Box component={'div'}>
                <Typography variant={"h6"} style={{ marginRight: "10px" }}>Processed Results</Typography>
            </Box>
            <Box component={'div'} sx={{ overflowX: 'auto', whiteSpace: 'nowrap', padding: 1.5, margin: '-4px -12px' }}>
                {resultVideos.map(resultVideo => (
                    <VideoResultCard
                        key={resultVideo.videoResultId}
                        resultVideo={resultVideo}
                        selected={props.resultVideoId === resultVideo.videoResultId}
                        onSelect={() => selectResultVideo(resultVideo.videoResultId)}
                        onOpenMenu={openVideoResultMenu}
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
                onCreatePreset={createPreset}
            />
        </Box>
    )

}

export default VideoResultsOverview
