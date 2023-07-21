import {Menu, MenuItem} from "@mui/material";

interface DownloadMenuProps {
    anchorEl: HTMLElement|null;
    onClose: () => void;
}

const VideoResultMenu = (props: DownloadMenuProps) => {
    const open = Boolean(props.anchorEl);

    return (
        <Menu
            anchorEl={props.anchorEl}
            open={open}
            onClose={props.onClose}
        >
            <MenuItem onClick={() => props.onClose()}>Rename result</MenuItem>
        </Menu>
    );
};

export default VideoResultMenu;
