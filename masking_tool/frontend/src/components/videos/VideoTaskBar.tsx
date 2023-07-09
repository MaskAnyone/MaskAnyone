import {Box, Button} from "@mui/material";
import VideoRunParamsDialog from "./VideoRunParamsDialog";
import React, {useState} from "react";
import ManageAccountsIcon from '@mui/icons-material/ManageAccounts';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import DownloadMenu from "./videoTaskBar/DownloadMenu";

const styles = {
    container: {
        marginBottom: 4,
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
    const [videoRunParamsOpen, setVideoRunParamsOpen] = useState<boolean>(false);
    const [downloadAnchorEl, setDownloadAnchorEl] = useState<null|HTMLElement>(null);

    const openDownloadMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        setDownloadAnchorEl(event.currentTarget);
    };

    return (<>
        <Box component={'div'} sx={styles.container}>
            <Box component={'div'}>
                <Button
                    variant={'contained'}
                    onClick={() => setVideoRunParamsOpen(true)}
                    children={'Mask Video'}
                    color={'secondary'}
                    startIcon={<ManageAccountsIcon />}
                />
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
