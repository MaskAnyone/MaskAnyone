import { Box, Button, Grid } from "@mui/material"
import PresetSelection from "./PresetSelection"
import MasksIcon from '@mui/icons-material/Masks';
import TuneIcon from '@mui/icons-material/Tune';
import { Preset } from "../../../../state/types/Run";

interface PresetViewProps {
    onPresetSelected: (preset: Preset) => void
    onPresetParamRefinementClicked: () => void
    onCustomModeClicked: () => void
    selectedPreset?: Preset
    maskVideo: () => void
}

const PresetView = (props: PresetViewProps) => {
    return (
        <Box component="div" sx={{ flexGrow: 1, padding: "20px 40px" }}>
            <Grid container>
                <PresetSelection
                    selectedPreset={props.selectedPreset}
                    onPresetSelected={props.onPresetSelected}
                    onCustomModeClicked={props.onCustomModeClicked}
                />
                <Grid container>
                    <Grid item xs={12}>
                        <Box
                            display="flex"
                            component="div"
                            justifyContent="flex-end"
                            alignItems="flex-end"
                            visibility={props.selectedPreset ? "visible" : "hidden"}
                            paddingTop={"22px"}>
                            <Button
                                variant={'contained'}
                                startIcon={<TuneIcon />}
                                children={'Customize Params'}
                                onClick={() => props.onPresetParamRefinementClicked()}
                                sx={{ marginRight: "20px" }}
                            />
                            <Button
                                variant={'contained'}
                                startIcon={<MasksIcon />}
                                onClick={() => props.maskVideo()}
                                children={'Mask Video'}
                            />
                        </Box>
                    </Grid>
                </Grid>
            </Grid>
        </Box>)
}

export default PresetView