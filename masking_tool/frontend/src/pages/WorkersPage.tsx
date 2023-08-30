import {useSelector} from "react-redux";
import Selector from "../state/selector";
import {Box, Chip, Grid} from "@mui/material";
import Paper from "@mui/material/Paper";
import Typography from "@mui/material/Typography";
import {Link} from "react-router-dom";
import Paths from "../paths";

const WorkersPage = () => {
    const workers = useSelector(Selector.Worker.workerList);

    return (
        <Box component={'div'}>
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
