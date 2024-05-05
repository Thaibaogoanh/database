const Product = require("../services/product.js");

exports.getImage = async (req, res) => {
  return await Product.getImage(req, res);
};

exports.findByFilter = async (req, res) => {
  return await Product.findByFilter(req, res);
};
