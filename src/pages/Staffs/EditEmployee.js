import React, { useState,useEffect } from 'react';
import axios from 'axios';

import { Dialog, DialogActions, DialogContent, DialogTitle, Button, TextField } from '@mui/material';

const EditEmployeeModal = ({ open, onClose, employee, onSave , initialSsn }) => { // Sửa props ở đây
  const [editedEmployee, setEditedEmployee] = useState(null);
  const [editedImage, setEditedImage] = useState(null);
  const handleInputChange = (event) => {
    const { name, value } = event.target;
    setEditedEmployee({ ...editedEmployee, [name]: value });
    console.log(editedEmployee);

  };

  const handleImageChange = (event) => {
    const imageFile = event.target.files[0];
    setEditedImage(imageFile);
  };
  const handleSubmit = () => {
    onSave ({ ...editedEmployee, image: editedImage }, initialSsn);
  };

  useEffect(() => {
    setEditedEmployee(employee) ;
  },[employee]);
 

  // const [employeeDetails,setEmployeeDetails] = useState();
  // const API_URL = "http://localhost:5000/api/v1/employees";
//   useEffect(()=>{
//     const fetchDataDetail = async () => {
//       try {
//         console.log(employee);
//           const response = await axios.get(`${API_URL}/${employee.ssn}`);
//           setEmployeeDetails(response.data.data);
//           console.log(response.data.data);
//         } catch (error) {
//           console.error(error);
//         }
//  };
 
//  fetchDataDetail();
// },[]
// );

// console.log(employeeDetails);
  

  return ( editedEmployee&&(
    <Dialog open={open} onClose={onClose}>
      <DialogTitle>Edit Employee</DialogTitle>
      <DialogContent>
        <TextField
          autoFocus
          margin="dense"
          name="cccd"
          label="Cccd"
          type="text"
          fullWidth
          // value={employee.cccd}
          value={editedEmployee?.cccd || ''}
          onChange={handleInputChange}
        />
        <TextField
          margin="dense"
          name="address"
          label="Address"
          type="text"
          fullWidth
          value={editedEmployee?.address || ''}
          onChange={handleInputChange}
        />
        <TextField
          margin="dense"
          name="job_type"
          label="Job_type"
          type="text"
          fullWidth
          value={editedEmployee?.job_type || ''}
          onChange={handleInputChange}
        />
        <TextField
          margin="dense"
          name="date_of_birth"
          label="Date_of_birth"
          type="text"
          fullWidth
          value={editedEmployee?.date_of_birth || ''}
          onChange={handleInputChange}
        />
        <TextField
          margin="dense"
          name="super_ssn"
          label="Super_ssn"
          type="text"
          fullWidth
          value={editedEmployee?.super_ssn || ''}
          onChange={handleInputChange}
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
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="primary">
          Cancel
        </Button>
        <Button onClick={handleSubmit} color="primary">
          Save
        </Button>
      </DialogActions>
    </Dialog>)
  );
};

export default EditEmployeeModal;
