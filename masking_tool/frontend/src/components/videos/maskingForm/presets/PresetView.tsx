import {Button, DialogActions, DialogContent} from "@mui/material"
import PresetSelection from "./PresetSelection"
import TuneIcon from '@mui/icons-material/Tune';
import { Preset } from "../../../../state/types/Run";
import ShieldLogoIcon from "../../../common/ShieldLogoIcon";

const styles = {
    dialogActions: {
        paddingBottom: 2,
        paddingRight: 3,
    },
};

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
        <DialogActions sx={styles.dialogActions}>
            <Button
                startIcon={<TuneIcon />}
                children={props.selectedPreset ? 'Customize Preset' : 'Use Custom Settings'}
                onClick={() => setTimeout(() => props.onPresetParamRefinementClicked(), 150)}
            />
            <Button
                variant={'contained'}
                startIcon={<ShieldLogoIcon color={props.selectedPreset ? undefined : 'rgba(0, 0, 0, 0.26)'} />}
                onClick={() => props.maskVideo()}
                children={'Mask Video'}
                disabled={!props.selectedPreset}
            />
        </DialogActions>
    </>);
}

export default PresetView
