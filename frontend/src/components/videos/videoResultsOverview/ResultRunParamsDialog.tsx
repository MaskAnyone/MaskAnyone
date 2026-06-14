import { Button, Dialog, DialogActions, DialogContent, DialogTitle } from "@mui/material";
import { ResultVideo } from "../../../state/types/ResultVideo";
import Selector from "../../../state/selector";
import { useSelector } from "react-redux";
import { ReduxState } from "../../../state/reducer";

interface ResultRunParamsDialogProps {
    open: boolean;
    onClose: () => void;
    result?: ResultVideo
}

const ResultRunParamsDialog = (props: ResultRunParamsDialogProps) => {
    const selectJobById = Selector.Job.makeSelectJobById();
    const job = useSelector((state: ReduxState) => selectJobById(state, props.result?.jobId || ''));

    return (
        <>
            {props.result && <Dialog open={props.open} onClose={props.onClose} fullWidth={true}>
                <DialogTitle>Run Paramters for {props.result.name}</DialogTitle>
                <DialogContent>
                    <pre>{JSON.stringify(job?.data, null, 2)}</pre>
                </DialogContent>
                <DialogActions>
                    <Button onClick={props.onClose}>Cancel</Button>
                </DialogActions>
            </Dialog>}
        </>
    );
};

export default ResultRunParamsDialog;
