import { Box, Button, Checkbox, Divider, FormControl, FormControlLabel, FormGroup, Grid, MenuItem, Select, Tab, Tabs, Typography } from "@mui/material";
import React, { useState } from "react";
import TabPanel from "./ParamTabPanel";
import { RunParams } from "../../state/types/Run";
import MethodSettings from "./maskingForm/MethodSettings";
import MovieFilterIcon from '@mui/icons-material/MovieFilter';
import EmojiPeopleIcon from '@mui/icons-material/EmojiPeople';
import GraphicEqIcon from '@mui/icons-material/GraphicEq';
import { maskingMethods } from "../../util/maskingMethods";
import { MaskingMethods, Method } from "../../state/types/RunParamRendering";

interface ParameterTabOverviewProps {
    runParams: RunParams
    onParamsChange: (runParams: RunParams) => void
    onRunClicked: () => void
}

const ButtonInTabs = ({ onClick, children }: { onClick: () => void, children: React.ReactNode }) => {
    return <Button onClick={onClick} sx={{ margin: "10px" }} children={children} variant="contained" />;
};

const ParamterTabOverview = (props: ParameterTabOverviewProps) => {
    const [selectedTab, setSelectedTab] = useState<number>(0)
    const { runParams, onParamsChange, onRunClicked } = props

    const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
        setSelectedTab(newValue);
    };

    const upperFirst = (str: string) => {
        return str.charAt(0).toUpperCase() + str.slice(1)
    }

    const onMethodChange = (videoPart: string, strategy: "hidingStrategy" | "maskingStrategy", methodKey: string) => {
        const methodType = strategy == "hidingStrategy" ? "hidingMethods" : "maskingMethods"
        onParamsChange({
            ...runParams,
            videoMasking: {
                ...runParams.videoMasking,
                [videoPart]: {
                    ...runParams.videoMasking[videoPart],
                    [strategy]: {
                        key: methodKey,
                        params: maskingMethods[videoPart][methodType]![methodKey].defaultValues
                    }
                }
            }
        })
    }

    const maskVideoStrategyParamSetter = (videoPart: string, strategy: "hidingStrategy" | "maskingStrategy") => {
        const paramSetter = (newParams: object) => {
            onParamsChange({
                ...runParams,
                videoMasking: {
                    ...runParams.videoMasking,
                    [videoPart]: {
                        ...runParams.videoMasking[videoPart],
                        [strategy]: {
                            ...runParams.videoMasking[videoPart][strategy],
                            params: newParams
                        }
                    }
                }
            })
        }
        return paramSetter
    }

    const set3DParams = (strategy: "blender" | "skeleton" | "blendshapes", value: boolean) => {
        onParamsChange({
            ...runParams,
            threeDModelCreation: {
                ...runParams.threeDModelCreation,
                [strategy]: value
            }
        })
    }

    const a11yProps = (index: number) => {
        return {
            id: `vertical-tab-${index}`,
            'aria-controls': `vertical-tabpanel-${index}`,
        };
    }
    return (
        <div style={{ display: "flex" }}>
            <Tabs
                orientation="vertical"
                variant="scrollable"
                value={selectedTab}
                onChange={handleTabChange}
                sx={{ borderRight: 1, borderColor: 'divider' }}
            >
                <Tab icon={<MovieFilterIcon />} iconPosition="start" label="Video Masking" {...a11yProps(0)} />
                <Tab icon={<GraphicEqIcon />} iconPosition="start" label="Voice Masking" {...a11yProps(1)} />
                <Tab icon={<EmojiPeopleIcon />} iconPosition="start" label="3D Extraction" {...a11yProps(2)} />
                <ButtonInTabs
                    onClick={() => onRunClicked()}>
                    Run
                </ButtonInTabs>
            </Tabs>
            <TabPanel value={selectedTab} index={0}>
                <Typography>Select strategies for masking different parts of your video.</Typography>
                <Grid container sx={{ pt: 3, pl: 5 }} rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }}>
                    <Grid item xs={12}>
                        <Grid container>
                            <Grid item xs={2}>Video Part to Mask</Grid>
                            <Grid item xs={5}>Hiding Strategy</Grid>
                            <Grid item xs={5}>Masking Strategy</Grid>
                        </Grid>
                        <Divider light />
                    </Grid>
                    {Object.keys(maskingMethods).map((videoPart: string) => {
                        const videoPartMethods = maskingMethods[videoPart]
                        const activeHidingStrategyKey: string = runParams.videoMasking[videoPart].hidingStrategy.key
                        const activeHidingStrategy = videoPartMethods.hidingMethods[activeHidingStrategyKey]
                        const activeMaskingStrategyKey = runParams.videoMasking[videoPart].maskingStrategy?.key
                        return (
                            <>
                                <Grid item xs={2} sx={{ display: 'flex', alignItems: 'center' }}>
                                    <Typography>{upperFirst(videoPart)}</Typography>
                                </Grid>
                                <Grid item xs={5}>
                                    <Grid container>
                                        <Grid item xs={8}>
                                            <Select
                                                value={activeHidingStrategyKey}
                                                onChange={(e) => { onMethodChange(videoPart, "hidingStrategy", e.target.value) }}
                                                fullWidth
                                            >
                                                {Object.keys(videoPartMethods.hidingMethods).map((hidingMethod: string) => {
                                                    return (
                                                        <MenuItem value={hidingMethod}>{upperFirst(videoPartMethods.hidingMethods[hidingMethod].name)}</MenuItem>
                                                    )
                                                })}
                                            </Select>
                                        </Grid>
                                        <Grid item xs={4} sx={{ display: 'flex', alignItems: 'center' }}>
                                            <MethodSettings
                                                methodName={activeHidingStrategyKey}
                                                formSchema={activeHidingStrategy.parameterSchema}
                                                uiSchema={activeHidingStrategy.uiSchema}
                                                values={runParams.videoMasking[videoPart].hidingStrategy?.params}
                                                onSet={maskVideoStrategyParamSetter(videoPart, "hidingStrategy")}
                                            />
                                        </Grid>
                                    </Grid>
                                </Grid>
                                {videoPartMethods.maskingMethods && activeMaskingStrategyKey ? <Grid item xs={5}>
                                    <Grid container>
                                        <Grid item xs={8}>
                                            <Select
                                                value={activeMaskingStrategyKey}
                                                onChange={(e) => { onMethodChange(videoPart, "maskingStrategy", e.target.value) }}
                                                fullWidth
                                            >
                                                {Object.keys(videoPartMethods.maskingMethods).map((maskingMethod: string) => {
                                                    return (
                                                        <MenuItem value={maskingMethod}>{upperFirst(videoPartMethods.maskingMethods![maskingMethod].name)}</MenuItem>
                                                    )
                                                })}
                                            </Select>
                                        </Grid>
                                        <Grid item xs={4} sx={{ display: 'flex', alignItems: 'center' }}>
                                            <MethodSettings
                                                methodName={activeMaskingStrategyKey}
                                                formSchema={maskingMethods[videoPart].maskingMethods![activeMaskingStrategyKey].parameterSchema}
                                                uiSchema={maskingMethods[videoPart].maskingMethods![activeMaskingStrategyKey].uiSchema}
                                                values={runParams.videoMasking[videoPart].maskingStrategy?.params}
                                                onSet={maskVideoStrategyParamSetter(videoPart, "maskingStrategy")}
                                            />
                                        </Grid> </Grid></Grid> : <Grid item xs={4}></Grid>}
                            </>
                        )
                    })}
                </Grid>


            </TabPanel>
            <TabPanel value={selectedTab} index={1}>
                <Typography>Coming soon! Stay tuned...</Typography>
            </TabPanel>
            <TabPanel value={selectedTab} index={2}>
                <Typography>Select whether you want to extract 3D models from you video and define extraction parameters.</Typography>
                <FormGroup sx={{ pt: 3, pl: 5 }}>
                    <FormControlLabel
                        control={<Checkbox checked={runParams.threeDModelCreation.skeleton} value={runParams.threeDModelCreation.skeleton} onChange={(e, c) => { set3DParams("skeleton", c) }} />}
                        label="3D Skeleton"
                    />
                    <FormControlLabel
                        control={<Checkbox checked={runParams.threeDModelCreation.blender} value={runParams.threeDModelCreation.blender} onChange={(e, c) => { set3DParams("blender", c) }} />}
                        label="3D Character in Blender (FBX File)"
                    />
                    <FormControlLabel
                        control={<Checkbox checked={runParams.threeDModelCreation.blendshapes} value={runParams.threeDModelCreation.blendshapes} onChange={(e, c) => { set3DParams("blendshapes", c) }} />}
                        label="Facial Expressions on Animated Character (gLTF Model)"
                    />
                </FormGroup>
            </TabPanel>
        </div>
    )
}

export default ParamterTabOverview