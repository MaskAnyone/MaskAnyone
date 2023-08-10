import {Box, Button, DialogActions, DialogContent, Grid} from "@mui/material"
import PresetSelection from "./PresetSelection"
import MasksIcon from '@mui/icons-material/Masks';
import TuneIcon from '@mui/icons-material/Tune';
import { Preset } from "../../../../state/types/Run";

interface PresetViewProps {
    onPresetSelected: (preset: Preset) => void
    onPresetParamRefinementClicked: () => void
    selectedPreset?: Preset
    maskVideo: () => void
}

const PresetView = (props: PresetViewProps) => {
    return (<>
        <DialogContent sx={{ padding: '20px 32px' }}>
            <PresetSelection
                selectedPreset={props.selectedPreset}
                onPresetSelected={props.onPresetSelected}
            />
        </DialogContent>
        <DialogActions>
            <Button
                startIcon={<TuneIcon />}
                children={props.selectedPreset ? 'Customize Preset' : 'Use Custom Settings'}
                onClick={() => props.onPresetParamRefinementClicked()}
            />
            <Button
                variant={'contained'}
                startIcon={<MasksIcon />}
                onClick={() => props.maskVideo()}
                children={'Mask Video'}
                disabled={!props.selectedPreset}
            />
        </DialogActions>
    </>);
}

export default PresetView
