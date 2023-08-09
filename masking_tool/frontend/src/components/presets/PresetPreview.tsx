import {IconButton} from "@mui/material";
import {Preset} from "../../state/types/Preset";
import MoreVertIcon from "@mui/icons-material/MoreVert";
import React from "react";
import SideBySideCard from "../common/SideBySideCard";
import SideBySideCardContent from "../common/SideBySideCardContent";

interface PresetPreviewProps {
    preset: Preset;
    onOpenMenu: (element: HTMLElement) => void;
}

const PresetPreview = (props: PresetPreviewProps) => {
    const openPresetPreviewMenu = (event: React.MouseEvent<HTMLButtonElement>) => {
        event.preventDefault();
        event.stopPropagation();
        props.onOpenMenu(event.currentTarget);
    };

    return (
        <SideBySideCard>
            <SideBySideCardContent
                title={props.preset.name}
                description={props.preset.description}
            />
            <IconButton sx={{ position: 'absolute', top: 4, right: 0 }} onClick={openPresetPreviewMenu}>
                <MoreVertIcon sx={{ color: 'white', mixBlendMode: 'difference'}} />
            </IconButton>
        </SideBySideCard>
    );
};

export default PresetPreview;
