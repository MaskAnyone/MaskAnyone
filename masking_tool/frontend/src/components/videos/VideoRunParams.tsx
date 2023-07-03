import { Grid, FormGroup, FormControlLabel, Switch, Button, MenuItem, Select, Box, SelectChangeEvent, InputLabel, FormControl, Tab, Tabs, IconButton, Divider } from "@mui/material"
import { useEffect, useState } from "react";
import {useDispatch, useSelector} from "react-redux";
import Command from "../../state/actions/command";
import { v4 as uuidv4 } from 'uuid';
import PresetSelection from "./PresetSelection";
import TabPanel from "./ParamTabPanel";
import { Strategy, RunParams } from "../../state/types/Run";
import MasksIcon from '@mui/icons-material/Masks';
import TuneIcon from '@mui/icons-material/Tune';
import ParamterTabOverview from "./ParameterTabOverview";
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { maskingMethods } from "../../util/maskingMethods";

interface VideoRunParamsProps {
    videoId: string;
}

const initialRunParams: RunParams = {
    videoMasking: {},
    threeDModelCreation: {
        skeleton: false,
        skeletonParams: {},
        blender: false,
        blenderParams: {},
        blendshapes: false,
        blendshapesParams: {}
    },
    voiceMasking: {}
}

const VideoRunParams = (props: VideoRunParamsProps) => {

    const [presetView, setPresetView] = useState(true)
    const [runParams, setRunParams] = useState<RunParams>(initialRunParams)
    const [presetSelected, setPresetSelected] = useState(false)

    const initRunParams = () => {
        const newRunParams = initialRunParams
        Object.keys(maskingMethods).forEach((videoPart) => {
            const hidingStrategy  = {
                key: Object.keys(maskingMethods[videoPart].hidingMethods)[0],
                params: {}
            }
            newRunParams.videoMasking[videoPart] = {
                hidingStrategy: hidingStrategy
            }
            if(maskingMethods[videoPart].maskingMethods) {
                newRunParams.videoMasking[videoPart].maskingStrategy = {
                    key: Object.keys(maskingMethods[videoPart].maskingMethods!)[0],
                    params: {}
                }
            }

        })
        setRunParams(newRunParams)
    }

    useEffect(() => {
        initRunParams()
    }, [])

    const onPresetSelected = (runParams: RunParams) => {
        setRunParams(runParams)
        setPresetSelected(true)
    }

    const onCustomModeRequested = () => {
        setPresetView(false)
        setPresetSelected(false)
    }

    const maskVideo = () => {
        if (!props.videoId) {
            return;
        }

        /*dispatch(Command.Video.maskVideo({
            id: uuidv4(),
            videoId: props.videoId,
            extractPersonOnly,
            headOnlyHiding,
            hidingStrategy,
            headOnlyMasking,
            maskCreationStrategy,
            detailedFingers,
            detailedFaceMesh
        })); */
    };

    return (
        <Box sx={{ flexGrow: 1, bgcolor: 'background.paper', display: 'flex', minHeight: 224 }}>
            {presetView ? 
                <Box sx={{ flexGrow: 1, padding: "20px 40px" }}>
                    <Grid container>
                        <PresetSelection onPresetSelect={onPresetSelected} onCustomModeRequested={onCustomModeRequested}/>
                        <Grid container xs={12}>
                                <Grid item xs={12}>
                                    <Box
                                        display="flex"
                                        justifyContent="flex-end" 
                                        alignItems="flex-end"
                                        visibility={presetSelected? "visible": "hidden"}
                                        paddingTop={"22px"}>
                                        <Button
                                            variant={'contained'}
                                            startIcon={<TuneIcon/>}
                                            children={'Customize Params'}
                                            onClick={() => setPresetView(false)}
                                            sx={{marginRight: "20px"}}
                                        />
                                        <Button
                                            variant={'contained'}
                                            startIcon={<MasksIcon />}
                                            children={'Mask Video'}
                                        />
                                    </Box>
                                </Grid>
                        </Grid>
                    </Grid>
                </Box> 
            : <div>
                <Box sx={{ flexGrow: 1, padding: "20px 40px" }}>
                    <Grid container>
                        <Grid item xs={12}>
                        <IconButton onClick={() => setPresetView(true)}>
                            <ArrowBackIcon />
                        </IconButton>
                        Presets
                        </Grid>
                        <Grid container xs={12}>
                            <ParamterTabOverview runParams={runParams} onParamsChange={setRunParams}/>
                        </Grid>
                    </Grid>
                </Box>
            </div>}
        </Box>
    )
}

export default VideoRunParams
