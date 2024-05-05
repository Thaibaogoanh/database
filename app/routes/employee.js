module.exports = (app) => {
  const employee = require("../controllers/employee.js");
  const { uploadEmployee, uploadProduct } = require("../models/config.js");
  const express = require("express");
  const router = express.Router();

  // Create a new employee
  router.post("/", uploadEmployee.single("image"), employee.create);

  // Fitler employees with job type
  router.get("/", employee.findByFilter);

  // Get employees image
  router.get("/images/:imageName", employee.getImage);

  // Get an employee with id
  router.get("/:id", employee.findById);

  // Update an employee with id
  router.put("/:id", uploadEmployee.single("image"), employee.update);

  // Delete employees with ids
  router.delete("/", employee.delete);

  app.use("/api/v1/employees", router);
};
