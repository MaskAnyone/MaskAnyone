import { Box, Checkbox, Divider, Drawer, Fab, IconButton, List } from "@mui/material";
import { useDispatch, useSelector } from "react-redux";
import Selector from "../state/selector";
import UploadIcon from '@mui/icons-material/Upload';
import UploadDialog from "../components/upload/UploadDialog";
import Event from "../state/actions/event";
import SideBarVideoItem from "./SideBarVideoItem";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router";
import Paths from "../paths";
import LibraryAddCheckIcon from '@mui/icons-material/LibraryAddCheck';
import ClearIcon from '@mui/icons-material/Clear';

const styles = {
    drawer: (theme: any) => ({
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
    const videoList = useSelector(Selector.Video.videoList);
    const uploadDialogOpen = useSelector(Selector.Upload.dialogOpen);
    const videoJobsRecord = useSelector(Selector.Job.videoActiveJobCountRecord);
    const [selectedVideos, setSelectedVideos] = useState<string[]>([])
    const [anyChecked, setAnyChecked] = useState(false)

    useEffect(() => {
        if (anyChecked) {
            navigate(Paths.videoRunMasking, { state: { selectedVideos } })
        }
    }, [anyChecked, selectedVideos])

    const openUploadDialog = () => {
        dispatch(Event.Upload.uploadDialogOpened({}));
    };

    const closeUploadDialog = () => {
        dispatch(Event.Upload.uploadDialogClosed({}));
    };

    const handleItemClicked = (videoId: string) => {
        if (!anyChecked) {
            navigate(Paths.makeVideoDetailsUrl(videoId));
        } else {
            selectOrUnselectVideo(videoId)
        }
    }

    const selectOrUnselectVideo = (videoId: string) => {
        console.log(videoId, selectedVideos)
        if (selectedVideos.includes(videoId)) {
            const filteredVideos = selectedVideos.filter((val) => val != videoId)
            setSelectedVideos(filteredVideos)
            if (filteredVideos.length == 0) {
                setAnyChecked(false)
            }
        } else {
            setSelectedVideos([...selectedVideos, videoId])
        }
    }

    const handleCheckboxClicked = (e: React.MouseEvent<HTMLButtonElement>, videoId: string) => {
        setAnyChecked(true)
        e.stopPropagation()
        selectOrUnselectVideo(videoId)
    }

    const handleSelectAll = () => {
        if (selectedVideos.length == videoList.length) {
            setSelectedVideos([])
        } else {
            setSelectedVideos(videoList.map((video) => video.id))
        }
    }

    const handleSelectCancel = () => {
        setSelectedVideos([])
        setAnyChecked(false)
    }

    return (
        <Drawer
            sx={styles.drawer}
            open={props.open || props.isLargeScreen}
            onClose={props.onClose}
            variant={props.isLargeScreen ? 'persistent' : 'temporary'}
            children={(
                <Box component="div" sx={styles.container}>
                    <Box component="div" style={{ display: anyChecked ? "block" : "none", paddingLeft: "15px", borderBottom: "1px solid #e0e0e0" }}>
                        <IconButton aria-label="Cancel Multiple Selection" style={{ float: "left" }} onClick={() => handleSelectCancel()}>
                            <ClearIcon />
                        </IconButton>
                        <Checkbox
                            style={{ float: "right" }}
                            checked={selectedVideos.length == videoList.length}
                            onClick={() => handleSelectAll()}
                        />
                    </Box>
                    <List sx={{ display: 'flex', flexDirection: 'column', flex: 1, paddingBottom: 1 }} disablePadding={true}>
                        {videoList.map(video => (
                            <SideBarVideoItem
                                video={video}
                                badge={videoJobsRecord[video.id] || 0}
                                onCheckboxClicked={handleCheckboxClicked}
                                onItemClicked={handleItemClicked}
                                checked={selectedVideos.includes(video.id)}
                                active={selectedVideos.length == 1 && selectedVideos[0] == video.id}
                                anyChecked={anyChecked}
                            />
                        ))}
                    </List>
                    <Fab variant={'extended'} color={'primary'} onClick={openUploadDialog}>
                        <UploadIcon sx={{ mr: 1 }} />
                        Upload
                    </Fab>
                    <UploadDialog open={uploadDialogOpen} onClose={closeUploadDialog} />
                </Box >
            )}
        />
    );
};

export default SideBar;
