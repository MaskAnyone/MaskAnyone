import {Box, Typography} from "@mui/material";
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import PresetPreview from "../components/presets/PresetPreview";
import React, {useEffect, useState} from "react";
import Command from "../state/actions/command";
import DeletePresetConfirmationDialog from "../components/presets/DeletePresetConfirmationDialog";
import PresetPreviewMenu from "../components/presets/PresetPreviewMenu";
import PresetDetailsDialog from "../components/presets/PresetDetailsDialog";
import Assets from "../assets/assets";

const PresetsPage = () => {
    const dispatch = useDispatch();
    const presetList = useSelector(Selector.Preset.presetList);
    const [presetPreviewAnchorEl, setPresetPreviewAnchorEl] = useState<null|HTMLElement>(null);
    const [activePresetId, setActivePresetId] = useState<string>();
    const [deletePresetDialogOpen, setDeletePresetDialogOpen] = useState<boolean>(false);
    const [presetDetailsDialogOpen, setPresetDetailsDialogOpen] = useState<boolean>(false);


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

    const openPresetDetailsDialog = () => {
        setPresetDetailsDialogOpen(true);
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
            <Typography variant={'h4'}>
                My Custom Presets
            </Typography>

            {presetList.length < 1 ? (
                <Box component={'div'} sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                    <img src={Assets.illustrations.empty} alt={'Empty'} width={300} style={{ marginTop: 24 }} />
                    <Typography variant={'body1'}>
                        You do not have any presets yet. Please navigate to a result you like and create a preset from it!
                    </Typography>
                </Box>
            ) : (
                <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', marginTop: 2, gap: '24px' }}>
                    {presetList.map(preset => (
                        <PresetPreview
                            key={preset.id}
                            preset={preset}
                            onOpenMenu={anchorEl => openPresetPreviewMenu(anchorEl, preset.id)}
                        />
                    ))}
                </Box>
            )}

            <PresetPreviewMenu
                anchorEl={presetPreviewAnchorEl}
                onClose={() => setPresetPreviewAnchorEl(null)}
                onDelete={openDeleteDialog}
                onShowDetails={openPresetDetailsDialog}
            />
            <DeletePresetConfirmationDialog
                open={deletePresetDialogOpen}
                onClose={() => setDeletePresetDialogOpen(false)}
                onDelete={deletePreset}
            />
            <PresetDetailsDialog
                open={presetDetailsDialogOpen}
                onClose={() => setPresetDetailsDialogOpen(false)}
                preset={presetList.find(preset => preset.id === activePresetId)}
            />
        </Box>
    );
};

export default PresetsPage;
