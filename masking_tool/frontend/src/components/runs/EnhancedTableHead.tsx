import { TableHead, TableRow, TableCell, TableSortLabel } from "@mui/material";
import { Box } from "@mui/system";
import { visuallyHidden } from "@mui/utils";
import { Run } from "../../state/types/Run";
import { Order } from "../../util/sorting";

interface EnhancedTableProps {
    onRequestSort: (event: React.MouseEvent<unknown>, property: keyof Run) => void;
    order: Order;
    orderBy: string;
    rowCount: number;
  }

interface HeadCell {
    disablePadding: boolean;
    id: keyof Run;
    label: string;
    numeric: boolean;
}
  
const EnhancedTableHead = (props: EnhancedTableProps) =>  {
    const createSortHandler = (property: keyof Run) => (event: React.MouseEvent<unknown>) => {
        props.onRequestSort(event, property);
    }

    const headCells: readonly HeadCell[] = [
        {id: 'id', numeric: false, disablePadding: true, label: 'ID'},
        {id: 'videoName', numeric: true, disablePadding: false, label: 'Video Name'},
        {id: 'params', numeric: true, disablePadding: false, label: 'Params'},
        {id: 'duration', numeric: true, disablePadding: false, label: 'Duration'},
        {id: 'status', numeric: true, disablePadding: false, label: 'Status'},
  ];
  
    return (
      <TableHead>
        <TableRow>
          {headCells.map((headCell) => (
            <TableCell
              key={headCell.id}
              align={headCell.numeric ? 'right' : 'left'}
              padding={headCell.disablePadding ? 'none' : 'normal'}
              sortDirection={props.orderBy === headCell.id ? props.order : false}
            >
              <TableSortLabel
                active={props.orderBy === headCell.id}
                direction={props.orderBy === headCell.id ? props.order : 'asc'}
                onClick={createSortHandler(headCell.id)}
              >
                {headCell.label}
                {props.orderBy === headCell.id ? (
                  <Box component="span" sx={visuallyHidden}>
                    {props.order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                  </Box>
                ) : null}
              </TableSortLabel>
            </TableCell>
          ))}
        </TableRow>
      </TableHead>
    );
}

export default EnhancedTableHead