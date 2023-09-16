import { Box, Fade, Grid, MenuItem, Select, Typography } from "@mui/material"
import { RunParams } from "../../../../../state/types/Run"
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
        title: "None",
        description: "Do not hide anything",
        imagePath: "/images/hiding_strategy/none.jpg",
        value: "none"
    },
    {
        title: "Face Only",
        description: "Only hide the face of the subjects",
        imagePath: "/images/hiding_strategy/head_only.jpg",
        value: "face"
    },
    {
        title: "Full body",
        description: "Hide the complete body of the subject",
        imagePath: "/images/hiding_strategy/fullbody.jpg",
        value: "body"
    },

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
        const params = newStrategy == "none" ? {} : availableHidingMethodsTarget![newStrategy].defaultValues!
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingStrategyTarget: {
                    key: newStrategy,
                    params: params
                }
            }
        })
    }

    const handleHidingStrategyBGChanged = (newStrategy: string) => {
        const params = newStrategy == "none" ? {} : availableHidingMethodsBG![newStrategy].defaultValues!
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                hidingStrategyBG: {
                    key: newStrategy,
                    params: params
                }
            }
        })
    }

    return (
        <>
            <Box component={'div'} sx={{ marginBottom: 3.5 }}>
                <Typography variant="h6">
                    What do you want to hide?
                </Typography >
                <Typography variant={'body2'}>
                    Please select the area you want to hide. Hiding will overlay the selected area, so that it is not visible anymore.
                </Typography>
            </Box>
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '24px' }}>
                {
                    maskingAreas.map((area) => {
                        return (
                            <SelectableCard
                                title={area.title}
                                description={area.description}
                                imagePath={process.env.PUBLIC_URL + area.imagePath}
                                onSelect={() => setHidingTarget(area.value)}
                                selected={hidingTarget == area.value}
                            />
                        )
                    })
                }
            </Box>
            <Fade in={Boolean(hidingStrategyTarget && availableHidingMethodsTarget)}>
                <Box component="div">
                    <Grid container pt={3}>
                        <Grid xs={6} container>
                            <Grid item xs={12} pb={1}>
                                <Typography variant="body1">
                                    Hiding Strategy
                                </Typography>
                            </Grid>
                            <Grid item xs={10}>
                                {availableHidingMethodsTarget && (
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
                                )}
                            </Grid>
                            <Grid item xs={2} sx={{ display: 'flex', alignItems: 'center' }}>
                                {availableHidingMethodsTarget && (
                                    <MethodSettings
                                        methodName={hidingStrategyTarget.key}
                                        formSchema={availableHidingMethodsTarget[hidingStrategyTarget.key].parameterSchema}
                                        uiSchema={availableHidingMethodsTarget[hidingStrategyTarget.key].uiSchema}
                                        values={hidingStrategyTarget.params}
                                        onSet={setHidingStrategyTargetParams}
                                    />
                                )}
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
            </Fade>
        </>
    )
}

export default HidingStep
