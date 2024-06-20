import { Button, Dialog, DialogActions, DialogContent, DialogTitle } from "@mui/material";

interface DeleteResultVideoDialogProps {
    open: boolean;
    onCancel: () => void;
    onConfirm: () => void;
}

const DeleteResultVideoDialog = (props: DeleteResultVideoDialogProps) => {
    return (
        <Dialog open={props.open} onClose={props.onCancel} fullWidth={true}>
            <DialogTitle>Delete Job</DialogTitle>
            <DialogContent>
                Please confirm that you really want to delete this result video. This cannot be undone.
            </DialogContent>
            <DialogActions>
                <Button onClick={props.onCancel}>Cancel</Button>
                <Button variant={'contained'} onClick={props.onConfirm}>Delete</Button>
            </DialogActions>
        </Dialog>
    );
};

export default DeleteResultVideoDialog;
