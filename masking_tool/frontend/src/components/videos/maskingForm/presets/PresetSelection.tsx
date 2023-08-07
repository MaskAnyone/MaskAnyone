import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../../../state/types/Run";
import { presetsDB } from "../../../../util/presets"

interface PresetSelectionProps {
    onPresetSelected: (preset: Preset) => void
    onCustomModeClicked: () => void
    selectedPreset?: Preset
}

const PresetSelection = (props: PresetSelectionProps) => {
    const [presets, setPresets] = useState(presetsDB)
    const { selectedPreset } = props

    const onPresetClicked = (preset: Preset) => {
        props.onPresetSelected(preset)
    }

    return (
        <Grid container rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }} xs={12} marginTop={"10px"}>
            {presets.map((preset, index) => (
                <Grid item xs={4} key={preset.name}>
                    <PresetItem
                        name={preset.name}
                        selected={selectedPreset ? selectedPreset.name == preset.name : false}
                        previewImagePath={preset.previewImagePath}
                        description={preset.detailText}
                        onClick={() => onPresetClicked(preset)}
                    />
                </Grid>
            ))}
            <Grid item xs={4}>
                <PresetItem
                    name="Custom Run"
                    icon={<TuneIcon />}
                    selected={false}
                    onClick={() => props.onCustomModeClicked()}
                />
            </Grid>
        </Grid>
    )
}

export default PresetSelection
