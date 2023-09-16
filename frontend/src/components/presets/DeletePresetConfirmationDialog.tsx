import {Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle} from "@mui/material";

interface DeletePresetConfirmationDialogProps {
    open: boolean;
    onClose: () => void;
    onDelete: () => void;
}

const DeletePresetConfirmationDialog = (props: DeletePresetConfirmationDialogProps) => {
    return (
        <Dialog open={props.open} onClose={props.onClose}>
            <DialogTitle>Delete preset?</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    Are you sure you want to delete this preset? This action cannot be undone.
                </DialogContentText>
            </DialogContent>
            <DialogActions>
                <Button onClick={props.onClose}>Cancel</Button>
                <Button onClick={props.onDelete} variant={'contained'}>Delete</Button>
            </DialogActions>
        </Dialog>
    );
};

export default DeletePresetConfirmationDialog;
