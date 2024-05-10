import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { alpha } from '@mui/material/styles';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TablePagination from '@mui/material/TablePagination';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import Modal from '@mui/material/Modal';
import { Toolbar, Typography } from '@mui/material';
import Checkbox from '@mui/material/Checkbox';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import DeleteIcon from '@mui/icons-material/Delete';
import { visuallyHidden } from '@mui/utils';
import clsx from 'clsx';
import MenuItem from '@mui/material/MenuItem';
import VisibilityIcon from '@mui/icons-material/Visibility'; // Adjust the import path if necessary
import EditIcon from '@mui/icons-material/Edit';
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

import EditEmployeeModal from './EditEmployee';

function Employee() {
  const API_URL = "http://localhost:5000/api/v1/employees";
  const [employeeData, setEmployeeData] = useState([]);
  const [order, setOrder] = useState('asc');
  const [orderBy, setOrderBy] = useState('cccd');
  const [selected, setSelected] = useState([]);
  const [page, setPage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(20);
  const [searchInput, setSearchInput] = useState('');
  const [selectedEmployeeData, setSelectedEmployeeData] = useState(null);

  const [filters, setFilters] = useState({
    jobType: '',
    gender: '',
  });
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [dateRange, setDateRange] = useState([null, null]);
  const [productData, setProductData] = useState([]);
  const [selectedEmployee, setSelectedEmployee] = useState(null);

  const [newEmployeeData, setNewEmployeeData] = useState({
    cccd: '',
    address: '',
    job_type: '',
    date_of_work: '',
    gender: '',
    date_of_birth: '',
    last_name: '',
    middle_name: '',
    first_name: '',
    super_ssn: '',
    image: null, // Thêm trường hình ảnh vào đối tượng
  });

  // State for modal open/close
  const [total, setTotal] = useState();
  const [modalOpen, setModalOpen] = useState(false);
  const fetchData = async () => {
    try {
      let queryParams;
   

      if (searchInput.trim() !== '') {
        queryParams += `&search=${encodeURIComponent(searchInput.trim())}`;
      }
      if (filters.jobType !== '') {
        queryParams += `&jobType=${encodeURIComponent(filters.jobType)}`;
        console.log(queryParams);
      }

      if (filters.gender !== '') {
        queryParams += `&gender=${encodeURIComponent(filters.gender)}`;
        console.log(queryParams);
      }
      const response = await axios.get(`${API_URL}?page=${page}&perPage=${rowsPerPage}&${queryParams}`);
      
      setProductData(response.data.data);
      setTotal(response.data.total);

      setEmployeeData(response.data.data);
    } catch (err) {
      console.error("Failed to fetch employees:", err);
    }
  };
  
  useEffect(() => {
    fetchData();
  }, [ searchInput, filters,dateRange, page, rowsPerPage,selected]);

  const handleNewEmployeeChange = (event) => {
    const { name, value } = event.target;
    setNewEmployeeData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };
 

  const handleImageChange = (event) => {
    const imageFile = event.target.files[0];
    setNewEmployeeData((prevData) => ({
      ...prevData,
      image: imageFile,
    }));
     // Kiểm tra tệp ảnh sau khi đã được chọn
  // const reader = new FileReader();
  // reader.onload = (e) => {
  //   const imageSrc = e.target.result;
  //   console.log("Tệp ảnh đã được tải lên thành công:", imageSrc);
  //   // Ở đây, bạn có thể sử dụng imageSrc để hiển thị trước ảnh nếu cần
  // };
  // reader.readAsDataURL(imageFile);
  };



  const handleModalClose = () => {
    setModalOpen(false);
    setIsModalOpen(false);

  };
const emptyRows =page > 0 ? Math.max(0, (1 + page) * rowsPerPage - productData.length) : 0;
  const handleCreateEmployee = async () => {
    try {
      console.log(newEmployeeData.cccd);
      console.log(newEmployeeData.super_ssn);
      // 1. Xác thực dữ liệu
      if (!newEmployeeData.image) {
        console.error("Image is required");
        return;
      }
      
      // 2. Tạo một FormData object để gửi dữ liệu
      const formData = new FormData();
      formData.append("image", newEmployeeData.image); // Đảm bảo rằng tên trường ảnh trùng với tên trường trong API
      formData.append("cccd", newEmployeeData.cccd);
      formData.append("address", newEmployeeData.address);
      formData.append("job_type", newEmployeeData.job_type);
      formData.append("date_of_work", newEmployeeData.date_of_work);
      formData.append("gender", newEmployeeData.gender);
      formData.append("date_of_birth", newEmployeeData.date_of_birth);
      formData.append("last_name", newEmployeeData.last_name);
      formData.append("middle_name", newEmployeeData.middle_name);
      formData.append("first_name", newEmployeeData.first_name);
      formData.append("super_ssn", newEmployeeData.super_ssn);
  
      // 3. Gửi yêu cầu POST tới API
      const response = await axios.post(API_URL, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
  
      // 4. Xử lý phản hồi từ API
      const newEmployee = response.data.data;
      setEmployeeData([...employeeData, newEmployee]);
      setModalOpen(false);
    } catch (error) {
      console.error("Failed to create employee:", error);
      console.log(error);
    }
  };
  

  const [initialSsn, setInitialSsn] = useState(null);

  const handleEdit = (employee) => {
    // console.log(employee);
    setSelectedEmployeeData(employee); 
   // setSelectedEmployee(employee);
    setInitialSsn(employee); 

    setEditModalOpen(true);
    
  };

  const handleCloseEditModal = () => {
    setEditModalOpen(false);
    setSelectedEmployee(null);
  };

  const handleSaveEdit = async (editedData) => {
    try {
      // Tạo một FormData object để gửi dữ liệu
      console.log(editedData.cccd);
      console.log(editedData.image);
      const formData = new FormData();
      formData.append("cccd", editedData.cccd||null);
      formData.append("address", editedData.address||null);
      formData.append("job_type", editedData.job_type||null);
      formData.append("date_of_birth", editedData.date_of_birth||null);
      formData.append("super_ssn", editedData.super_ssn||null);
      formData.append("image", editedData.image); // Thêm hình ảnh vào FormData
      // Gửi yêu cầu PUT tới API
      
      const response = await axios.put(`${API_URL}/${initialSsn.ssn}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      
      // Xử lý phản hồi từ API
      setSelectedEmployee(null);
      setEmployeeData([...employeeData,response.data.data]);
      setEditModalOpen(false);
      fetchData();
     
    } catch (err) {
      console.error("Failed to update employee:", err);
      console.log(err);
    }
  };

  const stableSort = (array, comparator) => {
    if (!array) return []; 
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

  const handleModalOpen = (employee) => {
    setSelectedEmployeeData(employee);
    setIsModalOpen(true);
    setModalOpen(true);
  };
  const handleSelectAllClick = (event) => {
    if (employeeData && employeeData.length > 0 && event.target.checked) {
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
    setRowsPerPage(parseInt(event.target.value));
    setPage(0);
  };

  const handleRequestSort = (event, property) => {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
  };

  const handleDelete = async () => {
    try {
      // Truyền danh sách các SSN đã chọn vào body của yêu cầu delete
 
      const response = await axios.delete(API_URL, {
        data: { ids: selected } // Trích xuất danh sách SSN từ selected
      });
    
      setSelected([{}]);
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
  const [isModalOpen, setIsModalOpen] = useState(false);

  const [addEmployeeModalOpen, setAddEmployeeModalOpen] = useState(false);
const [viewEmployeeModalOpen, setViewEmployeeModalOpen] = useState(false);
  
const handleAddEmployeeModalOpen = () => {
  setAddEmployeeModalOpen(true);
};

const handleViewEmployeeModalOpen = (employee) => {
  setSelectedEmployeeData(employee); // Truyền dữ liệu nhân viên vào modal
  setViewEmployeeModalOpen(true); // Mở modal
};

const handleAddEmployeeModalClose = () => {
  setAddEmployeeModalOpen(false);
};

const handleViewEmployeeModalClose = () => {
  setViewEmployeeModalOpen(false);
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
          <MenuItem value="Phục vụ" style={{ fontFamily: 'Roboto, sans-serif' }}>Phục vụ</MenuItem>
<MenuItem value="Pha chế" style={{ fontFamily: 'Roboto, sans-serif' }}>Pha chế</MenuItem>
<MenuItem value="Bảo vệ" style={{ fontFamily: 'Roboto, sans-serif' }}>Bảo vệ</MenuItem>
<MenuItem value="Thu ngân" style={{ fontFamily: 'Roboto, sans-serif' }}>Thu ngân</MenuItem>

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
    
      <Paper className={clsx(styles.paper)}>
        <EnhancedTableToolbar
          numSelected={selected.length}
          onDelete={handleDelete}
          onAdd={handleModalOpen}
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
            {employeeData && employeeData.length > 0 && visibleRows.map((row, index) =>{
                const {ssn, cccd, address, job_type, date_of_work, gender, date_of_birth, last_name, middle_name, first_name, image_url } = row;
                const labelId = `enhanced-table-checkbox-${index}`;

                return (
                  <TableRow
                    hover
                    role="checkbox"
                    tabIndex={-1}
                    key={ssn}
                    selected={isSelected(ssn)}
                  >
                    <TableCell padding="checkbox">
                      <Checkbox
                        color="primary"
                        checked={isSelected(ssn)}
                        onChange={(event) => handleClick(event, ssn)}
                        inputProps={{
                          'aria-labelledby': labelId,
                        }}
                      />
                    </TableCell>
                    <TableCell align="center">
                      <img src={image_url} alt="Employee" className={styles.employeeImage} />
                    </TableCell>
                    <TableCell align="center">{cccd}</TableCell>
                    <TableCell align="center" >{job_type}</TableCell>
                    <TableCell align="center">{gender}</TableCell>
                    <TableCell align="center" >
                      {`${last_name} ${middle_name} ${first_name}`}
                    </TableCell>
                    <TableCell align="center">
                      <IconButton onClick={() => handleViewEmployeeModalOpen(row)}>
                      <VisibilityIcon/>
                      </IconButton>
                      <IconButton onClick={() => handleEdit(row)}>
                     <EditIcon/>
                      </IconButton>
                     
                    </TableCell>
                  </TableRow>
                );
              })}
              {emptyRows > 0 && (
                        <TableRow>
                        <TableCell colSpan={6} />
                        </TableRow>
                    )}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          rowsPerPageOptions={[5, 10, 25]}
          component="div"
          count={total}
          rowsPerPage={rowsPerPage}
          page={page}
          onPageChange={handleChangePage}
          onRowsPerPageChange={handleChangeRowsPerPage}
        />
      </Paper>
      <EditEmployeeModal
        open={editModalOpen}
        onClose={handleCloseEditModal}
        employee={selectedEmployeeData}
        onSave={(editedData) => handleSaveEdit(editedData, initialSsn)}
      />
        {/* Add Employee Modal */}
        <Modal
  open={modalOpen}
  onClose={handleModalClose}
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
  style={{
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  }}
  slotProps={{
    backdrop: {
      className: 'modalBackdrop' // Thêm lớp CSS cho backdrop
    }
  }}
>
  <div className={clsx(styles.modalContent, 'modalContent')}>
    <Typography variant="h6" id="modal-title">
    </Typography>
    <form className={styles.form}>

      <TextField
        label="Cccd"
        name="cccd"
        value={newEmployeeData.cccd}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Address"
        name="address"
        value={newEmployeeData.address}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Job Type"
        name="job_type"
        value={newEmployeeData.job_type}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Date of Work"
        name="date_of_work"
        value={newEmployeeData.date_of_work}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Gender"
        name="gender"
        value={newEmployeeData.gender}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Date of Birth"
        name="date_of_birth"
        value={newEmployeeData.date_of_birth}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Last Name"
        name="last_name"
        value={newEmployeeData.last_name}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Middle Name"
        name="middle_name"
        value={newEmployeeData.middle_name}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="First Name"
        name="first_name"
        value={newEmployeeData.first_name}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <TextField
        label="Super SSN"
        name="super_ssn"
        value={newEmployeeData.super_ssn}
        onChange={handleNewEmployeeChange}
        fullWidth
      />
      <input
        accept="image/*"
        id="image-upload"
        type="file"
        onChange={handleImageChange}
        style={{ display: 'none' }}
      />
      <label htmlFor="image-upload">
        <Button variant="contained" component="span">
          Upload Image
        </Button>
      </label>
      <Button variant="contained" color="primary" onClick={handleCreateEmployee}>
        Save
      </Button>
    </form>
  </div>
</Modal>

      <Modal
  open={viewEmployeeModalOpen}
  onClose={handleViewEmployeeModalClose}
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
  style={{
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  }}
>
  <div className={clsx(styles.modalContent, 'modalContent')}>
    <Typography variant="h6" id="modal-title">
    
    </Typography>
    {selectedEmployeeData && (
      <div>
        {selectedEmployeeData.image_url && (
          <img src={selectedEmployeeData.image_url} alt="Employee" />
        )}
        <p>CCCD: {selectedEmployeeData.cccd}</p>
        <p>Address: {selectedEmployeeData.address}</p>
        <p>Job Type: {selectedEmployeeData.job_type}</p>
        <p>Date of Work: {selectedEmployeeData.date_of_work}</p>
        <p>Gender: {selectedEmployeeData.gender}</p>
        <p>Date of Birth: {selectedEmployeeData.date_of_birth}</p>
        <p>Name: {`${selectedEmployeeData.last_name} ${selectedEmployeeData.middle_name} ${selectedEmployeeData.first_name}`}</p>

        <p>Super SSN: {selectedEmployeeData.super_ssn}</p>
      
      </div>
    )}
  </div>
</Modal>

    </div>
  );
}
function EnhancedTableToolbar(props) {
  const { numSelected, onDelete, onAdd } = props;

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
          onClick={onAdd} // Thêm sự kiện onClick vào nút "New Employee"
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
  onAdd: PropTypes.func.isRequired, // Thêm kiểu prop và yêu cầu prop onAdd
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
          CCCD
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

          Gender
        </TableCell>
        <TableCell
          align='center'
          padding='normal'
          style={{ fontSize: '14px' }}
        >
       
          Name
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