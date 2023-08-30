import {Box, Button, DialogActions, DialogContent, IconButton, Step, StepButton, Stepper} from "@mui/material"
import React, { useState } from "react";
import { RunParams } from "../../../../state/types/Run";
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import HidingStep, { StepProps } from "./steps/HidingStep";
import VideoMaskingStep from "./steps/VideoMaskingStep";
import VoiceMaskingStep from "./steps/VoiceMaskingStep";
import DataExctactionStep from "./steps/DataExtractionStep";
import ShieldLogoIcon from "../../../common/ShieldLogoIcon";

const steps = [
    {
        name: "Hiding",
        component: HidingStep
    },
    {
        name: "Video Masking",
        component: VideoMaskingStep
    },
    {
        name: "Voice Masking",
        component: VoiceMaskingStep
    },
    {
        name: "3D Model Extraction",
        component: DataExctactionStep
    }
]

const styles = {
    dialogActions: {
        paddingBottom: 2,
        paddingRight: 3,
    },
    stepButton: {
        "& .MuiSvgIcon-root.Mui-active": { color: "secondary.main" },
        "& .MuiStepLabel-label.Mui-active": { color: "secondary.main" },
    },
};

interface RunSettingsContainerProps {
    runParams: RunParams
    onParamsChange: (runParams: RunParams) => void
    onRunClicked: () => void
    onBackClicked: () => void
}

const CustomSettingsContainer = (props: RunSettingsContainerProps) => {
    const [activeStep, setActiveStep] = useState(0);

    const isStepCompleted = (index: number) => {
        return activeStep > index
    }

    const handleNext = () => {
        setActiveStep((prevActiveStep) => prevActiveStep + 1);
    };

    const handleBack = () => {
        setActiveStep((prevActiveStep) => prevActiveStep - 1);
    };

    const handleStepChange = (step: number) => {
        setActiveStep(step);
    };

    const currentStepContainer = () => {
        const StepContainer: ((props: StepProps) => JSX.Element) = steps[activeStep].component
        return (<Box component="div" sx={{ minHeight: "300px", paddingTop: 2 }}>
            <StepContainer runParams={props.runParams} onParamsChange={props.onParamsChange} />
        </Box>)
    }

    return (<>
        <DialogContent sx={{ minHeight: 550, padding: '20px 32px' }}>
            <Box component="div" sx={{ width: '100%' }}>
                <Box component="div" sx={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-between', marginTop: 1, marginBottom: 1 }}>
                    <Button
                        startIcon={<ArrowBackIcon />}
                        onClick={() => setTimeout(props.onBackClicked, 150)}
                        children={'Presets'}
                    />

                    <Stepper nonLinear activeStep={activeStep} sx={{ width: 700 }}>
                        {steps.map((step, index) => {
                            return (
                                <Step key={step.name} completed={isStepCompleted(index)}>
                                    <StepButton onClick={() => handleStepChange(index)} sx={styles.stepButton}>
                                        {step.name}
                                    </StepButton>
                                </Step>
                            );
                        })}
                    </Stepper>

                    {/* Spacer */}<Box component={'div'} sx={{ width: '100px' }}></Box>
                </Box>

                {currentStepContainer()}
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            {activeStep > 0 && <Button onClick={() => handleBack()}>Go back</Button>}
            {activeStep < steps.length - 1 && <Button variant="contained" sx={{ marginLeft: "25px" }} onClick={() => handleNext()}>Next</Button>}
            {activeStep == steps.length - 1 && <Button variant="contained" color="secondary" startIcon={<ShieldLogoIcon />} onClick={() => props.onRunClicked()} sx={{ marginLeft: "25px" }}>Mask Video</Button>}
        </DialogActions>
    </>)
}

export default CustomSettingsContainer
