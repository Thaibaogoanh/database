// EditEmployee.js

import React, { useState } from 'react';
import { TextField, Button, Dialog, DialogActions, DialogContent, DialogTitle } from '@mui/material';

function EditEmployee({ open, onClose, employeeData, onSave }) {
  const [editedData, setEditedData] = useState({ ...employeeData });

  const handleInputChange = (event) => {
    const { name, value } = event.target;
    setEditedData({ ...editedData, [name]: value });
  };

  const handleSave = () => {
    onSave(editedData);
    onClose();
  };

  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle>Edit Employee</DialogTitle>
      <DialogContent>
        <TextField
          name="cccd"
          label="CCCD"
          value={editedData.cccd}
          onChange={handleInputChange}
          fullWidth
        />
        <TextField
          name="address"
          label="Address"
          value={editedData.address}
          onChange={handleInputChange}
          fullWidth
        />
        {/* Add other fields for editing */}
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose} color="primary">
          Cancel
        </Button>
        <Button onClick={handleSave} color="primary">
          Save
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default EditEmployee;
