import {Button, DialogActions, DialogContent} from "@mui/material"
import PresetSelection from "./PresetSelection"
import TuneIcon from '@mui/icons-material/Tune';
import {Preset, RunParams} from "../../../../state/types/Run";
import ShieldLogoIcon from "../../../common/ShieldLogoIcon";

const styles = {
    dialogActions: {
        paddingBottom: 2,
        paddingRight: 3,
    },
};

interface PresetViewProps {
    onPresetSelected: (presetId: string, runParams: RunParams) => void;
    onPresetParamRefinementClicked: () => void
    selectedPresetId?: string;
    maskVideo: () => void
}

const PresetView = (props: PresetViewProps) => {
    return (<>
        <DialogContent sx={{ padding: '20px 32px' }}>
            <PresetSelection
                selectedPresetId={props.selectedPresetId}
                onPresetSelected={props.onPresetSelected}
            />
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button
                startIcon={<TuneIcon />}
                children={props.selectedPresetId ? 'Customize Preset' : 'Use Custom Settings'}
                onClick={() => setTimeout(() => props.onPresetParamRefinementClicked(), 150)}
            />
            <Button
                variant={'contained'}
                startIcon={<ShieldLogoIcon color={props.selectedPresetId ? undefined : 'rgba(0, 0, 0, 0.26)'} />}
                onClick={() => props.maskVideo()}
                children={'Mask Video'}
                disabled={!props.selectedPresetId}
            />
        </DialogActions>
    </>);
}

export default PresetView
