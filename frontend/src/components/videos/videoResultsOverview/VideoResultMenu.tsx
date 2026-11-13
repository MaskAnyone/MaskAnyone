import { Menu, MenuItem } from "@mui/material";

interface DownloadMenuProps {
    anchorEl: HTMLElement | null;
    onClose: () => void;
    onShowRunParams: () => void;
    onRename: () => void;
    onDelete: () => void;
}

const VideoResultMenu = (props: DownloadMenuProps) => {
    const open = Boolean(props.anchorEl);

    return (
        <Menu
            anchorEl={props.anchorEl}
            open={open}
            onClose={props.onClose}
        >
            <MenuItem onClick={props.onShowRunParams}>Show masking config</MenuItem>
            <MenuItem onClick={props.onRename}>Rename result</MenuItem>
            <MenuItem onClick={props.onDelete}>Delete result</MenuItem>
            {/*<MenuItem onClick={props.onCreatePreset}>Create preset</MenuItem>*/}
        </Menu>
    );
};

export default VideoResultMenu;
