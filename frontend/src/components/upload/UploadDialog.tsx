import {Box, Button, Dialog, DialogActions, DialogContent, DialogTitle} from '@mui/material';
import UploadDropzone from './UploadDropzone';
import {useEffect, useState} from 'react';
import { v4 as uuidv4 } from 'uuid';
import {useDispatch, useSelector} from 'react-redux';
import PublishIcon from '@mui/icons-material/Publish';
import TagBar from './TagBar';
import Selector from "../../state/selector";
import LoaderButton from "./LoaderButton";
import {usePrevious} from "../../util/usePrevious";
import Command from "../../state/actions/command";

const styles = {
    tagBarWrapper: {
        marginBottom: 2,
        paddingTop: 1,
    },
}

interface UploadDialogProps {
    open: boolean;
    onClose: () => void;
}

const UploadDialog = (props: UploadDialogProps) => {
    const dispatch = useDispatch();
    const uploadProgress = useSelector(Selector.Upload.uploadProgress);
    const videoNameList = useSelector(Selector.Video.videoNameList);
    const [stagedFiles, setStagedFiles] = useState<Array<{file: File, id: string}>>([]);
    const [tags, setTags] = useState<string[]>([]);
    const [uploadRunning, setUploadRunning] = useState<boolean>(false);
    const currentUploadCount = Object.keys(uploadProgress).length;
    const previousUploadCount = Object.keys(usePrevious(uploadProgress) || {}).length;

    const handleSelectedFiles = (files: File[]): void => {
        const validNewFiles = files.filter(file => !videoNameList.includes(file.name));

        if (validNewFiles.length < files.length) {
            alert('A file with this name already exists.');
        }

        setStagedFiles([
            ...stagedFiles,
            ...validNewFiles.map(file => ({ file, id: uuidv4() })),
        ]);
    };

    const cancelStagedFile = (fileId: string): void => {
        setStagedFiles(stagedFiles.filter(file => file.id !== fileId));
    };

    const closeDialog = (): void => {
        setStagedFiles([]);
        props.onClose();
    };

    const startFileUpload = (): void => {
        if (stagedFiles.length < 1) {
            return;
        }

        setUploadRunning(true);
        dispatch(Command.Upload.uploadVideos({
            videos: stagedFiles.map(stagedFile => ({ ...stagedFile, tags: [] })),
        }));
    };

    useEffect(() => {
        setStagedFiles([
            ...stagedFiles.filter(stagedFile => Object.keys(uploadProgress).includes(stagedFile.id)),
        ]);

        if (currentUploadCount < 1) {
            props.onClose();
        }
    }, [currentUploadCount < previousUploadCount]);

    useEffect(() => {
        if (!props.open) {
            setStagedFiles([]);
            setUploadRunning(false);
        }
    }, [props.open]);

    return (
        <Dialog open={props.open} onClose={uploadRunning ? undefined : props.onClose} fullWidth={true}>
            <DialogTitle>Upload</DialogTitle>
            <DialogContent>
                <Box component="div" sx={styles.tagBarWrapper}>
                    {/* @todo disabled */}
                    <div style={{ display: 'none' }}><TagBar tags={tags} onChange={setTags} /></div>
                </Box>
                <UploadDropzone
                    stagedFiles={stagedFiles}
                    uploadRunning={uploadRunning}
                    onSelectFiles={handleSelectedFiles}
                    onCancelFile={cancelStagedFile}
                />
            </DialogContent>
            <DialogActions>
                <Button color={'inherit'} onClick={closeDialog}>Cancel</Button>
                <LoaderButton
                    variant={'contained'}
                    onClick={startFileUpload}
                    startIcon={<PublishIcon />}
                    children={'Upload'}
                    loading={uploadRunning}
                />
            </DialogActions>
        </Dialog>
    );
};

export default UploadDialog;
