import {Menu, MenuItem} from "@mui/material";

interface PresetPreviewMenuProps {
    anchorEl: HTMLElement|null;
    onClose: () => void;
    onDelete: () => void;
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
            <MenuItem onClick={props.onDelete}>Delete</MenuItem>
        </Menu>
    );
};

export default PresetPreviewMenu;
