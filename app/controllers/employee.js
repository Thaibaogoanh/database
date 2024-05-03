const Employee = require("../services/employee.js");

exports.create = (req, res) => {
  res.json({ message: "Create a new employee." });
};

exports.findAll = (req, res) => {
  res.json({ message: "Get all employees." });
};

exports.findOne = (req, res) => {
  res.json({ message: "Get an employee with id." });
};

exports.update = (req, res) => {
  res.json({ message: "Update an employee with id." });
};

exports.delete = (req, res) => {
  res.json({ message: "Delete an employee with id." });
};

exports.findByFilter = async (req, res) => {
  try {
    const data = await Employee.findByFilter(req, res);
    res.json({
      status: 200,
      message: "Success",
      data,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
