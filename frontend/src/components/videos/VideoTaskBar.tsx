import { Box, Button } from "@mui/material";
import VideoRunParamsDialog from "./VideoRunParamsDialog";
import React, { useState } from "react";
import ManageAccountsIcon from '@mui/icons-material/ManageAccounts';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import DownloadMenu from "./videoTaskBar/DownloadMenu";
import ShieldLogoIcon from "../common/ShieldLogoIcon";
import Paths from "../../paths";
import {useNavigate} from "react-router";

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

    const openDownloadMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        setDownloadAnchorEl(event.currentTarget);
    };

    const openVideoMaskingEditor = () => {
        navigate(Paths.makeVideoMaskingEditorUrl(props.videoId));
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
