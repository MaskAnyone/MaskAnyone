import {Box, Drawer, Fab, List} from "@mui/material";
import SideBarItem from "./SideBarItem";
import VideocamIcon from '@mui/icons-material/Videocam';
import {useSelector} from "react-redux";
import Selector from "../state/selector";
import UploadIcon from '@mui/icons-material/Upload';

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
    const videoList = useSelector(Selector.Video.videoList);

    return (
        <Drawer
            sx={styles.drawer}
            open={props.open || props.isLargeScreen}
            onClose={props.onClose}
            variant={props.isLargeScreen ? 'persistent' : 'temporary'}
            children={(
                <Box sx={styles.container}>
                    <List sx={{ display: 'flex', flexDirection: 'column', flex: 1, paddingBottom: 1 }} disablePadding={true}>
                        {videoList.map(video => (
                            <SideBarItem
                                key={video.name}
                                url={`/videos/${encodeURIComponent(video.name)}`}
                                title={`${video.name} (${Math.round(video.duration)}s)`}
                                subtitle={`${video.frameWidth}x${video.frameHeight}, ${video.fps} FPS`}
                                icon={<VideocamIcon />}
                            />
                        ))}
                    </List>
                    <Fab variant={'extended'} color={'primary'}>
                        <UploadIcon sx={{ mr: 1 }} />
                        Upload
                    </Fab>
                </Box>
            )}
        />
    );
};

export default SideBar;
