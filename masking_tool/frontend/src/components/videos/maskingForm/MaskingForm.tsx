import { useState } from "react";
import { useDispatch } from "react-redux";
import { v4 as uuidv4 } from 'uuid';
import PresetView from "./presets/PresetView";
import { Preset, RunParams } from "../../../state/types/Run";
import Command from "../../../state/actions/command";
import CustomSettingsContainer from "./customSettings/CustomSettingsContainer";

interface MaskingFormProps {
    videoIds: string[];
    onClose: () => void;
}

const initialRunParams: RunParams = {
    videoMasking: {
        hidingTarget: "none",
        hidingStrategyTarget: {
            key: "none",
            params: {}
        },
        hidingStrategyBG: {
            key: "none",
            params: {}
        },
        maskingStrategy: {
            key: "none",
            params: {}
        }
    },
    threeDModelCreation: {
        skeleton: false,
        skeletonParams: {},
        blender: false,
        blenderParams: {},
        blendshapes: false,
        blendshapesParams: {}
    },
    voiceMasking: {
        maskingStrategy: {
            key: 'preserve',
            params: {},
        },
    },
}

const MaskingForm = (props: MaskingFormProps) => {
    const dispatch = useDispatch();
    const [presetView, setPresetView] = useState(true)
    const [runParams, setRunParams] = useState<RunParams>(initialRunParams)
    const [selectedPreset, setSelectedPreset] = useState<Preset>()

    const handlePresetSelected = (preset: Preset) => {
        setRunParams(preset.runParams)
        setSelectedPreset(preset)
    }

    const handlePresetParamRefinementClicked = () => {
        setPresetView(false)
    }

    const maskVideo = () => {
        if (!props.videoIds) {
            return;
        }

        dispatch(Command.Video.maskVideo({
            id: uuidv4(),
            videoIds: props.videoIds,
            resultVideoId: uuidv4(),
            runData: runParams,
        }));

        props.onClose();
    };

    return presetView ? (
        <PresetView
            onPresetSelected={handlePresetSelected}
            onPresetParamRefinementClicked={handlePresetParamRefinementClicked}
            maskVideo={maskVideo}
            selectedPreset={selectedPreset}
        />
    ) : (
        <CustomSettingsContainer
            onBackClicked={() => setPresetView(true)}
            onParamsChange={setRunParams}
            onRunClicked={maskVideo}
            runParams={runParams}
        />
    );
}

export default MaskingForm
