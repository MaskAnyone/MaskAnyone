import { Button, Dialog, DialogActions, DialogContent, DialogTitle, TextField } from "@mui/material";
import { useState } from "react";
import { ResultVideo } from "../../../state/types/ResultVideo";

interface ResultRunParamsDialogProps {
    open: boolean;
    onClose: () => void;
    result?: ResultVideo
}

const ResultRunParamsDialog = (props: ResultRunParamsDialogProps) => {
    const [name, setName] = useState<string | null>(null);
    const [description, setDescription] = useState<string | null>(null);

    return (
        <>
            {props.result && <Dialog open={props.open} onClose={props.onClose} fullWidth={true}>
                <DialogTitle>Run Paramters for {props.result.name}</DialogTitle>
                <DialogContent>
                    <pre>{JSON.stringify(props.result.jobInfo, null, 2)}</pre>
                </DialogContent>
                <DialogActions>
                    <Button onClick={props.onClose}>Cancel</Button>
                </DialogActions>
            </Dialog>}
        </>
    );
};

export default ResultRunParamsDialog;
