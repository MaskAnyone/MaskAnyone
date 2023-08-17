import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../../../state/types/Run";
import { presetsDB } from "../../../../util/presets"
import SelectableCard from "../../../common/SelectableCard";
import {useSelector} from "react-redux";
import Selector from "../../../../state/selector";

const styles = {
    presetList: {
        overflowX: 'auto',
        whiteSpace: 'nowrap',
        padding: '12px 6px',
        margin: '0 -6px',
    },
};

interface PresetSelectionProps {
    onPresetSelected: (preset: Preset) => void
    selectedPreset?: Preset
}

const PresetSelection = (props: PresetSelectionProps) => {
    const customPresets = useSelector(Selector.Preset.presetList);

    const [presets, setPresets] = useState(presetsDB)
    const { selectedPreset } = props

    const onPresetClicked = (preset: Preset) => {
        props.onPresetSelected(preset)
    }

    return (
        <Box component={'div'}>
            <Box component={'div'} sx={{ marginBottom: 2 }}>
                <Typography variant="h6">
                    Predefined Presets
                </Typography >
                <Typography variant={'body2'}>
                    Please choose one of our predefined presets or click "Use Custom Settings" to configure your own.
                </Typography>
            </Box>
            <Box component={'div'} sx={styles.presetList}>
                {presets.map((preset, index) => (
                    <SelectableCard
                        key={preset.name}
                        title={preset.name}
                        selected={selectedPreset?.name == preset.name}
                        imagePath={preset.previewImagePath || ''}
                        description={preset.detailText || ''}
                        onSelect={() => onPresetClicked(preset)}
                        style={index === presets.length - 1 ? undefined : { marginRight: '23.5px' }}
                    />
                ))}
            </Box>

            <Box component={'div'} sx={{ marginTop: 3.5, marginBottom: 0 }}>
                <Typography variant="h6">
                    My Custom Presets
                </Typography >
            </Box>
            <Box component={'div'} sx={styles.presetList}>
                {customPresets.map((preset, index) => (
                    <SelectableCard
                        key={preset.id}
                        title={preset.name}
                        description={preset.description}
                        selected={false}
                        imagePath={''}
                        onSelect={() => {}}
                        style={index === customPresets.length - 1 ? undefined : { marginRight: '23.5px' }}
                    />
                ))}
            </Box>
        </Box>
    )
}

export default PresetSelection
