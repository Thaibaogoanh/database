import * as React from 'react';
import PropTypes from 'prop-types';
import { alpha } from '@mui/material/styles';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import EditEmployee from './EditEmployee';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import TableSortLabel from '@mui/material/TableSortLabel';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Paper from '@mui/material/Paper';
import Checkbox from '@mui/material/Checkbox';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import DeleteIcon from '@mui/icons-material/Delete';
import { visuallyHidden } from '@mui/utils';
import clsx from 'clsx';
import MenuItem from '@mui/material/MenuItem';

import styles from "./Employee.module.scss";
import Button from '@mui/material/Button';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import SearchIcon from '@mui/icons-material/Search';
import InputBase from '@mui/material/InputBase';
import { LocalizationProvider } from '@mui/x-date-pickers-pro';
import { AdapterDayjs } from '@mui/x-date-pickers-pro/AdapterDayjs';
import { DateRangePicker } from '@mui/x-date-pickers-pro/DateRangePicker';
import { Box, TextField } from '@mui/material';
import axios from 'axios';
import VisibilityIcon from '@mui/icons-material/Visibility';
import EditIcon from '@mui/icons-material/Edit';

function Employee() {
  const API_URL = "http://localhost:5000/api/v1/employees";
  const [employeeData, setEmployeeData] = React.useState([]);
  const [order, setOrder] = React.useState('asc');
  const [orderBy, setOrderBy] = React.useState('cccd');
  const [selected, setSelected] = React.useState([]);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(5);
  const [dateRange, setDateRange] = React.useState([null, null]);
  const [searchInput, setSearchInput] = React.useState('');
  const [filters, setFilters] = React.useState({
    jobType: '',
    gender: '',
  });
  const [editModalOpen, setEditModalOpen] = React.useState(false);
  const [selectedEmployee, setSelectedEmployee] = React.useState(null);
  React.useEffect(() => {
    const fetchData = async () => {
      try {
        let response;
        let queryParams = '';

        if (dateRange[0] !== null && dateRange[1] !== null) {
          const startDate = dateRange[0].format('YYYY-MM-DD');
          const endDate = dateRange[1].format('YYYY-MM-DD');
          queryParams += `&dob=${startDate}&dob=${endDate}`;
        }

        if (searchInput.trim() !== '') {
          queryParams += `&search=${encodeURIComponent(searchInput.trim())}`;
        }

        if (filters.jobType !== '') {
          queryParams += `&job_type=${encodeURIComponent(filters.jobType)}`;
        }

        if (filters.gender !== '') {
          queryParams += `&gender=${encodeURIComponent(filters.gender)}`;
        }

        response = await axios.get(`${API_URL}?${queryParams}`);
        setEmployeeData(response.data.data);
      } catch (err) {
        console.error("Failed to fetch employees:", err);
      }
    };

    fetchData();
  }, [dateRange, searchInput, filters]);
  const handleEdit = (employee) => {
    setSelectedEmployee(employee);
    setEditModalOpen(true);
  };

  const handleCloseEditModal = () => {
    setEditModalOpen(false);
    setSelectedEmployee(null);
  };
  const handleSaveEdit = async (editedData) => {
    try {
      await axios.put(`${API_URL}/${editedData.id}`, editedData);
      // Refresh employee data after update
      const response = await axios.get(API_URL);
      setEmployeeData(response.data.data);
    } catch (err) {
      console.error("Failed to update employee:", err);
    }
  };
  const stableSort = (array, comparator) => {
    const stabilizedThis = array.map((el, index) => [el, index]);
    stabilizedThis.sort((a, b) => {
      const order = comparator(a[0], b[0]);
      if (order !== 0) {
        return order;
      }
      return a[1] - b[1];
    });
    return stabilizedThis.map((el) => el[0]);
  };

  const descendingComparator = (a, b, orderBy) => {
    if (b[orderBy] < a[orderBy]) {
      return -1;
    }
    if (b[orderBy] > a[orderBy]) {
      return 1;
    }
    return 0;
  };

  const getComparator = (order, orderBy) => {
    return order === 'desc'
      ? (a, b) => descendingComparator(a, b, orderBy)
      : (a, b) => -descendingComparator(a, b, orderBy);
  };

  const visibleRows = React.useMemo(() =>
    stableSort(employeeData, getComparator(order, orderBy)).slice(
      page * rowsPerPage,
      page * rowsPerPage + rowsPerPage,
    ),
    [order, orderBy, page, rowsPerPage, employeeData],
  );

  const handleDateChange = (newValue) => {
    setDateRange(newValue);
  };

  const handleSelectAllClick = (event) => {
    if (event.target.checked) {
      const newSelected = employeeData.map((n) => n.ssn);
      setSelected(newSelected);
      return;
    }
    setSelected([]);
  };

  const isSelected = (ssn) => selected.indexOf(ssn) !== -1;

  const handleClick = (event, ssn) => {
    const selectedIndex = selected.indexOf(ssn);
    let newSelected = [];

    if (selectedIndex === -1) {
      newSelected = newSelected.concat(selected, ssn);
    } else if (selectedIndex === 0) {
      newSelected = newSelected.concat(selected.slice(1));
    } else if (selectedIndex === selected.length - 1) {
      newSelected = newSelected.concat(selected.slice(0, -1));
    } else if (selectedIndex > 0) {
      newSelected = newSelected.concat(
        selected.slice(0, selectedIndex),
        selected.slice(selectedIndex + 1),
      );
    }

    setSelected(newSelected);
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const handleRequestSort = (event, property) => {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
  };

  const handleDelete = async () => {
    try {
      await axios.delete(API_URL, {
        data: { ids: selected }
      });
      // Refresh employee data after deletion
      const response = await axios.get(API_URL);
      setEmployeeData(response.data.data);
      setSelected([]);
    } catch (err) {
      console.error("Failed to delete employees:", err);
    }
  };

  const handleSearchInputChange = (event) => {
    setSearchInput(event.target.value);
  };

  const handleFilterChange = (event) => {
    const { name, value } = event.target;
    setFilters((prevFilters) => ({
      ...prevFilters,
      [name]: value,
    }));
  };

  return (
    
    <div className={clsx(styles.root)}>
      <div className={clsx(styles.searchBar)}>
        <div className={clsx(styles.searchIcon)}>
          <SearchIcon />
        </div>
        <InputBase
          placeholder="Search…"
          classes={{
            root: styles.inputRoot,
            input: styles.inputInput,
          }}
          inputProps={{ 'aria-label': 'search' }}
          value={searchInput}
          onChange={handleSearchInputChange}
        />
      </div>
      <div>
        <TextField
          select
          label="Job Type"
          value={filters.jobType}
          onChange={handleFilterChange}
          name="jobType"
          variant="outlined"
          size="small"
          className={clsx(styles.filterSelect)}
        >
          <MenuItem value="">All</MenuItem>
          <MenuItem value="Full-time">Full-time</MenuItem>
          <MenuItem value="Part-time">Part-time</MenuItem>
          <MenuItem value="Contract">Contract</MenuItem>
        </TextField>
        <TextField
          select
          label="Gender"
          value={filters.gender}
          onChange={handleFilterChange}
          name="gender"
          variant="outlined"
          size="small"
          className={clsx(styles.filterSelect)}
        >
          <MenuItem value="">All</MenuItem>
          <MenuItem value="Male">Male</MenuItem>
          <MenuItem value="Female">Female</MenuItem>
          <MenuItem value="Other">Other</MenuItem>
        </TextField>
      </div>
      <LocalizationProvider dateAdapter={AdapterDayjs}>
        <DateRangePicker
          startText="From"
          endText="To"
          value={dateRange}
          onChange={handleDateChange}
          renderInput={(startProps, endProps) => (
            <React.Fragment>
              <TextField {...startProps} size="small" />
              <Box sx={{ mx: 2 }}> to </Box>
              <TextField {...endProps} size="small" />
            </React.Fragment>
          )}
        />
      </LocalizationProvider>
      <Paper className={clsx(styles.paper)}>
        <EnhancedTableToolbar
          numSelected={selected.length}
          onDelete={handleDelete}
        />
        <TableContainer>
          <Table
            sx={{ minWidth: 750 }}
            aria-labelledby="tableTitle"
            size="medium"
            aria-label="enhanced table"
          >
            <EnhancedTableHead
              numSelected={selected.length}
              order={order}
              orderBy={orderBy}
              onSelectAllClick={handleSelectAllClick}
              onRequestSort={handleRequestSort}
              rowCount={employeeData.length}
            />
            <TableBody>
              {visibleRows.map((row, index) => {
                const { ssn, cccd, last_name, address, job_type, date_of_work, gender, date_of_birth, middle_name, first_name, imageURL } = row;
                const labelId = `enhanced-table-checkbox-${index}`;

                return (
                  <TableRow
                    hover
                    role="checkbox"
                    tabIndex={-1}
                    key={cccd}
                    selected={isSelected(cccd)}
                  >
                    <TableCell padding="checkbox">
                      <Checkbox
                        color="primary"
                        checked={isSelected(cccd)}
                        onChange={(event) => handleClick(event, cccd)}
                        inputProps={{
                          'aria-labelledby': labelId,
                        }}
                      />
                    </TableCell>
                    <TableCell align="center">{cccd}</TableCell>
                    <TableCell align="center">{address}</TableCell>
                    <TableCell align="center">{job_type}</TableCell>
                    <TableCell align="center">{date_of_work}</TableCell>
                    <TableCell align="center">{gender}</TableCell>
                    <TableCell align="center">{date_of_birth}</TableCell>
                    <TableCell align="center">{last_name}</TableCell>
                    <TableCell align="center">{middle_name}</TableCell>
                    <TableCell align="center">{first_name}</TableCell>
                    <TableCell align="center">
                      <img src={imageURL} alt="Employee" className={styles.employeeImage} />
                    </TableCell>
                    <TableCell align="center">
                      <IconButton>
                        <VisibilityIcon />
                      </IconButton>
                      <IconButton>
                        <EditIcon />
                        <EditEmployee
        open={editModalOpen}
        onClose={handleCloseEditModal}
        employeeData={selectedEmployee}
        onSave={handleSaveEdit}
      />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={employeeData.length}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </Paper>
    </div>
  );
}

function EnhancedTableToolbar(props) {
  const { numSelected, onDelete } = props;

  return (
    <Toolbar
      sx={{
        pl: { sm: 2 },
        pr: { xs: 1, sm: 1 },
        ...(numSelected > 0 && {
          bgcolor: (theme) =>
            alpha(theme.palette.primary.main, theme.palette.action.activatedOpacity),
        }),
      }}
    >
      {numSelected > 0 ? (
        <Typography
          sx={{ flex: '1 1 100%' }}
          color="inherit"
          variant="subtitle1"
          component="div"
        >
          {numSelected} selected
        </Typography>
      ) : (
        <Typography
          sx={{ flex: '1 1 100%' }}
          variant="h6"
          id="tableTitle"
          component="div"
        >
          Employees
        </Typography>
      )}
      {numSelected > 0 ? (
        <Tooltip title="Delete">
          <IconButton onClick={onDelete}>
            <DeleteIcon />
          </IconButton>
        </Tooltip>
      ) : (
        <Button
          variant="contained"
          color="primary"
          size="small"
          startIcon={<AddCircleOutlineIcon />}
          className={clsx(styles.addButton)}
        >
          New Employee
        </Button>
      )}
    </Toolbar>
  );
}

EnhancedTableToolbar.propTypes = {
  numSelected: PropTypes.number.isRequired,
  onDelete: PropTypes.func.isRequired,
};

function EnhancedTableHead(props) {
  const { onSelectAllClick, order, orderBy, numSelected, rowCount, onRequestSort } =
    props;
  const createSortHandler = (property) => (event) => {
    onRequestSort(event, property);
  };

  return (
    <TableHead>
      <TableRow className={clsx(styles.headTable)}>
        <TableCell padding="checkbox">
          <Checkbox
            color="primary"
            indeterminate={numSelected > 0 && numSelected < rowCount}
            checked={rowCount > 0 && numSelected === rowCount}
            onChange={onSelectAllClick}
            inputProps={{
              'aria-label': 'select all employees',
            }}
          />
        </TableCell>
        <TableCell
          key='cccd'
          align='center'
          padding='none'
          sortDirection={orderBy === 'cccd' ? order : false}
          style={{ fontSize: '14px' }}
        >
          <TableSortLabel
            active={orderBy === 'cccd'}
            direction={orderBy === 'cccd' ? order : 'asc'}
            onClick={createSortHandler('cccd')}
          >
            CCCD
            {orderBy === 'cccd' ? (
              <Box component="span" sx={visuallyHidden}>
                {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
              </Box>
            ) : null}
          </TableSortLabel>
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Address
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Job Type
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Date of Work
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Gender
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Date of Birth
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Last Name
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Middle Name
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          First Name
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Image
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
          Actions
        </TableCell>
      </TableRow>
    </TableHead>
  );
}

EnhancedTableHead.propTypes = {
  numSelected: PropTypes.number.isRequired,
  onRequestSort: PropTypes.func.isRequired,
  onSelectAllClick: PropTypes.func.isRequired,
  order: PropTypes.oneOf(['asc', 'desc']).isRequired,
  orderBy: PropTypes.string.isRequired,
  rowCount: PropTypes.number.isRequired,
};

export default Employee;
