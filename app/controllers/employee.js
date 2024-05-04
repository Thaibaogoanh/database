const Employee = require("../services/employee.js");

exports.create = async (req, res) => {
  return await Employee.create(req, res);
};

exports.getImage = async (req, res) => {
  return await Employee.getImage(req, res);
};

exports.findById = async (req, res) => {
  return await Employee.findById(req, res);
};

exports.update = async (req, res) => {
  return await Employee.update(req, res);
};

exports.delete = async (req, res) => {
  return await Employee.delete(req, res);
};

exports.findByFilter = async (req, res) => {
  return await Employee.findByFilter(req, res);
};
