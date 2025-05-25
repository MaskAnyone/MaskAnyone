import { Box, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, IconButton } from "@mui/material";
import VideoRunParamsDialog from "./VideoRunParamsDialog";
import React, { useState } from "react";
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import DeleteIcon from '@mui/icons-material/Delete';
import DownloadMenu from "./videoTaskBar/DownloadMenu";
import ShieldLogoIcon from "../common/ShieldLogoIcon";
import Paths from "../../paths";
import {useNavigate} from "react-router";
import Selector from "../../state/selector";
import { useDispatch, useSelector } from "react-redux";
import { ReduxState } from "../../state/reducer";
import Api from "../../api";
import Command from "../../state/actions/command";

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
    const dispatch = useDispatch();
    const [videoRunParamsOpen, setVideoRunParamsOpen] = useState<boolean>(false);
    const [downloadAnchorEl, setDownloadAnchorEl] = useState<null | HTMLElement>(null);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState<boolean>(false);

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

    const handleDelete = () => {
        dispatch(Command.Video.deleteVideo({ videoId: props.videoId }));
        setDeleteDialogOpen(false);
        navigate(Paths.videos);
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
                <IconButton onClick={() => setDeleteDialogOpen(true)}><DeleteIcon /></IconButton>
            </Box>
        </Box>
        <VideoRunParamsDialog
            videoId={props.videoId}
            open={videoRunParamsOpen}
            onClose={() => setVideoRunParamsOpen(false)}
        />
        <Dialog
            open={deleteDialogOpen}
            onClose={() => setDeleteDialogOpen(false)}
        >
            <DialogTitle>Delete Video</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    Are you sure you want to delete this video? This action cannot be undone.
                </DialogContentText>
            </DialogContent>
            <DialogActions>
                <Button onClick={() => setDeleteDialogOpen(false)} color="primary">
                    Cancel
                </Button>
                <Button onClick={handleDelete} color="error">
                    Delete
                </Button>
            </DialogActions>
        </Dialog>
    </>);
};

export default VideoTaskBar;
