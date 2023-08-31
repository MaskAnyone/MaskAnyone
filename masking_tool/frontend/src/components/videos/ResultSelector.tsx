import {FormControl, FormControlLabel, Radio, RadioGroup} from "@mui/material";
import {ResultVideo} from "../../state/types/ResultVideo";

export enum ResultViews {
    video = "video",
    blendshapes3D = "blendshapes3D",
    skeleton3D = "skeleton3D"
}

interface ResultSelectorProps {
    resultVideo?: ResultVideo;
    value: ResultViews;
    onValueChange: (newValue: ResultViews) => void;
}

const ResultSelector = (props: ResultSelectorProps) => {
    return (
        <FormControl>
            <RadioGroup row value={props.value} onChange={(e, v) => props.onValueChange(ResultViews[v as keyof typeof ResultViews])}>
                {Boolean(props.resultVideo?.videoResultExists) && <FormControlLabel value={ResultViews.video} control={<Radio />} label="Show Masked Video" />}
                {Boolean(props.resultVideo?.kinematicResultsExists) && <FormControlLabel value={ResultViews.skeleton3D} control={<Radio />} label="Show 3D Skeleton" />}
                {Boolean(props.resultVideo?.blendshapeResultsExists) && <FormControlLabel value={ResultViews.blendshapes3D} control={<Radio />} label="Show animated 3D Face" />}
            </RadioGroup>
        </FormControl>
    );
};

export default ResultSelector;
