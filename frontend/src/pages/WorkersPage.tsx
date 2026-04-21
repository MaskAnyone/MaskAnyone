import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import {Alert, Box, Chip, Grid, Tooltip} from "@mui/material";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import {Link} from "react-router-dom";
import Paths from "../paths";
import Command from "../state/actions/command";
import {useEffect, useState} from "react";
import Config from "../config";
import KeycloakAuth from "../keycloakAuth";

interface WorkerRecommendation {
    current: number;
    recommended: number;
    max: number;
    basis: { cpu_count: number; ram_gb: number; vram_gb: number };
    note: string;
}

const WorkersPage = () => {
    const dispatch = useDispatch();
    const workers = useSelector(Selector.Worker.workerList);
    const [reco, setReco] = useState<WorkerRecommendation | null>(null);

    useEffect(() => {
        dispatch(Command.Worker.fetchWorkerList({}));
        // Fetch the hardware-based recommendation. Endpoint is JWT-gated.
        fetch(`${Config.api.baseUrl}/workers/recommendation`, {
            headers: KeycloakAuth.getToken() ? { Authorization: `Bearer ${KeycloakAuth.getToken()}` } : {},
        })
            .then(r => r.ok ? r.json() : null)
            .then((data: WorkerRecommendation | null) => setReco(data))
            .catch(() => setReco(null));
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    return (
        <Box component={'div'}>
            {reco && (
                <Paper sx={{ p: 2, mb: 2 }}>
                    <Typography variant="h6" gutterBottom>Scale workers</Typography>
                    <Typography variant="body2" sx={{ mb: 1 }}>
                        <strong>Running:</strong> {reco.current} worker{reco.current === 1 ? '' : 's'}.
                        {' '}<strong>Recommended for your hardware:</strong> {reco.recommended}.
                        {' '}<strong>Practical maximum:</strong> {reco.max}.
                    </Typography>
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
                        Detected: {reco.basis.cpu_count} cores · {reco.basis.ram_gb} GB RAM
                        {reco.basis.vram_gb > 0 ? ` · ${reco.basis.vram_gb} GB VRAM` : ''}
                    </Typography>
                    {reco.current < reco.recommended && (
                        <Alert severity="info" sx={{ mb: 1 }}>
                            You could add {reco.recommended - reco.current} more worker
                            {reco.recommended - reco.current === 1 ? '' : 's'}. Run this from your project directory:
                            <Box component="pre" sx={{ fontFamily: 'monospace', fontSize: '0.8rem', mt: 1, mb: 0, p: 1, bgcolor: 'action.hover', borderRadius: 1 }}>
                                docker compose up -d --scale worker={reco.recommended}
                            </Box>
                        </Alert>
                    )}
                    <Tooltip title="Why: SAM2 and OpenPose each hold a single GPU model and serialize requests. Extra workers help when multiple jobs are queued — one can render (CPU) while another segments (GPU)." placement="bottom-start">
                        <Typography variant="caption" color="text.secondary" sx={{ cursor: 'help', borderBottom: '1px dotted', display: 'inline-block' }}>
                            Why diminishing returns past {reco.max}?
                        </Typography>
                    </Tooltip>
                </Paper>
            )}
            <Grid container spacing={2}>
                {workers.map((worker, index) => (
                    <Grid item xs={12} sm={6} md={4} lg={3} key={worker.id}>
                        <Paper sx={{ p: 2 }}>
                            <div style={{ position: 'relative' }}>
                                {worker.jobId ? (
                                    <Link to={Paths.runs}>
                                        <Chip
                                            label="Working"
                                            color="primary"
                                            size="small"
                                            sx={{
                                                position: 'absolute',
                                                top: 2,
                                                right: 2,
                                                zIndex: 1,
                                                cursor: 'pointer',
                                            }}
                                        />
                                    </Link>
                                ) : (
                                    <Chip
                                        label="Idle"
                                        color="default"
                                        size="small"
                                        sx={{
                                            position: 'absolute',
                                            top: 2,
                                            right: 2,
                                            zIndex: 1,
                                        }}
                                    />
                                )}
                                <Typography variant="h6" gutterBottom>
                                    Worker #{index + 1}
                                </Typography>
                            </div>
                            <Typography variant="body2" color="textSecondary">
                                Type: {worker.type}
                            </Typography>
                            <Typography variant="body2" color="textSecondary">
                                Last Activity: {formatRelativeTime(worker.lastActivity)}
                            </Typography>
                        </Paper>
                    </Grid>
                ))}
            </Grid>
        </Box>
    );
};

// Helper function to format the last activity timestamp in a relative way
const formatRelativeTime = (lastActivity: any) => {
    const userTimezoneOffset = new Date().getTimezoneOffset() * 60 * 1000;
    const activityTime = new Date(lastActivity);
    const now = new Date();
    // @ts-ignore
    const diff = now - activityTime + userTimezoneOffset;

    if (diff < 1000) {
        return 'Just now';
    } else if (diff < 60000) {
        const seconds = Math.floor(diff / 1000);
        return `${seconds} second${seconds !== 1 ? 's' : ''} ago`;
    } else if (diff < 3600000) {
        const minutes = Math.floor(diff / 60000);
        return `${minutes} minute${minutes !== 1 ? 's' : ''} ago`;
    } else if (diff < 86400000) {
        const hours = Math.floor(diff / 3600000);
        return `${hours} hour${hours !== 1 ? 's' : ''} ago`;
    } else {
        return activityTime.toLocaleString();
    }
};

export default WorkersPage;
