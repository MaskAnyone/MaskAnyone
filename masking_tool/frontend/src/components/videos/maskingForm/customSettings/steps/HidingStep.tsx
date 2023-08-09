import { Box, Grid, MenuItem, Select, Typography } from "@mui/material"
import { RunParams } from "../../../../../state/types/Run"
import RadioCard from "../RadioCard"
import MethodSettings from "../../MethodSettings"
import { hidingMethods } from "../../../../../util/maskingMethods";
import { useEffect, useState } from "react";
import { Method } from "../../../../../state/types/RunParamRendering";
import SelectableCard from "../../../../common/SelectableCard";

export interface StepProps {
    runParams: RunParams,
    onParamsChange: (runParams: RunParams) => void
}

interface MaskingArea {
    title: string,
    value: "face" | "body" | "none",
    description: string,
    imagePath: string
}

const maskingAreas: MaskingArea[] = [
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
    const { runParams, onParamsChange } = props
    const videoMaskingParams = runParams.videoMasking
    const hidingTarget = videoMaskingParams.hidingTarget
    const hidingStrategyTarget = videoMaskingParams.hidingStrategyTarget
    const hidingStrategyBG = videoMaskingParams.hidingStrategyBG
    const [availableHidingMethodsTarget, setAvailableHidingMethodsTarget] = useState<{
        [methodName: string]: Method
    } | null>(null)
    const availableHidingMethodsBG = hidingMethods["background"]

    useEffect(() => {
        if (hidingTarget != "none") {
            setAvailableHidingMethodsTarget(hidingMethods[hidingTarget])
        } else {
            setAvailableHidingMethodsTarget(null)
        }
    }, [hidingTarget])

    const upperFirst = (str: string) => {
        return str.charAt(0).toUpperCase() + str.slice(1)
    }

    const setHidingTarget = (hidingTarget: string) => {
        if (!(hidingTarget == "face" || hidingTarget == "body" || hidingTarget == "none")) {
            return
        }
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingTarget: hidingTarget
            }
        })
    }

    const setHidingStrategyTarget = (hidingStrategy: string) => {
        let params;
        if (hidingStrategy != "none" && availableHidingMethodsTarget) {
            params = availableHidingMethodsTarget[hidingStrategy].defaultValues
        } else {
            params = {}
        }
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingStrategyTarget: {
                    key: "abc",
                    params: params!
                }
            }
        })
    }

    const setHidingStrategyTargetParams = (params: any) => {
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingStrategyTarget: {
                    ...runParams.videoMasking.hidingStrategyTarget,
                    params
                }
            }
        })
    }

    const setHidingStrategyBG = (hidingStrategy: string) => {
        let params;
        if (hidingStrategy != "none" && availableHidingMethodsBG) {
            params = availableHidingMethodsBG[hidingStrategy].defaultValues
        } else {
            params = {}
        }
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingStrategyBG: {
                    key: hidingStrategy,
                    params: params!
                }
            }
        })
    }

    const setHidingStrategyBGParams = (params: any) => {
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingStrategyBG: {
                    ...runParams.videoMasking.hidingStrategyBG,
                    params
                }
            }
        })
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
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '15px' }}>
                {
                    maskingAreas.map((area) => {
                        return (
                            <SelectableCard
                                title={area.title}
                                description={area.description}
                                imagePath={area.imagePath}
                                onSelect={() => setHidingTarget(area.value)}
                                selected={hidingTarget == area.value}
                            />
                        )
                    })
                }
            </Box>
            {
                (hidingStrategyTarget && availableHidingMethodsTarget) && (
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
                                        value={hidingStrategyTarget.key}
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
                                        methodName={hidingStrategyTarget.key}
                                        formSchema={availableHidingMethodsTarget[hidingStrategyTarget.key].parameterSchema}
                                        uiSchema={availableHidingMethodsTarget[hidingStrategyTarget.key].uiSchema}
                                        values={hidingStrategyTarget.params}
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
                                        value={hidingStrategyBG.key}
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
                                        methodName={hidingStrategyBG.key}
                                        formSchema={availableHidingMethodsBG[hidingStrategyBG.key].parameterSchema}
                                        uiSchema={availableHidingMethodsBG[hidingStrategyBG.key].uiSchema}
                                        values={hidingStrategyBG.params}
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