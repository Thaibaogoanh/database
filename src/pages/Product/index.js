import * as React from 'react';
import PropTypes from 'prop-types';
import { alpha } from '@mui/material/styles';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
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
import styles from "./Products.module.scss";
import Button from '@mui/material/Button';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import SearchIcon from '@mui/icons-material/Search';
import InputBase from '@mui/material/InputBase';
import { LocalizationProvider } from '@mui/x-date-pickers-pro';
import { AdapterDayjs } from '@mui/x-date-pickers-pro/AdapterDayjs';
import { DateRangePicker } from '@mui/x-date-pickers-pro/DateRangePicker';
import { Box } from '@mui/material';
import { useState, useEffect, useMemo } from 'react';
import VisibilityIcon from '@mui/icons-material/Visibility';
import EditIcon from '@mui/icons-material/Edit';
import axios from 'axios';

function Products() {
  const API_URL = "http://localhost:5000/api/v1/products";
  const [productData, setProductData] = useState([]);
  const [order, setOrder] = React.useState('asc');
  const [orderBy, setOrderBy] = React.useState('calories');
  const [selected, setSelected] = React.useState([]);
  const [page, setPage] = React.useState(0);
  const [rowsPerPage, setRowsPerPage] = React.useState(5);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(API_URL);
        setProductData(response.data.data);
      } catch (err) {
        console.error("Failed to fetch products:", err);
      }
    };

    fetchData();
  }, []);

  // Define other state variables and functions as previously

  // Updated visibleRows calculation using productData
  function stableSort(array, comparator) {
    const stabilizedThis = array.map((el, index) => [el, index]);
    stabilizedThis.sort((a, b) => {
      const order = comparator(a[0], b[0]);
      if (order !== 0) {
        return order;
      }
      return a[1] - b[1];
    });
    return stabilizedThis.map((el) => el[0]);
  }

  function descendingComparator(a, b, orderBy) {
    if (b[orderBy] < a[orderBy]) {
      return -1;
    }
    if (b[orderBy] > a[orderBy]) {
      return 1;
    }
    return 0;
  }

  function getComparator(order, orderBy) {
    return order === 'desc'
      ? (a, b) => descendingComparator(a, b, orderBy)
      : (a, b) => -descendingComparator(a, b, orderBy);
  }

  const visibleRows = useMemo( () =>
      stableSort(productData, getComparator(order, orderBy)).slice(
        page * rowsPerPage,
        page * rowsPerPage + rowsPerPage,
      ),
    [order, orderBy, page, rowsPerPage, productData],
  );

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
              'aria-label': 'select all desserts',
              }}
            />
          </TableCell>
          <TableCell
            key='name'
            align='center'
            padding='none'
            sortDirection={orderBy === 'name' ? order : false}
            colSpan={2}
            style={{ fontSize: '14px' }}
          >
            <TableSortLabel
              active={orderBy === 'name'}
              direction={orderBy === 'name' ? order : 'asc'}
              onClick={createSortHandler('name')}
            >
              Name
              {orderBy === 'name' ? (
                <Box component="span" sx={visuallyHidden}>
                  {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                </Box>
              ) : null}
            </TableSortLabel>
          </TableCell>
          <TableCell
            align='center'
            padding='normal'
            sortDirection={orderBy === 'size' ? order : false}
            style={{ fontSize: '14px' }}
          >
            Size
          </TableCell>
          <TableCell
            key='price'
            align='right'
            padding='normal'
            sortDirection={orderBy === 'price' ? order : false}
            style={{ fontSize: '14px' }}
          >
            <TableSortLabel
              active={orderBy === 'price'}
              direction={orderBy === 'price' ? order : 'asc'}
              onClick={createSortHandler('price')}
            >
              Price
              {orderBy === 'price' ? (
                <Box component="span" sx={visuallyHidden}>
                  {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                </Box>
              ) : null}
            </TableSortLabel>
          </TableCell>
          <TableCell 
            align='center' 
            padding='normal'
            key='sold'
            sortDirection={orderBy === 'sold' ? order : false}
            style={{ fontSize: '14px' }}
          >
            <TableSortLabel
              active={orderBy === 'sold'}
              direction={orderBy === 'sold' ? order : 'asc'}
              onClick={createSortHandler('sold')}
            >
              Quantity Sold
              {orderBy === 'sold' ? (
                <Box component="span" sx={visuallyHidden}>
                  {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                </Box>
              ) : null}
            </TableSortLabel>
            <LocalizationProvider dateAdapter={AdapterDayjs}>
              <DateRangePicker
                calendars={1} // Only show one calendar
              />
            </LocalizationProvider>
          </TableCell>
          <TableCell
            align='center'
            padding='normal'
            colSpan={3}
            style={{ fontSize: '14px' }}
          >
            Options
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

  function EnhancedTableToolbar(props) {
    const { numSelected } = props;

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
          <Typography sx={{ flex: '1 1 100%' }}>
              <Button 
                  variant="contained"
                  endIcon={<AddCircleOutlineIcon />}
                  sx={{
                    textTransform: 'none' ,
                    backgroundColor: '#4B6587', // Use backgroundColor inside sx
                    ':hover': {
                        backgroundColor: '#102C57' // Darken on hover for example
                    }
                  }}
                  style={{ fontSize: '12px' }}
              >
                  Thêm sản phẩm   
              </Button>
          </Typography>
        )}

        {numSelected > 0 ? (
          <Tooltip title="Delete">
            <IconButton>
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        ) : (
          <Typography>
              <Paper
                  component="form"
                  sx={{ p: '2px 4px', display: 'flex', alignItems: 'center'}}
              >
                  <InputBase
                      sx={{width: '200px'}}
                      placeholder="Search product"
                  />
                  <IconButton type="button" sx={{ p: '10px' }} aria-label="search">
                      <SearchIcon />
                  </IconButton>
              </Paper>
          </Typography>
        )}
      </Toolbar>
    );
  }

  EnhancedTableToolbar.propTypes = {
    numSelected: PropTypes.number.isRequired,
  };

  const handleRequestSort = (event, property) => {
    const isAsc = orderBy === property && order === 'asc';
    setOrder(isAsc ? 'desc' : 'asc');
    setOrderBy(property);
  };

  const handleSelectAllClick = (event) => {
    if (event.target.checked) {
      const newSelected = productData.map((n) => n.beverage_name);
      setSelected(newSelected);
      return;
    }
    setSelected([]);
  };

  const handleClick = (event, beverage_name) => {
    const selectedIndex = selected.indexOf(beverage_name);
    let newSelected = [];

    if (selectedIndex === -1) {
      newSelected = newSelected.concat(selected, beverage_name);
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


  const isSelected = (beverage_name) => selected.indexOf(beverage_name) !== -1;

  // Avoid a layout jump when reaching the last page with empty rows.
  const emptyRows =
    page > 0 ? Math.max(0, (1 + page) * rowsPerPage - productData.length) : 0;

    function SizeAndQuantity({row}) {
      const [selectedValue, setSelectedValue] = useState("Nhỏ"); // Default size
      const [quantity, setQuantity] = useState(0);
      const [price, setPrice] = useState(0);
  
      useEffect(() => {
          const selectedSize = row.sizes.find(item => item.size === selectedValue);
          if (selectedSize) {
              setQuantity(selectedSize.sold_quantity);
              setPrice(selectedSize.price);
          }
      }, [selectedValue, row.sizes]);
  
      const handleSizeChange = (event) => {
          setSelectedValue(event.target.value);
      };
  
      return (
          <>
              <TableCell align='center'>
                  <select
                      value={selectedValue}
                      onChange={handleSizeChange}
                      className="form-select"
                      id={`size-select-${row.beverage_name}`}
                  >
                      {row.sizes.map((size, index) => (
                          <option key={index} value={size.size}>{size.size}</option>
                      ))}
                  </select>
              </TableCell>
              <TableCell align='center' style={{ fontSize: '12px' }}>{price}</TableCell>
              <TableCell align='center' style={{ fontSize: '12px' }}>{quantity}</TableCell>
          </>
      );
  }

  return (
    <div className={clsx(styles.productArea)}>
      <Box sx={{ width: '100%' }}>
        <Paper sx={{ width: '100%', mb: 2 }}>
            <EnhancedTableToolbar numSelected={selected.length} />
            <TableContainer>
              <Table
                sx={{ minWidth: 750 }}
                aria-labelledby="tableTitle"
              >
                <EnhancedTableHead
                  numSelected={selected.length}
                  order={order}
                  orderBy={orderBy}
                  onSelectAllClick={handleSelectAllClick}
                  onRequestSort={handleRequestSort}
                  rowCount={productData.length}
                />
                  <TableBody>
                    {visibleRows.map((row, index) => {
                        const isItemSelected = isSelected(row.beverage_name);
                        const labelId = `enhanced-table-checkbox-${index}`;

                        return (
                        <TableRow
                            hover
                            role="checkbox"
                            aria-checked={isItemSelected}
                            tabIndex={-1}
                            key={row.beverage_name}
                            selected={isItemSelected}
                            sx={{ cursor: 'pointer' }}
                        >
                            <TableCell 
                              padding="checkbox" 
                              onClick={(event) => handleClick(event, row.beverage_name)}
                            >
                              <Checkbox
                                  color="primary"
                                  checked={isItemSelected}
                                  inputProps={{
                                  'aria-labelledby': labelId,
                                  }}
                              />
                            </TableCell>
                            <TableCell>
                              <img src={row.image_url} width={35} height={35}></img>
                            </TableCell>
                            <TableCell
                            component="th"
                            id={labelId}
                            scope="row"
                            padding="none"
                            style={{ fontSize: '12px' }}
                            >
                              {row.beverage_name}
                            </TableCell>
                            <SizeAndQuantity row={row} />
                            <TableCell><button type="button" class="btn btn-outline-secondary"><VisibilityIcon></VisibilityIcon></button></TableCell>
                            <TableCell><button type="button" class="btn btn-outline-primary"><EditIcon></EditIcon></button></TableCell>
                            <TableCell><button type="button" class="btn btn-outline-danger"><DeleteIcon></DeleteIcon></button></TableCell>
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
              rowsPerPageOptions={[5, 10]}
              component="div"
              count={productData.length}
              rowsPerPage={rowsPerPage}
              page={page}
              onPageChange={handleChangePage}
              onRowsPerPageChange={handleChangeRowsPerPage}
              style={{ fontSize: '14px' }}
            />
        </Paper>
      </Box>
    </div>
  );}
export default Products;