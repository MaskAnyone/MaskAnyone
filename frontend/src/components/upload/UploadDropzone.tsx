import Dropzone from 'react-dropzone';
import {Box, IconButton, List, ListItem, ListItemText, Paper, Typography} from '@mui/material';
import UploadProgress from './UploadProgress';
import CancelIcon from '@mui/icons-material/Cancel';
import React from 'react';
import {useSelector} from 'react-redux';
import Selector from "../../state/selector";
import {formatFileSize} from "../../util/formatFileSize";
import Config from "../../config";
import Assets from "../../assets/assets";

const styles = {
    dropzoneRoot: {
        height: '350px',
    },
    dropzoneWrapper: {
        width: '100%',
        height: '100%',
        overflow: 'auto',
    },
    dropzoneInfoContainer: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        paddingTop: '24px',
    },
    dropzoneInfo: {
        width: '50%',
        margin: '0 auto',
        paddingTop: '24px',
        textAlign: 'center',
    },
    stagedFilesListItemText: {
        paddingLeft: 2,
    },
};

interface UploadDropzoneProps {
    stagedFiles: Array<{file: File, id: string}>;
    uploadRunning: boolean;
    onSelectFiles: (files: File[]) => void;
    onCancelFile: (fileId: string) => void;
}

const UploadDropzone = (props: UploadDropzoneProps) => {
    const uploadProgress = useSelector(Selector.Upload.uploadProgress);

    const cancelFile = (event: React.MouseEvent, fileId: string): void => {
        event.stopPropagation();
        props.onCancelFile(fileId);
    };

    return (
        <Dropzone onDrop={props.onSelectFiles} maxSize={Config.upload.maxSize} accept={Config.upload.accept}>
            {({getRootProps, getInputProps}) => (
                <Paper variant={'outlined'} square={true} sx={styles.dropzoneRoot}>
                    <div {...getRootProps()} style={styles.dropzoneWrapper}>
                        <input {...getInputProps()} />
                        {props.stagedFiles.length < 1 && (
                            <Box component={'div'} sx={styles.dropzoneInfoContainer}>
                                <img src={Assets.illustrations.upload} alt={'Upload'} width={220} />
                                <Typography sx={styles.dropzoneInfo}>
                                    Drag files here, or click to select files
                                </Typography>
                            </Box>
                        )}
                        {props.stagedFiles.length > 0 && (
                            <List dense={true}>
                                {props.stagedFiles.map(stagedFile => (
                                    <ListItem key={stagedFile.id}>
                                        <UploadProgress value={uploadProgress[stagedFile.id] || 0} />
                                        <ListItemText
                                            sx={styles.stagedFilesListItemText}
                                            primary={stagedFile.file.name}
                                            secondary={formatFileSize(stagedFile.file.size)}
                                        />
                                        <IconButton
                                            onClick={event => cancelFile(event, stagedFile.id)}
                                            disabled={props.uploadRunning}
                                            children={<CancelIcon />}
                                            size="large"
                                        />
                                    </ListItem>
                                ))}
                            </List>
                        )}

                    </div>
                </Paper>
            )}
        </Dropzone>
    );
};

export default UploadDropzone;
