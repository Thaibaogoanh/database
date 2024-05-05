module.exports = (app) => {
  const product = require("../controllers/product.js");
  const { uploadProduct } = require("../models/config.js");
  const express = require("express");
  const router = express.Router();

  // Fitler employees with job type
//   router.get("/", products.findByFilter);

  // Get employees image
  router.get("/images/:imageName", product.getImage);

  app.use("/api/v1/products", router);
};
