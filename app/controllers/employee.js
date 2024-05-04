const Employee = require("../services/employee.js");

exports.create = async (req, res) => {
  try {
    const data = await Employee.create(req, res);
    res.status(201).json(data);
  } catch (error) {
    res.status(500).json({
      status: 500,
      message: error.message,
      data: {
        ...req.body,
      },
    });
  }
};

exports.getImage = async (req, res) => {
  try {
    await Employee.getImage(req, res);
    return;
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.findById = async (req, res) => {
  try {
    const data = await Employee.findById(req, res);
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.update = async (req, res) => {
  try {
    const data = await Employee.update(req, res);
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.delete = async (req, res) => {
  try {
    const data = await Employee.delete(req, res);
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.findByFilter = async (req, res) => {
  try {
    const data = await Employee.findByFilter(req, res);
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
