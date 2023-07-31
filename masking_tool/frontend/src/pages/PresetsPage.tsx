import { Box } from "@mui/material";
import {useSelector} from "react-redux";
import Selector from "../state/selector";

const PresetsPage = () => {
    const presetList = useSelector(Selector.Preset.presetList);

    return (
        <Box component="div">
            {JSON.stringify(presetList)}
        </Box>
    );
};

export default PresetsPage;
