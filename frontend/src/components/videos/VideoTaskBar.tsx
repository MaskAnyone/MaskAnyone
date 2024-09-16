import { Box, Button } from "@mui/material";
import VideoRunParamsDialog from "./VideoRunParamsDialog";
import React, { useState } from "react";
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import DownloadMenu from "./videoTaskBar/DownloadMenu";
import ShieldLogoIcon from "../common/ShieldLogoIcon";
import Paths from "../../paths";
import {useNavigate} from "react-router";
import Selector from "../../state/selector";
import { useSelector } from "react-redux";
import { ReduxState } from "../../state/reducer";

const styles = {
    container: {
        marginBottom: 2,
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'space-between',
    },
};

interface VideoTaskBarProps {
    videoId: string;
    resultVideoId?: string;
}

const VideoTaskBar = (props: VideoTaskBarProps) => {
    const navigate = useNavigate();
    const [videoRunParamsOpen, setVideoRunParamsOpen] = useState<boolean>(false);
    const [downloadAnchorEl, setDownloadAnchorEl] = useState<null | HTMLElement>(null);

    const resultVideoLists = useSelector(Selector.Video.resultVideoLists);
    const resultVideos = resultVideoLists[props.videoId] || [];
    const activeResultVideo = resultVideos.find(resultVideo => resultVideo.videoResultId === props.resultVideoId);

    const selectJobById = Selector.Job.makeSelectJobById();
    const resultVideoJob = useSelector((state: ReduxState) => selectJobById(state, activeResultVideo?.jobId || ''));

    const openDownloadMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        setDownloadAnchorEl(event.currentTarget);
    };

    const openVideoMaskingEditor = () => {
        navigate(Paths.makeVideoMaskingEditorUrl(props.videoId));
    };

    const openResultVideoMaskingEditor = () => {
        if (!props.resultVideoId) {
            return;
        }

        navigate(Paths.makeResultVideoMaskingEditorUrl(props.videoId, props.resultVideoId));
    };

    return (<>
        <Box component={'div'} sx={styles.container}>
            <Box component={'div'}>
                <Button
                    variant={'contained'}
                    onClick={() => setVideoRunParamsOpen(true)}
                    children={'Mask Video'}
                    color={'secondary'}
                    startIcon={<ShieldLogoIcon />}
                />
                <Button
                    variant={'contained'}
                    onClick={openVideoMaskingEditor}
                    children={'New Masking Process'}
                    sx={{ marginLeft: 1 }}
                    color={'secondary'}
                    startIcon={<ShieldLogoIcon />}
                />
                {Boolean(props.resultVideoId && resultVideoJob) && (
                    <Button
                        variant={'contained'}
                        onClick={openResultVideoMaskingEditor}
                        children={'Refine Result'}
                        sx={{ marginLeft: 1 }}
                        color={'primary'}
                        startIcon={<ShieldLogoIcon />}
                    />
                )}
            </Box>
            <Box component={'div'}>
                <Button
                    variant={'text'}
                    onClick={openDownloadMenu}
                    children={'Download'}
                    color={'secondary'}
                    startIcon={<FileDownloadIcon />}
                />
                <DownloadMenu
                    videoId={props.videoId}
                    resultVideoId={props.resultVideoId}
                    anchorEl={downloadAnchorEl}
                    onClose={() => setDownloadAnchorEl(null)}
                />
            </Box>
        </Box>
        <VideoRunParamsDialog
            videoId={props.videoId}
            open={videoRunParamsOpen}
            onClose={() => setVideoRunParamsOpen(false)}
        />
    </>);
};

export default VideoTaskBar;
