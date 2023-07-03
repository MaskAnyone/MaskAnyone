import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../state/types/Run";

interface PresetSelectionProps {
    onPresetSelect: (runParams: RunParams) => void
    onCustomModeRequested: () => void
}

 const mockPresets: Preset[] = [
    {
        name: "Blur Face",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Mask Kinematics",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Video to 3D Character",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Replace Face",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
    {
        name: "Blur Background",
        runParams: {
            videoMasking: {},
            threeDModelCreation: {},
            voiceMasking: {}
        }
    },
]

const PresetSelection = (props: PresetSelectionProps) => {
    const [presets, setPresets] = useState(mockPresets)
    const [selected, setSelected] = useState<string | undefined>()

    const onPresetClicked = (preset: Preset) => {
        setSelected(preset.name)
        props.onPresetSelect(preset.runParams)
    }

    return(
                <Grid container rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }} xs={12} marginTop={"10px"}>
                    {presets.map((preset, index) => {
                        return(
                            <Grid item xs={4}>
                                <PresetItem
                                    name={preset.name}
                                    selected={selected==preset.name}
                                    previewImagePath={preset.previewImagePath}
                                    onClick={() => onPresetClicked(preset)}
                                />
                            </Grid>
                        )
                    })}
                    <Grid item xs={4}>
                        <PresetItem
                            name="Custom Run"
                            icon={<TuneIcon/>}
                            hideInfo={true}
                            selected={false}
                            onClick={() => props.onCustomModeRequested()}
                        />
                    </Grid>
                </Grid>
    )
}

export default PresetSelection