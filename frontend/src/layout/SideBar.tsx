import {Box, Button, Checkbox, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, Drawer, IconButton, List, Tooltip, useTheme} from "@mui/material";
import { useDispatch, useSelector } from "react-redux";
import Selector from "../state/selector";
import UploadIcon from '@mui/icons-material/Upload';
import UploadDialog from "../components/upload/UploadDialog";
import Event from "../state/actions/event";
import SideBarVideoItem from "./SideBarVideoItem";
import { useState } from "react";
import { useNavigate, useParams } from "react-router";
import Paths from "../paths";
import ClearIcon from '@mui/icons-material/Clear';
import DeleteIcon from '@mui/icons-material/Delete';
import ShieldIcon from '@mui/icons-material/Shield';
import Command from "../state/actions/command";
import Api from "../api";

const styles = {
    drawer: (theme: any) => ({
        zIndex: 1100,  // Lower than AppBar (1300) so TopBar stays visible
        '& .MuiDrawer-paper': {
            width: 280,
            [theme.breakpoints.up('lg')]: {
                paddingTop: '64px',
            },
            boxSizing: 'border-box',
        },
    }),
    container: {
        padding: 1.5,
        boxSizing: 'border-box',
        flex: 1,
        display: 'flex',
        flexDirection: 'column',
    },
};

interface SideBarProps {
    open: boolean;
    isLargeScreen: boolean;
    onClose: () => void;
}

const SideBar = (props: SideBarProps) => {
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const { videoId: activeVideoId } = useParams<{ videoId: string }>();
    const videoList = useSelector(Selector.Video.videoList);
    const uploadDialogOpen = useSelector(Selector.Upload.dialogOpen);
    const videoJobsRecord = useSelector(Selector.Job.videoActiveJobCountRecord);
    const [selectedVideos, setSelectedVideos] = useState<string[]>([])
    const [anyChecked, setAnyChecked] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const theme = useTheme();

    const openUploadDialog = () => {
        dispatch(Event.Upload.uploadDialogOpened({}));
    };

    const closeUploadDialog = () => {
        dispatch(Event.Upload.uploadDialogClosed({}));
    };

    const selectOrUnselectVideo = (videoId: string) => {
        console.log(videoId, selectedVideos)
        if (selectedVideos.includes(videoId)) {
            const filteredVideos = selectedVideos.filter((val) => val !== videoId)
            setSelectedVideos(filteredVideos)
            if (filteredVideos.length === 0) {
                setAnyChecked(false)
            }
        } else {
            setSelectedVideos([...selectedVideos, videoId])
        }
    }

    const handleCheckboxClicked = (videoId: string) => {
        setAnyChecked(true)
        selectOrUnselectVideo(videoId)
    }

    const handleSelectAll = () => {
        if (selectedVideos.length === videoList.length) {
            setSelectedVideos([])
        } else {
            setSelectedVideos(videoList.map((video) => video.id))
        }
    }

    const handleSelectCancel = () => {
        setSelectedVideos([])
        setAnyChecked(false)
    }

    const handleRename = async (videoId: string, newName: string) => {
        try {
            await Api.renameVideo(videoId, newName);
            dispatch(Command.Video.fetchVideoList({}));
        } catch {
            // name conflict or other error — video list stays unchanged
        }
    };

    const handleMaskSelected = () => {
        navigate(Paths.videoRunMasking, { state: { selectedVideos } });
    };

    const handleBulkDelete = () => {
        setDeleteDialogOpen(true);
    }

    const confirmBulkDelete = () => {
        selectedVideos.forEach(videoId => {
            dispatch(Command.Video.deleteVideo({ videoId }));
        });
        setSelectedVideos([]);
        setAnyChecked(false);
        setDeleteDialogOpen(false);
        navigate(Paths.videos);
    }

    return (
        <Drawer
            sx={styles.drawer}
            open={props.open || props.isLargeScreen}
            onClose={props.onClose}
            variant={props.isLargeScreen ? 'persistent' : 'temporary'}
            children={(
                <Box component="div" sx={styles.container}>
                    <Box component="div" style={{ display: anyChecked ? "flex" : "none", alignItems: 'center', justifyContent: 'space-between', borderBottom: `1px solid ${theme.palette.divider}` }}>
                        <Tooltip title="Cancel selection">
                            <IconButton onClick={handleSelectCancel} aria-label="Cancel selection">
                                <ClearIcon />
                            </IconButton>
                        </Tooltip>
                        <Tooltip title="Mask selected">
                            <span>
                                <IconButton onClick={handleMaskSelected} color="primary" disabled={selectedVideos.length === 0} aria-label="Mask selected videos">
                                    <ShieldIcon />
                                </IconButton>
                            </span>
                        </Tooltip>
                        <Tooltip title="Delete selected">
                            <span>
                                <IconButton onClick={handleBulkDelete} color="error" disabled={selectedVideos.length === 0} aria-label="Delete selected videos">
                                    <DeleteIcon />
                                </IconButton>
                            </span>
                        </Tooltip>
                        <Tooltip title="Select all">
                            <Checkbox
                                checked={selectedVideos.length === videoList.length}
                                onClick={handleSelectAll}
                                inputProps={{ 'aria-label': 'Select all videos' } as any}
                            />
                        </Tooltip>
                    </Box>
                    <List sx={{ display: 'flex', flexDirection: 'column', flex: 1, paddingBottom: 1 }} disablePadding={true}>
                        {videoList.map(video => (
                            <SideBarVideoItem
                                key={video.id}
                                video={video}
                                badge={videoJobsRecord[video.id] || 0}
                                onCheckboxClicked={handleCheckboxClicked}
                                onRename={handleRename}
                                checked={selectedVideos.includes(video.id)}
                                active={video.id === activeVideoId}
                                anyChecked={anyChecked}
                            />
                        ))}
                    </List>
                    <Button variant={'contained'} color={'primary'} size={'large'} onClick={openUploadDialog} startIcon={<UploadIcon />}>
                        Upload
                    </Button>
                    <UploadDialog open={uploadDialogOpen} onClose={closeUploadDialog} />
                    <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
                        <DialogTitle>Delete Videos</DialogTitle>
                        <DialogContent>
                            <DialogContentText>
                                Delete {selectedVideos.length} selected video{selectedVideos.length !== 1 ? 's' : ''}? This cannot be undone.
                            </DialogContentText>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={() => setDeleteDialogOpen(false)} color="primary">Cancel</Button>
                            <Button onClick={confirmBulkDelete} color="error">Delete</Button>
                        </DialogActions>
                    </Dialog>
                </Box >
            )}
        />
    );
};

export default SideBar;
