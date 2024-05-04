module.exports = (app) => {
  const employees = require("../controllers/employee.js");
  const { uploadEmployee, uploadProduct } = require("../models/config.js");
  const express = require("express");
  const router = express.Router();
  const swaggerUi = require("swagger-ui-express");
  const swaggerDocument = require("../../swagger.json");

  // Swagger UI
  router.use("/api-docs", swaggerUi.serve);
  router.get("/api-docs", swaggerUi.setup(swaggerDocument));

  // Create a new employee
  router.post("/", uploadEmployee.single("image"), employees.create);

  // Fitler employees with job type
  router.get("/", employees.findByFilter);

  // Get employees image
  router.get("/images/:imageName", employees.getImage);

  // Get an employee with id
  router.get("/:id", employees.findById);

  // Update an employee with id
  router.put("/:id", uploadEmployee.single("image"), employees.update);

  // Delete employees with ids
  router.delete("/", employees.delete);

  app.use("/api/v1/employees", router);
};
