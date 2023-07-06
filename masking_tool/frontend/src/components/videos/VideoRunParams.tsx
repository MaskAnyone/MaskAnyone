import { Grid, FormGroup, FormControlLabel, Switch, Button, MenuItem, Select, Box, SelectChangeEvent, InputLabel, FormControl, Tab, Tabs, IconButton, Divider } from "@mui/material"
import { useEffect, useState } from "react";
import { useDispatch } from "react-redux";
import Command from "../../state/actions/command";
import { v4 as uuidv4 } from 'uuid';
import PresetSelection from "./PresetSelection";
import { RunParams, Preset } from "../../state/types/Run";
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
    const dispatch = useDispatch();
    const [presetView, setPresetView] = useState(true)
    const [runParams, setRunParams] = useState<RunParams>(initialRunParams)
    const [selectedPreset, setSelectedPreset] = useState<Preset>()

    const initRunParams = () => {
        const newRunParams = initialRunParams
        Object.keys(maskingMethods).forEach((videoPart) => {
            const hidingStrategy = {
                key: Object.keys(maskingMethods[videoPart].hidingMethods)[0],
                params: {}
            }
            newRunParams.videoMasking[videoPart] = {
                hidingStrategy: hidingStrategy
            }
            if (maskingMethods[videoPart].maskingMethods) {
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

    const onPresetSelected = (preset: Preset) => {
        setRunParams(preset.runParams)
        setSelectedPreset(preset)
    }

    const onCustomModeRequested = () => {
        setPresetView(false)
        setSelectedPreset(undefined)
    }

    const maskVideo = () => {
        if (!props.videoId) {
            return;
        }

        dispatch(Command.Video.maskVideo({
            id: uuidv4(),
            videoId: props.videoId,
            runData: runParams
        }));
    };

    return (
        <Box component="div" sx={{ flexGrow: 1, bgcolor: 'background.paper', display: 'flex', minHeight: 224 }}>
            {presetView ?
                <Box component="div" sx={{ flexGrow: 1, padding: "20px 40px" }}>
                    <Grid container>
                        <PresetSelection selectedPreset={selectedPreset} onPresetSelect={onPresetSelected} onCustomModeRequested={onCustomModeRequested} />
                        <Grid container>
                            <Grid item xs={12}>
                                <Box
                                    display="flex"
                                    component="div"
                                    justifyContent="flex-end"
                                    alignItems="flex-end"
                                    visibility={selectedPreset ? "visible" : "hidden"}
                                    paddingTop={"22px"}>
                                    <Button
                                        variant={'contained'}
                                        startIcon={<TuneIcon />}
                                        children={'Customize Params'}
                                        onClick={() => setPresetView(false)}
                                        sx={{ marginRight: "20px" }}
                                    />
                                    <Button
                                        variant={'contained'}
                                        startIcon={<MasksIcon />}
                                        onClick={() => maskVideo()}
                                        children={'Mask Video'}
                                    />
                                </Box>
                            </Grid>
                        </Grid>
                    </Grid>
                </Box>
                : <div>
                    <Box component="div" sx={{ flexGrow: 1, padding: "20px 40px" }}>
                        <Grid container>
                            <Grid item xs={12}>
                                <IconButton onClick={() => setPresetView(true)}>
                                    <ArrowBackIcon />
                                </IconButton>
                                Presets
                            </Grid>
                            <Grid item xs={12}>
                                <ParamterTabOverview onRunClicked={maskVideo} runParams={runParams} onParamsChange={setRunParams} />
                            </Grid>
                        </Grid>
                    </Box>
                </div>}
        </Box>
    )
}

export default VideoRunParams
