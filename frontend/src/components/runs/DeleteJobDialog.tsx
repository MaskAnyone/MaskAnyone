import { Button, Dialog, DialogActions, DialogContent, DialogTitle } from "@mui/material";

interface DeleteJobDialogProps {
    open: boolean;
    onCancel: () => void;
    onConfirm: () => void;
}

const DeleteJobDialog = (props: DeleteJobDialogProps) => {
    return (
        <Dialog open={props.open} onClose={props.onCancel} fullWidth={true}>
            <DialogTitle>Delete Job</DialogTitle>
            <DialogContent>
                Please confirm that you really want to delete this job. This cannot be undone.
                Also note that this will not terminate the processing of a running job.
            </DialogContent>
            <DialogActions>
                <Button onClick={props.onCancel}>Cancel</Button>
                <Button variant={'contained'} onClick={props.onConfirm}>Delete</Button>
            </DialogActions>
        </Dialog>
    );
};

export default DeleteJobDialog;
