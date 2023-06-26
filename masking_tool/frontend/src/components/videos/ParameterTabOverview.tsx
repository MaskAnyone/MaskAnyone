import { FormControl, Grid, MenuItem, Select, Tab, Tabs, Typography } from "@mui/material";
import { useState } from "react";
import TabPanel from "./ParamTabPanel";
import { RunParams } from "../../state/types/Run";
import MethodSettings from "./MethodSettings";
import MovieFilterIcon from '@mui/icons-material/MovieFilter';
import EmojiPeopleIcon from '@mui/icons-material/EmojiPeople';
import GraphicEqIcon from '@mui/icons-material/GraphicEq';
import { maskingMethods } from "../../util/maskingMethods";
import { MaskingMethods, Method } from "../../state/types/RunParamRendering";

interface ParameterTabOverviewProps {
    runParams: RunParams
    onParamsChange: (runParams: RunParams) => void
}

const ParamterTabOverview = (props: ParameterTabOverviewProps) => {
    const [selectedTab, setSelectedTab] = useState<number>(0)
    const { runParams, onParamsChange } = props

    const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
        setSelectedTab(newValue);
    };

    const upperFirst = (str: string) => {
        return str.charAt(0).toUpperCase() + str.slice(1)
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

    const a11yProps = (index: number) => {
        return {
          id: `vertical-tab-${index}`,
          'aria-controls': `vertical-tabpanel-${index}`,
        };
    }
    return (
        <>
        <Tabs
        orientation="vertical"
        variant="scrollable"
        value={selectedTab}
        onChange={handleTabChange}
        sx={{ borderRight: 1, borderColor: 'divider' }}
    >
        <Tab icon={<MovieFilterIcon />} iconPosition="start" label="Mask Video" {...a11yProps(0)} />
        <Tab  icon={<EmojiPeopleIcon />} iconPosition="start" label="Extract 3D Model" {...a11yProps(1)} />
        <Tab icon={<GraphicEqIcon />} iconPosition="start" label="Mask Voice" {...a11yProps(2)} />
    </Tabs>
    <TabPanel value={selectedTab} index={0}>
        <Typography>Select strategies for masking different parts of your video.</Typography>
        <Grid container sx={{pt: 3, pl: 5}} rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }}>
            {Object.keys(maskingMethods).map((videoPart: string) => {
                const videoPartMethod = maskingMethods[videoPart]
                const activeHidingStrategy: string = runParams.videoMasking[videoPart].hidingStrategy.key
                const activeMaskingStrategy = runParams.videoMasking[videoPart].maskingStrategy?.key
                console.log(videoPartMethod)
                return (
                   <>
                        <Grid item xs={4}>
                            <Typography>{upperFirst(videoPart)}</Typography>
                        </Grid>
                        <Grid item xs={4}>
                            <FormControl fullWidth>
                                <Select
                                    value={activeHidingStrategy}
                                >
                                    {Object.keys(videoPartMethod.hidingMethods).map((hidingMethod: string) => {
                                        return (
                                            <MenuItem value={hidingMethod}>{upperFirst(videoPartMethod.hidingMethods[hidingMethod].name)}</MenuItem>
                                        )
                                    })}
                                </Select>
                                <MethodSettings
                                    methodName={activeHidingStrategy}
                                    formSchema={maskingMethods[videoPart].hidingMethods[activeHidingStrategy].parameterSchema}
                                    onSet={maskVideoStrategyParamSetter(videoPart, "hidingStrategy")}
                                />
                            </FormControl>
                        </Grid>
                        <Grid item xs={4}>
                            {videoPartMethod.maskingMethods ? <FormControl fullWidth>
                                <Select
                                    value={activeMaskingStrategy}
                                >
                                    {Object.keys(videoPartMethod.maskingMethods).map((maskingMethod: string) => {
                                        return (
                                            <MenuItem value={maskingMethod}>{upperFirst(videoPartMethod.maskingMethods![maskingMethod].name)}</MenuItem>
                                        )
                                    })}
                                </Select>
                                <MethodSettings
                                    methodName={activeMaskingStrategy}
                                    formSchema={maskingMethods[videoPart].maskingMethods![activeMaskingStrategy].parameterSchema}
                                    onSet={maskVideoStrategyParamSetter(videoPart, "maskingStrategy")}
                                />
                            </FormControl> : <></>}
                        </Grid>
                    </>
                )
            })}
        </Grid>


    </TabPanel>
    <TabPanel value={selectedTab} index={1}>
        <Typography>Select a strategy for extracting a 3D model from your video.</Typography>
    </TabPanel>
    <TabPanel value={selectedTab} index={2}>
        <Typography>Coming soon! Stay tuned...</Typography>
    </TabPanel> 
    </>
    )
}

export default ParamterTabOverview