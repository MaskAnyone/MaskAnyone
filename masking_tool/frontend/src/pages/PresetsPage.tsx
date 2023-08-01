import {Box, Typography} from "@mui/material";
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import PresetPreview from "../components/presets/PresetPreview";
import React, {useEffect, useState} from "react";
import Command from "../state/actions/command";
import DeletePresetConfirmationDialog from "../components/presets/DeletePresetConfirmationDialog";
import PresetPreviewMenu from "../components/presets/PresetPreviewMenu";

const PresetsPage = () => {
    const dispatch = useDispatch();
    const presetList = useSelector(Selector.Preset.presetList);
    const [presetPreviewAnchorEl, setPresetPreviewAnchorEl] = useState<null|HTMLElement>(null);
    const [activePresetId, setActivePresetId] = useState<string>();
    const [deletePresetDialogOpen, setDeletePresetDialogOpen] = useState<boolean>(false);

    useEffect(() => {
        dispatch(Command.Preset.fetchPresetList({}));
    }, []);

    const openPresetPreviewMenu = (anchorEl: HTMLElement, presetId: string) => {
        setPresetPreviewAnchorEl(anchorEl);
        setActivePresetId(presetId);
    };

    const openDeleteDialog = () => {
        setDeletePresetDialogOpen(true);
        setPresetPreviewAnchorEl(null);
    };

    const deletePreset = () => {
        setDeletePresetDialogOpen(false);

        if (!activePresetId) {
            return;
        }

        dispatch(Command.Preset.deletePreset({ id: activePresetId }));
        setActivePresetId(undefined);
    };

    return (
        <Box component={'div'}>
            <Typography variant={'h3'}>
                My Custom Presets
            </Typography>

            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', marginTop: 2 }}>
                {presetList.map(preset => (
                    <Box component={'div'} sx={{ paddingRight: 2, paddingBottom: 2 }}>
                        <PresetPreview
                            key={preset.id}
                            preset={preset}
                            onOpenMenu={anchorEl => openPresetPreviewMenu(anchorEl, preset.id)}
                        />
                    </Box>
                ))}
            </Box>

            <PresetPreviewMenu
                anchorEl={presetPreviewAnchorEl}
                onClose={() => setPresetPreviewAnchorEl(null)}
                onDelete={openDeleteDialog}
            />
            <DeletePresetConfirmationDialog
                open={deletePresetDialogOpen}
                onClose={() => setDeletePresetDialogOpen(false)}
                onDelete={deletePreset}
            />
        </Box>
    );
};

export default PresetsPage;
