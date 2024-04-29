module.exports = app => {
    const employees = require("../controllers/employee.js");
    const express = require("express");
    const router = express.Router();
  
    // Create a new employee
    router.post("/", employees.create);
  
    // Get all employees
    router.get("/", employees.findAll);
  
    // Get an employee with id
    router.get("/:id", employees.findOne);
  
    // Update an employee with id
    router.put("/:id", employees.update);
  
    // Delete an employee with id
    router.delete("/:id", employees.delete);
  
  
    app.use('/api/v1/employees', router);
  };