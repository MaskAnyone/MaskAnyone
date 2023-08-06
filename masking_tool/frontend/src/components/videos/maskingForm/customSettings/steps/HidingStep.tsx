import { Box, Grid, MenuItem, Select, Typography } from "@mui/material"
import { RunParams } from "../../../../../state/types/Run"
import RadioCard from "../RadioCard"
import MethodSettings from "../../MethodSettings"
import { maskingMethods } from "../../../../../util/maskingMethods";
import { useEffect, useState } from "react";
import { Method } from "../../../../../state/types/RunParamRendering";

export interface StepProps {
    runParams: RunParams,
    onParamsChange: (runParams: RunParams) => void
}

const maskingAreas = [
    {
        title: "Face Only",
        description: "Only hide the face of the subjects",
        imagePath: "",
        value: "face"
    },
    {
        title: "Full body",
        description: "Hide the complete body of the subject",
        imagePath: "",
        value: "body"
    },
    {
        title: "None",
        description: "Do not hide anything",
        imagePath: "",
        value: "none"
    }
]

const HidingStep = (props: StepProps) => {
    const params = props.runParams.videoMasking
    const hidingTarget = params.hidingTarget
    const hidingStrategyTarget = params.hidingtrategyTarget
    const hidingStrategyBG = params.hidingStrategyBG
    const [availableHidingMethodsTarget, setAvailableHidingMethodsTarget] = useState<{
        [methodName: string]: Method
    } | null>(null)
    const availableHidingMethodsBG = maskingMethods["background"].hidingMethods

    useEffect(() => {
        if (hidingTarget != "none") {
            console.log(maskingMethods[hidingTarget].hidingMethods)
            setAvailableHidingMethodsTarget(maskingMethods[hidingTarget].hidingMethods)
        } else {
            setAvailableHidingMethodsTarget(null)
        }
    }, [hidingTarget])

    const upperFirst = (str: string) => {
        return str.charAt(0).toUpperCase() + str.slice(1)
    }

    const handleHidingStrategyTargetChanged = (newStrategy: string) => {
        setHidingStrategyTarget(newStrategy)
        if (newStrategy != "none") {
            setHidingStrategyTargetParams(availableHidingMethodsTarget![newStrategy].defaultValues)
        } else {
            setHidingStrategyTargetParams(null)
        }

    }

    const handleHidingStrategyBGChanged = (newStrategy: string) => {
        setHidingStrategyBG(newStrategy)
        if (newStrategy != "none") {
            setHidingStrategyBGParams(availableHidingMethodsBG![newStrategy].defaultValues)
        } else {
            setHidingStrategyBGParams(null)
        }
    }

    return (
        <>
            <Typography variant="body1" sx={{ fontWeight: 500 }} mt={3}>
                Area to Mask
            </Typography >
            {
                maskingAreas.map((area) => {
                    return (
                        <RadioCard
                            title={area.title}
                            description={area.description}
                            value={area.value}
                            imagePath={area.imagePath}
                            onSelect={setHidingTarget}
                            selected={hidingTarget == area.value}
                        />
                    )
                })
            }
            {
                availableHidingMethodsTarget && (
                    <Box component="div">
                        <Grid container pt={3}>
                            <Grid xs={6} container>
                                <Grid item xs={12} pb={1}>
                                    <Typography variant="body1">
                                        Hiding Strategy
                                    </Typography>
                                </Grid>
                                <Grid item xs={10}>
                                    <Select
                                        value={hidingStrategyTarget}
                                        onChange={(e) => { handleHidingStrategyTargetChanged(e.target.value) }}
                                        fullWidth
                                    >
                                        {Object.keys(availableHidingMethodsTarget).map((hidingMethod: string) => {
                                            return (
                                                <MenuItem value={hidingMethod}>{upperFirst(availableHidingMethodsTarget[hidingMethod].name)}</MenuItem>
                                            )
                                        })}
                                    </Select>
                                </Grid>
                                <Grid item xs={2} sx={{ display: 'flex', alignItems: 'center' }}>
                                    <MethodSettings
                                        methodName={hidingStrategyTarget}
                                        formSchema={availableHidingMethodsTarget[hidingStrategyTarget].parameterSchema}
                                        uiSchema={availableHidingMethodsTarget[hidingStrategyTarget].uiSchema}
                                        values={hidingStartegyTargetParams}
                                        onSet={setHidingStrategyTargetParams}
                                    />
                                </Grid>
                            </Grid>
                            <Grid xs={6} container>
                                <Grid item xs={12} pb={1}>
                                    <Typography variant="body1">
                                        Background Hiding Strategy
                                    </Typography>
                                </Grid>
                                <Grid item xs={10}>
                                    <Select
                                        value={hidingStrategyBG}
                                        onChange={(e) => { handleHidingStrategyBGChanged(e.target.value) }}
                                        fullWidth
                                    >
                                        {Object.keys(availableHidingMethodsBG).map((hidingMethod: string) => {
                                            return (
                                                <MenuItem value={hidingMethod}>{upperFirst(availableHidingMethodsBG[hidingMethod].name)}</MenuItem>
                                            )
                                        })}
                                    </Select>
                                </Grid>
                                <Grid item xs={2} sx={{ display: 'flex', alignItems: 'center' }}>
                                    <MethodSettings
                                        methodName={hidingStrategyBG}
                                        formSchema={availableHidingMethodsBG[hidingStrategyBG].parameterSchema}
                                        uiSchema={availableHidingMethodsBG[hidingStrategyBG].uiSchema}
                                        values={hidingStartegyBGParams}
                                        onSet={setHidingStrategyBGParams}
                                    />
                                </Grid>
                            </Grid>
                        </Grid>
                    </Box >
                )
            }
        </>
    )
}

export default HidingStep