import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../../../state/types/Run";
import { presetsDB } from "../../../../util/presets"
import SelectableCard from "../../../common/SelectableCard";

interface PresetSelectionProps {
    onPresetSelected: (preset: Preset) => void
    selectedPreset?: Preset
}

const PresetSelection = (props: PresetSelectionProps) => {
    const [presets, setPresets] = useState(presetsDB)
    const { selectedPreset } = props

    const onPresetClicked = (preset: Preset) => {
        props.onPresetSelected(preset)
    }

    return (
        <Box component={'div'} sx={{ width: '100%', display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '24px'}}>
            {presets.map(preset => (
                <SelectableCard
                    key={preset.name}
                    title={preset.name}
                    selected={selectedPreset?.name == preset.name}
                    imagePath={preset.previewImagePath || ''}
                    description={preset.detailText || ''}
                    onSelect={() => onPresetClicked(preset)}
                />
            ))}
        </Box>
    )
}

export default PresetSelection
