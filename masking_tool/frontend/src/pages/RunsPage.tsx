import * as React from 'react';
import Box from '@mui/material/Box';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import { Chip } from '@mui/material';
import { useState } from 'react';
import { Run } from '../state/types/Run';
import { Order, getComparator, stableSort } from '../util/sorting';
import EnhancedTableHead from '../components/runs/EnhancedTableHead';

function createData(
  id: string,
  videoName: string,
  params: string,
  duration: number,
  status: 'success' | 'running' | 'failed'
): Run {
  return {
    id,
    videoName,
    params,
    duration,
    status,
  }
}

const statusColors: { [status: string] : "info"|"success"|"error" } = {
    "running": "info",
    "success": "success",
    "failed": "error"
}

const mockRows = [
  createData('run1', 'ted.mp4',"bbox, mediapipe", 23, "running"),
  createData('run2', 'ted.mp4',"bbox, mediapipe", 230, "success"),
  createData('run3', 'ted.mp4',"bbox, mediapipe", 231, "failed"),
  createData('run4', 'ted.mp4',"bbox, mediapipe", 203, "success"),
  createData('run5', 'ted.mp4',"bbox, mediapipe", 310, "success"),
  createData('run6', 'ted.mp4',"bbox, mediapipe", 23, "success"),
  createData('run7', 'ted.mp4',"bbox, mediapipe", 23, "success"),
];

const RunsPage = () => {
  const [order, setOrder] = useState<Order>('asc');
  const [orderBy, setOrderBy] = useState<keyof Run>('id');
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(5);
  const [rows, setRows] = useState<Run[]>(mockRows)

  const handleRequestSort = (
    event: React.MouseEvent<unknown>,
    property: keyof Run,
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

  const emptyRows =
    page > 0 ? Math.max(0, (1 + page) * rowsPerPage - rows.length) : 0;

  const visibleRows = React.useMemo(
    () =>
      stableSort(rows, getComparator(order, orderBy)).slice(
        page * rowsPerPage,
        page * rowsPerPage + rowsPerPage,
      ),
    [order, orderBy, page, rowsPerPage],
  );

  return (
    <Box sx={{ width: '100%' }}>
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
              rowCount={rows.length}
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
                    <TableCell
                      component="th"
                      id={String(index)}
                      scope="row"
                      padding="none"
                    >
                      {row.id}
                    </TableCell>
                    <TableCell align="right">{row.videoName}</TableCell>
                    <TableCell align="right">{row.params}</TableCell>
                    <TableCell align="right">{row.duration}</TableCell>
                    <TableCell align="right">
                        <Chip label={row.status} color={statusColors[row.status]} />
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
          count={rows.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </Paper>
    </Box>
  );
}

export default RunsPage