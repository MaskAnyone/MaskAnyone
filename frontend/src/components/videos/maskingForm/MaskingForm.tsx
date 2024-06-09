import { useState } from "react";
import { useDispatch } from "react-redux";
import { v4 as uuidv4 } from 'uuid';
import { RunParams } from "../../../state/types/Run";
import Command from "../../../state/actions/command";
import CustomSettingsContainer from "./customSettings/CustomSettingsContainer";

interface MaskingFormProps {
    videoIds: string[];
    onClose: () => void;
}

const initialRunParams: RunParams = {
    videoMasking: {
        strategy: 'blurring',
        options: {
            level: 3,
            skeleton: true,
            averageColor: true,
            color: '#000000',
        }
    },
    voiceMasking: {
        strategy: 'preserve',
    },
};

const MaskingForm = (props: MaskingFormProps) => {
    const dispatch = useDispatch();
    const [runParams, setRunParams] = useState<RunParams>(initialRunParams);

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

    return (
        <CustomSettingsContainer
            onParamsChange={setRunParams}
            onRunClicked={maskVideo}
            runParams={runParams}
        />
    );
}

export default MaskingForm
