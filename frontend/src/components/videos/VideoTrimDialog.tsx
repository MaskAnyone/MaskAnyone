import React, { useEffect, useState } from "react";
import {
    Box,
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    LinearProgress,
    Slider,
    TextField,
    Typography,
} from "@mui/material";
import ContentCutIcon from '@mui/icons-material/ContentCut';
import { useDispatch, useSelector } from "react-redux";
import { v4 as uuidv4 } from "uuid";
import Command from "../../state/actions/command";
import Selector from "../../state/selector";
import Config from "../../config";
import KeycloakAuth from "../../keycloakAuth";

const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    const ms = Math.round((seconds % 1) * 10);
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}.${ms}`;
};

interface VideoTrimDialogProps {
    open: boolean;
    onClose: () => void;
    videoId: string;
    videoName: string;
    videoDuration: number;
}

const VideoTrimDialog = (props: VideoTrimDialogProps) => {
    const dispatch = useDispatch();
    const trimStatus = useSelector(Selector.Video.trimStatus);
    const trimInitiated = React.useRef(false);

    const [range, setRange] = useState<[number, number]>([0, props.videoDuration]);
    const [newName, setNewName] = useState<string>(`${props.videoName} (trimmed)`);

    useEffect(() => {
        if (props.open) {
            trimInitiated.current = false;
            setRange([0, props.videoDuration]);
            setNewName(`${props.videoName} (trimmed)`);
        }
    }, [props.open, props.videoDuration, props.videoName]);

    useEffect(() => {
        if (trimStatus === 'done' && props.open && trimInitiated.current) {
            props.onClose();
        }
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [trimStatus, props.open, props.onClose]);

    const handleRangeChange = (_event: Event, newValue: number | number[]) => {
        setRange(newValue as [number, number]);
    };

    const handleTrim = () => {
        trimInitiated.current = true;
        const newVideoId = uuidv4();
        dispatch(Command.Video.trimVideo({
            videoId: props.videoId,
            newVideoId,
            newVideoName: newName,
            startTime: range[0],
            endTime: range[1],
        }));
    };

    const clipDuration = range[1] - range[0];
    const isTrimming = trimStatus === 'trimming';

    return (
        <Dialog open={props.open} onClose={props.onClose} maxWidth="sm" fullWidth>
            <DialogTitle>Trim Video</DialogTitle>
            <DialogContent>
                <Box component="div" sx={{ mt: 1 }}>
                    <Box
                        component="video"
                        src={`${Config.api.baseUrl}/videos/${props.videoId}?token=${KeycloakAuth.getToken()}`}
                        controls
                        sx={{ width: '100%', borderRadius: 0, border: 1, borderColor: 'divider' }}
                    />
                </Box>

                <Box component="div" sx={{ px: 1, mt: 2 }}>
                    <Slider
                        value={range}
                        onChange={handleRangeChange}
                        min={0}
                        max={props.videoDuration}
                        step={0.1}
                        valueLabelDisplay="auto"
                        valueLabelFormat={formatTime}
                        disabled={isTrimming}
                        disableSwap
                    />
                </Box>

                <Box component="div" sx={{ display: 'flex', justifyContent: 'space-between', mt: 1 }}>
                    <Typography variant="body2" sx={{ fontFamily: '"IBM Plex Mono", monospace' }}>
                        Start: {formatTime(range[0])}
                    </Typography>
                    <Typography variant="body2" sx={{ fontFamily: '"IBM Plex Mono", monospace' }}>
                        Duration: {formatTime(clipDuration)}
                    </Typography>
                    <Typography variant="body2" sx={{ fontFamily: '"IBM Plex Mono", monospace' }}>
                        End: {formatTime(range[1])}
                    </Typography>
                </Box>

                <TextField
                    label="New video name"
                    value={newName}
                    onChange={(e) => setNewName(e.target.value)}
                    fullWidth
                    size="small"
                    sx={{ mt: 2 }}
                    disabled={isTrimming}
                />

                {isTrimming && (
                    <LinearProgress sx={{ mt: 2 }} />
                )}
            </DialogContent>
            <DialogActions>
                <Button onClick={props.onClose} disabled={isTrimming}>
                    Cancel
                </Button>
                <Button
                    onClick={handleTrim}
                    variant="contained"
                    color="secondary"
                    disabled={isTrimming || clipDuration < 0.5 || !newName.trim()}
                    startIcon={<ContentCutIcon />}
                >
                    {isTrimming ? 'Trimming...' : 'Trim'}
                </Button>
            </DialogActions>
        </Dialog>
    );
};

export default VideoTrimDialog;
