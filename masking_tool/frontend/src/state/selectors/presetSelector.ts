import {ReduxState} from "../reducer";
import {Preset} from "../types/Preset";

const presetList = (state: ReduxState): Preset[] => state.preset.presetList;

const PresetSelector = {
    presetList,
};

export default PresetSelector;
