import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../state/types/Run";

interface PresetSelectionProps {
    onPresetSelect: (runParams: RunParams) => void
    customClickedHandler: (val: boolean) => void
}

 const mockPresets: Preset[] = [
    {
        name: "Blur Face",
    },
    {
        name: "Mask Kinematics",
    },
    {
        name: "Video to 3D Character",
    },
    {
        name: "Replace Face",
    },
    {
        name: "Blur Background",
    },
]

const PresetSelection = (props: PresetSelectionProps) => {
    const [presets, setPresets] = useState(mockPresets)

    return(
                <Grid container rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }} xs={12} marginTop={"10px"}>
                    {presets.map((preset, index) => {
                        return(
                            <Grid item xs={4}>
                                <PresetItem
                                    name={preset.name}
                                    previewImagePath={preset.previewImagePath}
                                />
                            </Grid>
                        )
                    })}
                    <Grid item xs={4}>
                        <PresetItem
                            name="Custom Run"
                            icon={<TuneIcon/>}
                            hideInfo={true}
                            onClick={() => props.customClickedHandler(true)}
                        />
                    </Grid>
                </Grid>
    )
}

export default PresetSelection