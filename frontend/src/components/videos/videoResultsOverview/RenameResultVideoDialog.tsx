import { Button, Dialog, DialogActions, DialogContent, DialogTitle, TextField } from "@mui/material";
import React, { useEffect, useState } from "react";

// Keep in sync with MAX_RESULT_NAME_LENGTH in backend/routers/results_router.py.
const MAX_NAME_LENGTH = 120;

interface RenameResultVideoDialogProps {
    open: boolean;
    currentName: string;
    onCancel: () => void;
    // Resolves when renamed; rejects with a message to show in the dialog.
    onConfirm: (newName: string) => Promise<void>;
}

const RenameResultVideoDialog = (props: RenameResultVideoDialogProps) => {
    const [name, setName] = useState<string>(props.currentName);
    const [error, setError] = useState<string | null>(null);
    const [saving, setSaving] = useState<boolean>(false);

    useEffect(() => {
        if (props.open) {
            setName(props.currentName);
            setError(null);
            setSaving(false);
        }
    }, [props.open, props.currentName]);

    const trimmed = name.trim();
    const unchanged = trimmed === props.currentName;
    const tooLong = trimmed.length > MAX_NAME_LENGTH;

    const submit = async (event?: React.FormEvent) => {
        event?.preventDefault();
        if (!trimmed || unchanged || tooLong || saving) {
            return;
        }
        setSaving(true);
        try {
            await props.onConfirm(trimmed);
        } catch (e) {
            setError(e instanceof Error ? e.message : 'Could not rename the result.');
            setSaving(false);
        }
    };

    return (
        <Dialog open={props.open} onClose={props.onCancel} fullWidth={true}>
            <form onSubmit={submit}>
                <DialogTitle>Rename result</DialogTitle>
                <DialogContent>
                    <TextField
                        autoFocus
                        fullWidth
                        margin="dense"
                        label="Name"
                        value={name}
                        onChange={(e) => { setName(e.target.value); setError(null); }}
                        error={Boolean(error) || tooLong}
                        helperText={error || (tooLong ? `At most ${MAX_NAME_LENGTH} characters` : 'Download file names use this name too.')}
                    />
                </DialogContent>
                <DialogActions>
                    <Button onClick={props.onCancel}>Cancel</Button>
                    <Button type="submit" variant={'contained'} disabled={!trimmed || unchanged || tooLong || saving}>Rename</Button>
                </DialogActions>
            </form>
        </Dialog>
    );
};

export default RenameResultVideoDialog;
