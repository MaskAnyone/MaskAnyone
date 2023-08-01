import {Menu, MenuItem} from "@mui/material";

interface PresetPreviewMenuProps {
    anchorEl: HTMLElement|null;
    onClose: () => void;
}

const PresetPreviewMenu = (props: PresetPreviewMenuProps) => {
    const open = Boolean(props.anchorEl);

    return (
        <Menu
            anchorEl={props.anchorEl}
            open={open}
            onClose={props.onClose}
        >
            <MenuItem onClick={() => props.onClose()}>View details</MenuItem>
            <MenuItem onClick={() => props.onClose()}>Delete</MenuItem>
        </Menu>
    );
};

export default PresetPreviewMenu;
