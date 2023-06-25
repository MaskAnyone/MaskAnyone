import { Grid, FormGroup, FormControlLabel, Switch, Button, MenuItem, Select, Box, SelectChangeEvent, InputLabel, FormControl } from "@mui/material"
import MasksIcon from '@mui/icons-material/Masks';
import { useEffect, useState } from "react";
import {useDispatch, useSelector} from "react-redux";
import Command from "../../state/actions/command";
import Selector from "../../state/selector";
import { v4 as uuidv4 } from 'uuid';

interface VideoRunParamsProps {
    videoId: string;
}

const VideoRunParams = (props: VideoRunParamsProps) => {
    const dispatch = useDispatch();
    const videoMaskingJobs = useSelector(Selector.Video.videoMaskingJobs);
    const [extractPersonOnly, setExtractPersonOnly] = useState(false)
    const [headOnlyHiding, setHeadOnlyHiding] = useState(false)
    const [hidingStrategy, setHidingStrategy] = useState<number|undefined>()

    const [headOnlyMasking, setHeadOnlyMasking] = useState<boolean>(false)
    const [maskCreationStrategy, setMaskCreationStrategy] = useState<number|undefined>()
    const [detailedFaceMesh, setDetailedFaceMesh] = useState(false)
    const [detailedFingers, setDetailedFingers] = useState(false)

    useEffect(() => {
        if(headOnlyHiding) {
            setHeadOnlyMasking(true)
        }
    }, [headOnlyHiding])

    const maskVideo = () => {
        if (!props.videoId || !hidingStrategy || ! maskCreationStrategy) {
            return;
        }

        dispatch(Command.Video.maskVideo({
            id: uuidv4(),
            videoId: props.videoId,
            extractPersonOnly,
            headOnlyHiding,
            hidingStrategy,
            headOnlyMasking,
            maskCreationStrategy,
            detailedFingers,
            detailedFaceMesh
        }));
    };

    return (
        <Box sx={{ marginBottom: 2 }}>
            <Grid container spacing={2}>
                <Grid item xs={6} style={{padding: "15px"}}>
                    <h4>1. Person Removal Options</h4>
                    <FormGroup>
                        <FormControlLabel control={<Switch checked={extractPersonOnly} onChange={(e,c) => {setExtractPersonOnly(c)}}/>} label="Remove complete background" />
                        {extractPersonOnly ? <></> :
                            <>
                                <FormControlLabel control={<Switch value={headOnlyHiding} onChange={(e, c) => {setHeadOnlyHiding(c)}}/>} label="Hide head only" />
                                <FormControl>
                                    <InputLabel id="select-hiding-strategy-label">Person Hiding Strategy</InputLabel>
                                    <Select
                                        id="select-hiding-strategy"
                                        labelId="select-hiding-strategy-label"
                                        value={hidingStrategy}
                                        label="Person Hiding Strategy"
                                        onChange={(e: SelectChangeEvent<number>, c) => {setHidingStrategy(Number(e.target.value))}}
                                        >
                                            <MenuItem value={1}>BoundingBox Black</MenuItem>
                                            <MenuItem value={2}>BoundingBox Blur</MenuItem>
                                            <MenuItem value={3} disabled={headOnlyHiding}>Silhouette Yolo</MenuItem>
                                            <MenuItem value={3} disabled={headOnlyHiding}>Silhouette MediaPipe</MenuItem>
                                            <MenuItem value={4} disabled={headOnlyHiding}>Estimate Background</MenuItem>
                                    </Select>
                                </FormControl>
                            </>
                        }
            </FormGroup>
                </Grid>
                <Grid item xs={6} style={{padding: "15px"}}>
                    <h4>2. Mask Creation Options</h4>
                    <FormGroup>
                        <FormControlLabel control={<Switch checked={headOnlyMasking} onChange={(e,c) => {setHeadOnlyMasking(c)}}/>} label="Create mask for head only" />
                        <FormControl style={{marginTop: "10px"}}>
                            <InputLabel id="select-maskcreation-strategy-label">Mask Creation Strategy</InputLabel>
                            <Select
                                labelId="select-maskcreation-strategy-label"
                                id="select-maskcreation-strategy"
                                value={maskCreationStrategy}
                                label="Mask Creation Strategy"
                                onChange={(e: SelectChangeEvent<number>, c) => {setMaskCreationStrategy(Number(e.target.value))}}
                                >
                                    <MenuItem value={1}>MediaPipe Skeleton</MenuItem>
                                    <MenuItem value={2} disabled>3D Character</MenuItem>
                            </Select>
                        </FormControl>
                        {maskCreationStrategy == 1 ?
                            <>
                                <FormControlLabel control={<Switch checked={detailedFaceMesh} onChange={(e,c) => {setHeadOnlyMasking(c)}}/>} label="Detailed Face Mesh" />
                                <FormControlLabel control={<Switch checked={detailedFingers} onChange={(e,c) => {setHeadOnlyMasking(c)}}/>} label="Detailed Fingers" />
                            </> : <></> }
                        <Button
                            variant={'contained'}
                            startIcon={<MasksIcon />}
                            children={'Mask Video'}
                            onClick={maskVideo}
                            style={{marginTop: "10px"}}
                            disabled={videoMaskingJobs[props.videoId]}
                        />
                    </FormGroup>
                </Grid>
            </Grid>
        </Box>
    )
}

export default VideoRunParams
