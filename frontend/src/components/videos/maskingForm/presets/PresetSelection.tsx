import { Typography } from "@mui/material";
import { Box } from "@mui/system";
import { useState } from "react";
import { RunParams, Preset } from "../../../../state/types/Run";
import { presetsDB } from "../../../../util/presets"
import SelectableCard from "../../../common/SelectableCard";
import {useSelector} from "react-redux";
import Selector from "../../../../state/selector";
import Config from "../../../../config";
import {Preset as CustomPreset} from "../../../../state/types/Preset";
import {asFrontendRunParams} from "../../../../api/helpers";

const styles = {
    presetList: {
        overflowX: 'auto',
        whiteSpace: 'nowrap',
        padding: '12px 6px',
        margin: '0 -6px',
    },
};

interface PresetSelectionProps {
    onPresetSelected: (presetId: string, runParams: RunParams) => void;
    selectedPresetId?: string;
}

const PresetSelection = (props: PresetSelectionProps) => {
    const customPresets = useSelector(Selector.Preset.presetList);
    const [presets, setPresets] = useState(presetsDB)

    const onPresetClicked = (preset: Preset) => {
        props.onPresetSelected(preset.id, preset.runParams);
    };

    const onCustomPresetClicked = (preset: CustomPreset) => {
        props.onPresetSelected(preset.id, asFrontendRunParams(preset.data));
    };

    return (
        <Box component={'div'}>
            <Box component={'div'} sx={{ marginBottom: 2 }}>
                <Typography variant="h6">
                    Predefined Presets
                </Typography >
                <Typography variant={'body2'}>
                    Please choose one of our predefined presets or click "Use Custom Settings" to configure your own.
                </Typography>
            </Box>
            <Box component={'div'} sx={styles.presetList}>
                {presets.map((preset, index) => (
                    <SelectableCard
                        key={preset.name}
                        title={preset.name}
                        selected={props.selectedPresetId === preset.id}
                        imagePath={preset.previewImagePath || ''}
                        description={preset.detailText || ''}
                        onSelect={() => onPresetClicked(preset)}
                        style={index === presets.length - 1 ? undefined : { marginRight: '23.5px' }}
                    />
                ))}
            </Box>

            {Boolean(customPresets.length) && (<>
                <Box component={'div'} sx={{ marginTop: 3.5, marginBottom: 0 }}>
                    <Typography variant="h6">
                        My Custom Presets
                    </Typography >
                </Box>
                <Box component={'div'} sx={styles.presetList}>
                    {customPresets.map((preset, index) => (
                        <SelectableCard
                            key={preset.id}
                            title={preset.name}
                            selected={props.selectedPresetId === preset.id}
                            description={preset.description}
                            imagePath={`${Config.api.baseUrl}/presets/${preset.id}/preview`}
                            onSelect={() => onCustomPresetClicked(preset)}
                            style={index === customPresets.length - 1 ? undefined : { marginRight: '23.5px' }}
                        />
                    ))}
                </Box>
            </>)}

        </Box>
    )
}

export default PresetSelection
