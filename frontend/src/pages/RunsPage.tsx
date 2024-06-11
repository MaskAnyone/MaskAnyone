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
import {Chip, IconButton, Link as MuiLink} from '@mui/material';
import {useDispatch, useSelector} from "react-redux";
import Selector from "../state/selector";
import {Job} from "../state/types/Job";
import {Link} from "react-router-dom";
import Paths from "../paths";
import JobProgress from "../components/runs/JobProgress";
import DeleteIcon from '@mui/icons-material/Delete';
import DeleteJobDialog from "../components/runs/DeleteJobDialog";
import Command from "../state/actions/command";

const statusColors: { [status: string] : "info"|"success"|"error" } = {
    'running': 'info',
    'finished': 'success',
    'failed': 'error',
}

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
  id: keyof Job | 'actions';
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
    label: 'Created At',
    sortable: true,
  },
  {
    id: 'startedAt',
    disablePadding: false,
    label: 'Started At',
    sortable: true,
  },
  {
    id: 'finishedAt',
    disablePadding: false,
    label: 'Finished At',
    sortable: true,
  },
  {
    id: 'progress',
    disablePadding: false,
    label: 'Progress',
    sortable: true,
  },
  {
    id: 'actions',
    disablePadding: false,
    label: 'Actions',
  }
];

interface EnhancedTableProps {
  onRequestSort: (event: React.MouseEvent<unknown>, property: keyof Job) => void;
  order: Order;
  orderBy: string;
  rowCount: number;
}

function EnhancedTableHead(props: EnhancedTableProps) {
  const { order, orderBy, rowCount, onRequestSort } =
    props;
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
      // @ts-ignore
    () => jobs.slice().sort(getComparator(order, orderBy)).slice(
        page * rowsPerPage,
        page * rowsPerPage + rowsPerPage,
    ),
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
              {visibleRows.map((row, index) => {

                return (
                  <TableRow
                    hover
                    tabIndex={-1}
                    key={row.id}
                    sx={{ cursor: 'pointer' }}
                  >
                    <TableCell>
                      <Chip label={row.status} color={statusColors[row.status]} />
                    </TableCell>
                    <TableCell>
                      <MuiLink component={Link} to={Paths.makeVideoDetailsUrl(row.videoId)}>
                        {videos.find(video => video.id === row.videoId)?.name}
                      </MuiLink>
                    </TableCell>
                    <TableCell>{row.type}</TableCell>
                    <TableCell>{row.createdAt.toLocaleString()}</TableCell>
                    <TableCell>{row.startedAt?.toLocaleString()}</TableCell>
                    <TableCell>{row.finishedAt?.toLocaleString()}</TableCell>
                    <TableCell sx={{ paddingTop: 1, paddingBottom: 1 }}>
                      <JobProgress value={row.progress} />
                    </TableCell>
                    <TableCell>
                      <IconButton color={'primary'} onClick={() => setJobToDelete(row.id)}>
                        <DeleteIcon />
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
                  <TableCell colSpan={6} />
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
