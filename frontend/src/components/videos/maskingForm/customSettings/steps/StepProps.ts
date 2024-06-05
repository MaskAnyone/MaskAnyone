import {RunParams} from "../../../../../state/types/Run";

export interface StepProps {
    runParams: RunParams,
    onParamsChange: (runParams: RunParams) => void
}
