import {Box, Typography} from "@mui/material";
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import PresetPreview from "../components/presets/PresetPreview";
import {useEffect} from "react";
import Command from "../state/actions/command";

const PresetsPage = () => {
    const dispatch = useDispatch();
    const presetList = useSelector(Selector.Preset.presetList);

    useEffect(() => {
        dispatch(Command.Preset.fetchPresetList({}));
    }, []);

    return (
        <Box component={'div'}>
            <Typography variant={'h3'}>
                My Custom Presets
            </Typography>

            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', marginTop: 2 }}>
                {[...presetList, ...presetList, ...presetList, ...presetList, ...presetList].map(preset => (
                    <Box component={'div'} sx={{ paddingRight: 2, paddingBottom: 2 }}>
                        <PresetPreview key={preset.id} preset={preset} />
                    </Box>
                ))}
            </Box>
        </Box>
    );
};

export default PresetsPage;
