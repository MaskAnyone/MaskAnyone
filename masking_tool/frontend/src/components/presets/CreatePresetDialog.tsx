import {Button, Dialog, DialogActions, DialogContent, DialogTitle, TextField} from "@mui/material";
import {useState} from "react";

const styles = {
    nameInput: {
        marginTop: 1,
    },
    descriptionInput: {
        marginTop: 2,
    },
};

interface CreatePresetDialogProps {
    open: boolean;
    onClose: () => void;
}

const CreatePresetDialog = (props: CreatePresetDialogProps) => {
    const [name, setName] = useState<string|null>(null);
    const [description, setDescription] = useState<string|null>(null);

    return (
        <Dialog open={props.open} onClose={props.onClose} fullWidth={true}>
            <DialogTitle>Create Preset</DialogTitle>
            <DialogContent>
                <TextField
                    fullWidth={true}
                    label={'Name'}
                    sx={styles.nameInput}
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                />
                <TextField
                    label={'Description'}
                    fullWidth={true}
                    multiline={true}
                    minRows={3}
                    maxRows={5}
                    sx={styles.descriptionInput}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                />
            </DialogContent>
            <DialogActions>
                <Button onClick={props.onClose}>Cancel</Button>
                <Button
                    variant={'contained'}
                    onClick={props.onClose}
                    children={'Create Preset'}
                    disabled={!name || !description}
                />
            </DialogActions>
        </Dialog>
    );
};

export default CreatePresetDialog;
