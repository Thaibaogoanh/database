module.exports = (app) => {
  const employees = require("../controllers/employee.js");
  const { uploadEmployee, uploadProduct } = require("../models/config.js");
  const express = require("express");
  const router = express.Router();

  // Create a new employee
  router.post("/", uploadEmployee.single("image"), employees.create);

  // Fitler employees with job type
  router.get("/", employees.findByFilter);

  // Get employees image
  router.get("/images/:imageName", employees.getImage);

  // Get an employee with id
  router.get("/:id", employees.findOne);

  // Update an employee with id
  router.put("/:id", employees.update);

  // Delete an employee with id
  router.delete("/:id", employees.delete);

  app.use("/api/v1/employees", router);
};
