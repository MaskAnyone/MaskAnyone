import { Button, Grid, Paper, Typography } from "@mui/material";
import { Box } from "@mui/system";
import PresetItem from "./PresetItem";
import TuneIcon from '@mui/icons-material/Tune';
import { useState } from "react";
import { Preset, RunParams } from "../../state/types/Run";

interface PresetSelectionProps {
    setParams: (runParams: RunParams) => void
    showPresetView: (val: boolean) => void
}

enum HidingStrategy {
    Blur,
    Blackout,
    Estimate
}

enum HidingSubjects {
    Background,
    Person,
    Head
}

enum PersonDetectionTypes {
    BBox,
    Silhouette
}

type BlurParams<T extends HidingSubjects> = {
    type: HidingStrategy.Blur
    kernelSize: number
} & (T extends HidingSubjects.Background ? {} : { additionalBorder: number });

type BlackoutParams<T extends HidingSubjects> = {
    type: HidingStrategy.Blackout
    color: `rgba(${number}, ${number}, ${number}, ${number})`
} & (T extends HidingSubjects.Background ? {} : { additionalBorder: number });

type EstimationParams = {
    type: HidingStrategy.Estimate
}

type PersonDetectionParamsBBox = {
    model: 'Yolo'
    type: PersonDetectionTypes.BBox
    confidence: number
} 

type PersonDetectionParamsSilhouette = {
    model: 'Yolo'
    type: PersonDetectionTypes.Silhouette
    confidence: number
    smoothingFactor: number
} | {
    model: 'MediaPipe'
    type: PersonDetectionTypes.Silhouette
    confidence: number
    smoothingFactor: number
}   

type HidingParams = {
    bg: BlurParams<HidingSubjects.Background> | BlackoutParams<HidingSubjects.Background>
} & ({
    personDetection: PersonDetectionParamsBBox
    personHidingParams: BlurParams<HidingSubjects.Person> | BlackoutParams<HidingSubjects.Person>
    headHidingParams: BlurParams<HidingSubjects.Head> | BlackoutParams<HidingSubjects.Head>
} | {
    personDetection: PersonDetectionParamsSilhouette
    personHidingParams: BlurParams<HidingSubjects.Person> | BlackoutParams<HidingSubjects.Person> | EstimationParams
    headHidingParams: BlurParams<HidingSubjects.Head> | BlackoutParams<HidingSubjects.Head> | EstimationParams
})

type BodyMaskingParams = {

}

type HeadMaskingParams = {
}

type MaskingParams = {
    body: BodyMaskingParams,
    head: HeadMaskingParams
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
                            onClick={() => props.showPresetView(true)}
                        />
                    </Grid>
                </Grid>
    )
}

export default PresetSelection