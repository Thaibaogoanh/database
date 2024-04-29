const Employee = require("../services/index.js");

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
