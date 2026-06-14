import * as React from 'react';
import Box from '@mui/material/Box';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import TableSortLabel from '@mui/material/TableSortLabel';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import { visuallyHidden } from '@mui/utils';
import {Chip, IconButton, keyframes, LinearProgress, Link as MuiLink, Tooltip} from '@mui/material';
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import {Job} from "../state/types/Job";
import {Link} from "react-router-dom";
import Paths from "../paths";
import DeleteIcon from '@mui/icons-material/Delete';
import CancelIcon from '@mui/icons-material/Cancel';
import DeleteJobDialog from "../components/runs/DeleteJobDialog";
import Command from "../state/actions/command";

const statusColors: { [status: string]: "default"|"info"|"success"|"error"|"warning" } = {
    'open': 'default',
    'running': 'info',
    'finished': 'success',
    'failed': 'error',
};

const jobTypeLabels: Record<string, string> = {
    'basic_masking': 'Basic Masking',
    'sam2_masking': 'SAM2 Masking',
};

const formatDuration = (ms: number): string => {
    const totalSeconds = Math.floor(ms / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
        return `${hours}h ${minutes}m ${seconds}s`;
    }
    if (minutes > 0) {
        return `${minutes}m ${seconds}s`;
    }
    return `${seconds}s`;
};

const getElapsedMs = (job: Job): number | null => {
    if (!job.startedAt) return null;
    const end = job.finishedAt ?? new Date();
    return end.getTime() - job.startedAt.getTime();
};

const getEstimatedRemainingMs = (job: Job): number | null => {
    if (job.status !== 'running' || !job.startedAt || job.progress <= 0) return null;
    const elapsed = new Date().getTime() - job.startedAt.getTime();
    const totalEstimated = elapsed / (job.progress / 100);
    return Math.max(0, totalEstimated - elapsed);
};

function descendingComparator<T>(a: T, b: T, orderBy: keyof T) {
  if (b[orderBy] < a[orderBy]) {
    return -1;
  }
  if (b[orderBy] > a[orderBy]) {
    return 1;
  }
  return 0;
}

type Order = 'asc' | 'desc';

function getComparator<Key extends keyof any>(
  order: Order,
  orderBy: Key,
): (
  a: { [key in Key]: number | string },
  b: { [key in Key]: number | string },
) => number {
  return order === 'desc'
    ? (a, b) => descendingComparator(a, b, orderBy)
    : (a, b) => -descendingComparator(a, b, orderBy);
}

interface HeadCell {
  disablePadding: boolean;
  id: keyof Job | 'actions' | 'duration';
  label: string;
  sortable?: boolean;
}

const headCells: readonly HeadCell[] = [
  {
    id: 'status',
    disablePadding: false,
    label: 'Status',
    sortable: true,
  },
  {
    id: 'videoId',
    disablePadding: false,
    label: 'Video',
    sortable: true,
  },
  {
    id: 'type',
    disablePadding: false,
    label: 'Type',
    sortable: true,
  },
  {
    id: 'createdAt',
    disablePadding: false,
    label: 'Created',
    sortable: true,
  },
  {
    id: 'progress',
    disablePadding: false,
    label: 'Progress',
    sortable: true,
  },
  {
    id: 'duration',
    disablePadding: false,
    label: 'Duration / ETA',
  },
  {
    id: 'actions',
    disablePadding: false,
    label: '',
  }
];

interface EnhancedTableProps {
  onRequestSort: (event: React.MouseEvent<unknown>, property: keyof Job) => void;
  order: Order;
  orderBy: string;
  rowCount: number;
}

function EnhancedTableHead(props: EnhancedTableProps) {
  const { order, orderBy, onRequestSort } = props;
  const createSortHandler =
    (property: keyof Job) => (event: React.MouseEvent<unknown>) => {
      onRequestSort(event, property);
    };

  return (
    <TableHead>
      <TableRow>
        {headCells.map((headCell) => (
          <TableCell
            key={headCell.id}
            align={'left'}
            padding={headCell.disablePadding ? 'none' : 'normal'}
            sortDirection={orderBy === headCell.id ? order : false}
          >
            {headCell.sortable ? (
              <TableSortLabel
                  active={orderBy === headCell.id}
                  direction={orderBy === headCell.id ? order : 'asc'}
                  onClick={createSortHandler(headCell.id as keyof Job)}
              >
                {headCell.label}
                {orderBy === headCell.id ? (
                    <Box component="span" sx={visuallyHidden}>
                      {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                    </Box>
                ) : null}
              </TableSortLabel>
            ) : (
              headCell.label
            )}
          </TableCell>
        ))}
      </TableRow>
    </TableHead>
  );
}

interface VideoInfo {
    frameCount: number;
    fps: number;
}

const estimateProcessingMs = (videoInfo: VideoInfo | null): number | null => {
    if (!videoInfo) return null;
    // Same heuristic as VideoMetadataBar: ~3 frames/sec on mid-range GPU
    const effectiveFrames = videoInfo.fps > 30 ? videoInfo.frameCount * (30 / videoInfo.fps) : videoInfo.frameCount;
    return (effectiveFrames / 3) * 1000;
};

const JobDurationCell = ({ job, videoInfo }: { job: Job; videoInfo: VideoInfo | null }) => {
    const [, setTick] = React.useState(0);

    React.useEffect(() => {
        if (job.status !== 'running') return;
        const interval = setInterval(() => setTick(t => t + 1), 1000);
        return () => clearInterval(interval);
    }, [job.status]);

    const elapsed = getElapsedMs(job);
    const remaining = getEstimatedRemainingMs(job);
    const initialEstimate = estimateProcessingMs(videoInfo);

    if (job.status === 'open') {
        return (
            <Box component="div" sx={{ width: 100 }}>
                <Typography variant="body2" color="text.secondary">—</Typography>
                <Box component="div" sx={{ minHeight: 18 }}>
                    {initialEstimate && (
                        <Typography variant="caption" color="text.secondary" sx={{ whiteSpace: 'nowrap' }}>
                            ~{formatDuration(initialEstimate)}
                        </Typography>
                    )}
                </Box>
            </Box>
        );
    }

    // For finished jobs, show how estimate compared to actual
    const getAccuracyLabel = (): string | null => {
        if (job.status !== 'finished' || !elapsed || !initialEstimate) return null;
        const ratio = elapsed / initialEstimate;
        // Use simple multipliers - cleaner than percentages
        if (ratio <= 0.5) return `${(1 / ratio).toFixed(1)}x faster`;
        if (ratio >= 2) return `${ratio.toFixed(1)}x longer`;
        // Within 0.5x-2x range: don't clutter with minor deviations
        return null;
    };

    const accuracyLabel = getAccuracyLabel();

    return (
        <Box component="div" sx={{ width: 100 }}>
            {elapsed !== null && (
                <Typography variant="body2" sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: '0.8125rem', whiteSpace: 'nowrap' }}>
                    {formatDuration(elapsed)}
                </Typography>
            )}
            <Box component="div" sx={{ minHeight: 18 }}>
                {remaining !== null && job.status === 'running' && (
                    <Typography variant="caption" color="text.secondary" sx={{ whiteSpace: 'nowrap' }}>
                        ~{formatDuration(remaining)}
                    </Typography>
                )}
                {job.status === 'finished' && job.startedAt && job.finishedAt && (
                    <Tooltip title={initialEstimate ? `Est. was ~${formatDuration(initialEstimate)}` : ''}>
                        <Typography variant="caption" color={accuracyLabel ? 'success.main' : 'text.secondary'} sx={{ whiteSpace: 'nowrap' }}>
                            {accuracyLabel ?? 'Done'}
                        </Typography>
                    </Tooltip>
                )}
            </Box>
        </Box>
    );
};

const pulse = keyframes`
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
`;

// Authoritative phase labels reported by the worker. Falls back to inferring from
// progress ranges for backward compatibility with jobs written before the phase
// field existed (or for UIs that have loaded before the column was populated).
const PHASE_META: Record<string, { color: string; detail: string }> = {
    'Preparing':       { color: 'info.main',    detail: 'Setting up the pipeline and reading video metadata' },
    'Segmenting':      { color: 'warning.main', detail: 'SAM2 propagating masks frame-by-frame — longest step, depends on video length' },
    'Estimating pose': { color: 'info.main',    detail: 'Running pose estimation on each tracked object (RTMPose / OpenPose / MediaPipe)' },
    'Rendering':       { color: 'success.main', detail: 'Compositing the output video — applying masks and pose overlays' },
};

const getProgressPhase = (progress: number, status: string, phase?: string | null): { label: string; color: string; detail: string } => {
    if (status === 'finished') return { label: 'Done', color: 'success.main', detail: 'Processing complete' };
    if (status === 'failed') return { label: 'Failed', color: 'error.main', detail: 'Job failed — check worker logs' };
    if (status === 'cancelled') return { label: 'Cancelled', color: 'text.secondary', detail: 'Cancelled by user — the worker stopped at the next checkpoint.' };
    if (status === 'open') return { label: 'Queued', color: 'text.secondary', detail: 'Waiting for a worker to pick up the job' };

    // Prefer the authoritative phase from the backend when available.
    if (phase && PHASE_META[phase]) {
        return { label: phase, ...PHASE_META[phase] };
    }
    if (phase) {
        return { label: phase, color: 'info.main', detail: phase };
    }

    // Fallback: infer from progress range (legacy behavior).
    if (progress <= 5) return { label: 'Reading', color: 'info.main', detail: 'Reading video into memory' };
    if (progress <= 30) return { label: 'SAM2', color: 'warning.main', detail: 'SAM2 propagating masks frame-by-frame — longest step, depends on video length' };
    if (progress <= 35) return { label: 'Decoding', color: 'info.main', detail: 'Decoding SAM2 mask output' };
    if (progress <= 45) return { label: 'Sub-videos', color: 'info.main', detail: 'Cropping per-object sub-videos for pose estimation' };
    if (progress <= 55) return { label: 'Pose est.', color: 'info.main', detail: 'Running pose estimation on each tracked object (RTMPose / OpenPose / MediaPipe)' };
    return { label: 'Rendering', color: 'success.main', detail: `Compositing frame ${progress - 55}/44 — applying masks and pose overlays` };
};

const JobProgressCell = ({ job }: { job: Job }) => {
    if (job.status === 'open') {
        return (
            <Tooltip title="Waiting for available worker">
                <Box component="div" sx={{ width: 180 }}>
                    <LinearProgress variant="indeterminate" sx={{ height: 6, borderRadius: 3 }} />
                    <Box component="div" sx={{ minHeight: 18, mt: 0.5 }}>
                        <Typography variant="caption" color="text.secondary">Queued</Typography>
                    </Box>
                </Box>
            </Tooltip>
        );
    }

    const phase = getProgressPhase(job.progress, job.status, job.phase);
    const isSegmenting = job.status === 'running' && job.progress > 5 && job.progress <= 30;

    return (
        <Box component="div" sx={{ width: 180 }}>
            <Box component="div" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <LinearProgress
                    variant="determinate"
                    value={job.progress}
                    sx={{
                        flex: 1,
                        height: 6,
                        borderRadius: 3,
                        backgroundColor: 'action.hover',
                        '& .MuiLinearProgress-bar': {
                            borderRadius: 3,
                            transition: 'transform 0.8s ease',
                        },
                    }}
                />
                <Typography
                    variant="body2"
                    sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: '0.8125rem', width: 38, textAlign: 'right', flexShrink: 0 }}
                >
                    {Math.round(job.progress)}%
                </Typography>
            </Box>
            {/* Fixed height + width to prevent any layout shift when phase label changes */}
            <Box component="div" sx={{ minHeight: 18, mt: 0.5 }}>
                {job.status === 'running' && (
                    <Tooltip title={phase.detail} placement="bottom-start">
                        <Typography
                            variant="caption"
                            sx={{
                                display: 'block',
                                color: phase.color,
                                fontFamily: '"IBM Plex Mono", monospace',
                                fontSize: '0.6875rem',
                                animation: isSegmenting ? `${pulse} 2s ease-in-out infinite` : 'none',
                                cursor: 'help',
                            }}
                        >
                            {phase.label}…
                        </Typography>
                    </Tooltip>
                )}
                {(job.status === 'finished' || job.status === 'failed') && (
                    <Typography variant="caption" sx={{ display: 'block', color: phase.color, fontFamily: '"IBM Plex Mono", monospace', fontSize: '0.6875rem' }}>
                        {phase.label}
                    </Typography>
                )}
            </Box>
        </Box>
    );
};

const RunsPage = () => {
  const dispatch = useDispatch();
  const jobs = useSelector(Selector.Job.jobList);
  const videos = useSelector(Selector.Video.videoList);
  const [order, setOrder] = React.useState<Order>('desc');
  const [orderBy, setOrderBy] = React.useState<keyof Job>('createdAt');
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(10);
  const [jobToDelete, setJobToDelete] = React.useState<string>();

  const handleRequestSort = (
    event: React.MouseEvent<unknown>,
    property: keyof Job,
  ) => {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
  };

  const handleChangePage = (event: unknown, newPage: number) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const deleteJob = (jobId: string) => {
    dispatch(Command.Job.deleteJob({ id: jobId }));
  };

  const emptyRows =
    page > 0 ? Math.max(0, (1 + page) * rowsPerPage - jobs.length) : 0;

  const visibleRows = React.useMemo(
    () => [...jobs]
        .sort(getComparator(order, orderBy) as unknown as (a: Job, b: Job) => number)
        .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage),
    [order, orderBy, page, rowsPerPage, jobs],
  );

  return (
    <Box component="div" sx={{ width: '100%' }}>
      <Paper sx={{ width: '100%', mb: 2 }}>
        <TableContainer sx={{padding: "20px"}}>
        <Typography
          sx={{ flex: '1 1 100%' }}
          variant="h6"
          id="tableTitle"
          component="div"
        >
          Masking Runs
        </Typography>
          <Table
            sx={{ minWidth: 750 }}
            aria-labelledby="runsTable"
            size={'medium'}
          >
            <EnhancedTableHead
              order={order}
              orderBy={orderBy}
              onRequestSort={handleRequestSort}
              rowCount={jobs.length}
            />
            <TableBody>
              {visibleRows.map((row) => {
                return (
                  <TableRow
                    hover
                    tabIndex={-1}
                    key={row.id}
                    sx={{ cursor: 'pointer' }}
                  >
                    <TableCell>
                      <Chip label={row.status} color={statusColors[row.status]} size="small" />
                    </TableCell>
                    <TableCell>
                      <MuiLink component={Link} to={Paths.makeVideoDetailsUrl(row.videoId)}>
                        {videos.find(video => video.id === row.videoId)?.name ?? row.videoId.slice(0, 8)}
                      </MuiLink>
                    </TableCell>
                    <TableCell>
                        {jobTypeLabels[row.type] ?? row.type}
                    </TableCell>
                    <TableCell>
                        <Tooltip title={row.createdAt.toLocaleString()}>
                            <span>{row.createdAt.toLocaleDateString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
                        </Tooltip>
                    </TableCell>
                    <TableCell sx={{ paddingTop: 1, paddingBottom: 1 }}>
                      <JobProgressCell job={row} />
                    </TableCell>
                    <TableCell>
                      <JobDurationCell
                        job={row}
                        videoInfo={(() => {
                          const video = videos.find(v => v.id === row.videoId);
                          return video?.videoInfo ? { frameCount: video.videoInfo.frameCount, fps: video.videoInfo.fps } : null;
                        })()}
                      />
                    </TableCell>
                    <TableCell>
                      {(row.status === 'open' || row.status === 'running') && (
                        <Tooltip title="Stop the worker at the next checkpoint. The job stays visible here with status 'cancelled'.">
                          <IconButton
                            color={'warning'}
                            size="small"
                            onClick={() => dispatch(Command.Job.cancelJob({ id: row.id }))}
                          >
                            <CancelIcon fontSize="small" />
                          </IconButton>
                        </Tooltip>
                      )}
                      <IconButton color={'primary'} size="small" onClick={() => setJobToDelete(row.id)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                );
              })}
              {emptyRows > 0 && (
                <TableRow
                  style={{
                    height: (53) * emptyRows,
                  }}
                >
                  <TableCell colSpan={7} />
                </TableRow>
              )}
              {jobs.length === 0 && (
                <TableRow>
                    <TableCell colSpan={7} align="center" sx={{ py: 4 }}>
                        <Typography variant="body2" color="text.secondary">
                            No masking runs yet. Start a run from the video detail page.
                        </Typography>
                    </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={jobs.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </Paper>
      <DeleteJobDialog
        open={Boolean(jobToDelete)}
        onCancel={() => setJobToDelete(undefined)}
        onConfirm={() => {
          if (jobToDelete) {
            deleteJob(jobToDelete);
          }
          setJobToDelete(undefined)
        }}
      />
    </Box>
  );
}

export default RunsPage
