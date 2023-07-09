import {Box, Drawer, Fab, List} from "@mui/material";
import SideBarItem from "./SideBarItem";
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import UploadIcon from '@mui/icons-material/Upload';
import UploadDialog from "../components/upload/UploadDialog";
import Event from "../state/actions/event";
import SideBarVideoItem from "./SideBarVideoItem";

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
    const videoList = useSelector(Selector.Video.videoList);
    const uploadDialogOpen = useSelector(Selector.Upload.dialogOpen);
    const videoJobsRecord = useSelector(Selector.Job.videoActiveJobCountRecord);

    const openUploadDialog = () => {
        dispatch(Event.Upload.uploadDialogOpened({}));
    };

    const closeUploadDialog = () => {
        dispatch(Event.Upload.uploadDialogClosed({}));
    };

    return (
        <Drawer
            sx={styles.drawer}
            open={props.open || props.isLargeScreen}
            onClose={props.onClose}
            variant={props.isLargeScreen ? 'persistent' : 'temporary'}
            children={(
                <Box component="div" sx={styles.container}>
                    <List sx={{ display: 'flex', flexDirection: 'column', flex: 1, paddingBottom: 1 }} disablePadding={true}>
                        {videoList.map(video => (
                            <SideBarVideoItem video={video} badge={videoJobsRecord[video.id] || 0} />
                        ))}
                    </List>
                    <Fab variant={'extended'} color={'primary'} onClick={openUploadDialog}>
                        <UploadIcon sx={{ mr: 1 }} />
                        Upload
                    </Fab>
                    <UploadDialog open={uploadDialogOpen} onClose={closeUploadDialog} />
                </Box>
            )}
        />
    );
};

export default SideBar;
