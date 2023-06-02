import {Box, Drawer} from "@mui/material";
import SideBarItem from "./SideBarItem";
import VideocamIcon from '@mui/icons-material/Videocam';
import {useSelector} from "react-redux";
import Selector from "../state/selector";

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
        paddingTop: 2.5,
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
                    {videoList.map(video => (
                        <SideBarItem
                            key={video.name}
                            url={`/videos/${encodeURIComponent(video.name)}`}
                            label={`${video.name} (${video.frameWidth}x${video.frameHeight})`}
                            icon={<VideocamIcon />}
                        />
                    ))}
                </Box>
            )}
        />
    );
};

export default SideBar;
