import {Menu, MenuItem} from "@mui/material";

interface DownloadMenuProps {
    videoId: string;
    resultVideoId?: string;
    anchorEl: HTMLElement|null;
    onClose: () => void;
}

const DownloadMenu = (props: DownloadMenuProps) => {
    const open = Boolean(props.anchorEl);

    const downloadOriginalVideo = () => {
        window.open(`/api/videos/${props.videoId}/download`, '_blank');
        props.onClose();
    };

    const downloadResultVideo = () => {
        window.open(`/api/videos/${props.videoId}/results/${props.resultVideoId}/download`, '_blank');
        props.onClose();
    };

    return (
        <Menu
            anchorEl={props.anchorEl}
            open={open}
            onClose={props.onClose}
        >
            <MenuItem onClick={downloadOriginalVideo}>Original Video</MenuItem>
            {props.resultVideoId && <MenuItem onClick={downloadResultVideo}>Result Video</MenuItem>}
        </Menu>
    );
};

export default DownloadMenu;
