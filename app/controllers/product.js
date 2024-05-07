const Product = require("../services/product.js");

exports.getImage = async (req, res) => {
  return await Product.getImage(req, res);
};

exports.findAll = async (req, res) => {
  return await Product.findAll(req, res);
};

exports.countSold = async (req, res) => {
  return await Product.countSold(req, res);
}