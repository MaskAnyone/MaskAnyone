import { Grid, FormGroup, FormControlLabel, Switch, Button, MenuItem, Select, Box, SelectChangeEvent, InputLabel, FormControl, Tab, Tabs, IconButton, Divider } from "@mui/material"
import { useEffect, useState } from "react";
import {useDispatch, useSelector} from "react-redux";
import Command from "../../state/actions/command";
import Selector from "../../state/selector";
import { v4 as uuidv4 } from 'uuid';
import PresetSelection from "./PresetSelection";
import TabPanel from "./ParamTabPanel";
import { RunParams } from "../../state/types/Run";
import MasksIcon from '@mui/icons-material/Masks';
import TuneIcon from '@mui/icons-material/Tune';
import ParamterTabOverview from "./ParameterTabOverview";
import ArrowBackIcon from '@mui/icons-material/ArrowBack';

interface VideoRunParamsProps {
    videoId: string;
}

const initialRunParams = {

}

const VideoRunParams = (props: VideoRunParamsProps) => {
    const dispatch = useDispatch();
    const videoMaskingJobs = useSelector(Selector.Video.videoMaskingJobs);

    const [presetView, setPresetView] = useState(true)
    const [runParams, setRunParams] = useState<RunParams>(initialRunParams)

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
        <Box sx={{ flexGrow: 1, bgcolor: 'background.paper', display: 'flex', height: 224 }}>
            {presetView ? 
                <Box sx={{ flexGrow: 1, padding: "20px 40px" }}>
                    <Grid container>
                        <PresetSelection setParams={setRunParams} showPresetView={setPresetView}/>
                        <Grid container xs={12}>
                                <Grid item xs={12}>
                                    <Box display="flex" justifyContent="flex-end" alignItems="flex-end" paddingTop={"22px"}>
                                        <Button
                                            variant={'contained'}
                                            startIcon={<TuneIcon/>}
                                            children={'Modify Params'}
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
                            <ParamterTabOverview />
                        </Grid>
                    </Grid>
                </Box>
            </div>}
        </Box>
    )
}

export default VideoRunParams
