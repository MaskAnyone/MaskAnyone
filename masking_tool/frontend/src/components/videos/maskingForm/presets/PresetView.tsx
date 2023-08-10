import {Box, Button, DialogActions, DialogContent, Grid} from "@mui/material"
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
    return (<>
        <DialogContent sx={{ padding: '20px 32px' }}>
            <Box component="div" sx={{ flexGrow: 1, padding: "20px 40px" }}>
                <Grid container>
                    <PresetSelection
                        selectedPreset={props.selectedPreset}
                        onPresetSelected={props.onPresetSelected}
                        onCustomModeClicked={props.onCustomModeClicked}
                    />
                </Grid>
            </Box>
        </DialogContent>
        <DialogActions>
            <Button
                startIcon={<TuneIcon />}
                children={'Customize Params'}
                onClick={() => props.onPresetParamRefinementClicked()}
            />
            <Button
                variant={'contained'}
                startIcon={<MasksIcon />}
                onClick={() => props.maskVideo()}
                children={'Mask Video'}
            />
        </DialogActions>
    </>);
}

export default PresetView
