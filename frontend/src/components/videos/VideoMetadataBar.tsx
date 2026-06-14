import {useState, useCallback} from "react";
import {Alert, Box, Button, Collapse, IconButton, LinearProgress, Typography} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import SpeedIcon from "@mui/icons-material/Speed";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import {Video} from "../../state/types/Video";
import {useDispatch} from "react-redux";
import {v4 as uuidv4} from "uuid";
import Api from "../../api";
import Command from "../../state/actions/command";

interface Recommendation {
    id: string;
    icon: string;
    text: string;
    action?: {
        label: string;
        onClick: () => void;
    };
}

const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    if (mins >= 60) {
        const hours = Math.floor(mins / 60);
        const remainMins = mins % 60;
        return `${hours}h ${remainMins}m`;
    }
    return mins > 0 ? `${mins}m ${secs}s` : `${secs}s`;
};

const formatResolution = (width: number, height: number): string => {
    if (height >= 2160) return '4K';
    if (height >= 1440) return '1440p';
    if (height >= 1080) return '1080p';
    if (height >= 720) return '720p';
    if (height >= 480) return '480p';
    return `${width}x${height}`;
};

const estimateProcessingTime = (frameCount: number, fps: number): string | null => {
    // Rough heuristic: SAM2 processes ~3 frames/sec on mid-range GPU
    // At 30fps source, this means ~10x slower than realtime
    const effectiveFrames = fps > 30 ? frameCount * (30 / fps) : frameCount;
    const estimatedSeconds = effectiveFrames / 3;

    if (estimatedSeconds < 30) return null; // not worth mentioning
    return formatDuration(estimatedSeconds);
};

interface ConversionState {
    status: 'idle' | 'converting' | 'complete' | 'error';
    progress: number;
    newVideoId: string | null;
}

interface VideoMetadataBarProps {
    video: Video;
}

const VideoMetadataBar = ({video}: VideoMetadataBarProps) => {
    const dispatch = useDispatch();
    const [dismissed, setDismissed] = useState(false);
    const [conversion, setConversion] = useState<ConversionState>({
        status: 'idle',
        progress: 0,
        newVideoId: null,
    });
    const info = video.videoInfo;

    const startFpsConversion = useCallback(async () => {
        const newVideoId = uuidv4();
        const newVideoName = `${video.name} (30fps)`;

        setConversion({status: 'converting', progress: 0, newVideoId});

        try {
            // Backend endpoint is synchronous - blocks until conversion is done
            await Api.convertVideoFps(video.id, newVideoId, newVideoName, 30);

            setConversion(prev => ({...prev, status: 'complete', progress: 100}));
            dispatch(Command.Video.fetchVideoList({}));
            dispatch(Command.Notification.enqueueNotification({
                severity: 'success',
                message: 'Video converted to 30fps successfully',
            }));
        } catch (err) {
            setConversion(prev => ({...prev, status: 'error'}));
            dispatch(Command.Notification.enqueueNotification({
                severity: 'error',
                message: 'Failed to convert video frame rate',
            }));
        }
    }, [video.id, video.name, dispatch]);

    const getRecommendations = useCallback((): Recommendation[] => {
        const recs: Recommendation[] = [];

        if (info.fps > 30 && conversion.status === 'idle') {
            const speedup = Math.round(info.fps / 30);
            recs.push({
                id: 'high-fps',
                icon: '\u26A1',
                text: `${Math.round(info.fps)}fps detected \u2014 convert to 30fps for ${speedup}x faster processing`,
                action: {
                    label: 'Convert',
                    onClick: startFpsConversion,
                },
            });
        }

        if (info.fps < 15) {
            recs.push({
                id: 'low-fps',
                icon: '\u26A0\uFE0F',
                text: `Low frame rate (${Math.round(info.fps)}fps) \u2014 masking may show temporal flicker`,
            });
        }

        if (info.frameHeight >= 2160 || info.frameWidth >= 3840) {
            recs.push({
                id: 'high-res',
                icon: '\uD83D\uDCD0',
                text: `${formatResolution(info.frameWidth, info.frameHeight)} \u2014 consider downscaling to 1080p`,
            });
        }

        if (info.frameHeight < 480 && info.frameWidth < 640) {
            recs.push({
                id: 'low-res',
                icon: '\uD83D\uDCD0',
                text: 'Low resolution \u2014 subject detection may be less accurate',
            });
        }

        if (info.duration > 300) {
            recs.push({
                id: 'long-video',
                icon: '\u23F1\uFE0F',
                text: `${formatDuration(info.duration)} long \u2014 consider trimming first`,
            });
        }

        const estimate = estimateProcessingTime(info.frameCount, info.fps);
        if (estimate) {
            // Compact format: show frames in K/M for readability
            const frameLabel = info.frameCount >= 1000000
                ? `${(info.frameCount / 1000000).toFixed(1)}M frames`
                : info.frameCount >= 1000
                    ? `${(info.frameCount / 1000).toFixed(1)}K frames`
                    : `${info.frameCount} frames`;
            recs.push({
                id: 'estimate',
                icon: '\uD83D\uDD52',
                text: `Est. ~${estimate} (${frameLabel})`,
            });
        }

        return recs;
    }, [info, conversion.status, startFpsConversion]);

    const recommendations = getRecommendations();

    const specLine = [
        formatResolution(info.frameWidth, info.frameHeight),
        `${Math.round(info.fps)}fps`,
        formatDuration(info.duration),
        info.codec.toUpperCase(),
    ].join(' \u00B7 ');

    const showRecommendations = recommendations.length > 0 || conversion.status === 'converting';

    return (
        <Box component="div" sx={{mb: 1}}>
            <Typography
                variant="caption"
                color="text.secondary"
                sx={{fontFamily: '"IBM Plex Mono", monospace', fontSize: '0.75rem'}}
            >
                {specLine}
            </Typography>

            {showRecommendations && (
                <Collapse in={!dismissed || conversion.status === 'converting'}>
                    <Alert
                        severity={conversion.status === 'complete' ? 'success' : 'info'}
                        variant="outlined"
                        sx={{mt: 0.5, py: 0, '& .MuiAlert-message': {py: 0.5, width: '100%'}}}
                        icon={conversion.status === 'converting' ? <SpeedIcon /> : undefined}
                        action={conversion.status !== 'converting' ? (
                            <IconButton
                                aria-label="Dismiss recommendations"
                                size="small"
                                onClick={() => setDismissed(true)}
                            >
                                <CloseIcon fontSize="small" />
                            </IconButton>
                        ) : undefined}
                    >
                        {conversion.status === 'converting' && (
                            <Box component="div" sx={{width: '100%', pr: 2}}>
                                <Typography variant="caption" component="div" sx={{py: 0.25, display: 'flex', alignItems: 'center', gap: 1}}>
                                    Converting to 30fps...
                                </Typography>
                                <LinearProgress
                                    variant="indeterminate"
                                    sx={{height: 4, borderRadius: 2, mt: 0.5}}
                                />
                            </Box>
                        )}
                        {conversion.status === 'complete' && (
                            <Typography variant="caption" component="div" sx={{py: 0.25, display: 'flex', alignItems: 'center', gap: 0.5}}>
                                <CheckCircleIcon sx={{fontSize: 14}} /> Conversion complete! New video added to library.
                            </Typography>
                        )}
                        {conversion.status === 'idle' && recommendations.map((rec) => (
                            <Box key={rec.id} component="div" sx={{
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'space-between',
                                py: 0.25,
                                minHeight: 24,
                            }}>
                                <Typography
                                    variant="caption"
                                    component="span"
                                    sx={{
                                        whiteSpace: 'nowrap',
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                        flex: 1,
                                        minWidth: 0,
                                    }}
                                >
                                    {rec.icon} {rec.text}
                                </Typography>
                                {rec.action && (
                                    <Button
                                        size="small"
                                        variant="text"
                                        onClick={rec.action.onClick}
                                        sx={{ml: 1, minWidth: 'auto', py: 0, fontSize: '0.7rem', flexShrink: 0}}
                                        startIcon={<SpeedIcon sx={{fontSize: '14px !important'}} />}
                                    >
                                        {rec.action.label}
                                    </Button>
                                )}
                            </Box>
                        ))}
                    </Alert>
                </Collapse>
            )}
        </Box>
    );
};

export default VideoMetadataBar;
