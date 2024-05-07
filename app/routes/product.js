module.exports = (app) => {
  const product = require("../controllers/product.js");
  const { uploadProduct } = require("../models/config.js");
  const express = require("express");
  const router = express.Router();

  // Get quantity of sold products
  router.get("/:productName", product.countSold);

  // Get products 
  router.get("/", product.findAll);

  // Get products image
  router.get("/images/:imageName", product.getImage);

  app.use("/api/v1/products", router);
};
