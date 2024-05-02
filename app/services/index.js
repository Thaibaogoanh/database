const { connectDB, sql } = require("../models/config.js");

const Employee = {
  create: (req, res) => {
    res.json({ message: "Create a new employee." });
  },

  filterByJobType: async (req, res) => {
    try {
      const jobType = req.query.jobType;
      const pool = await connectDB();
      const result = await pool
        .request()
        .input("job_type", sql.NVarChar, jobType)
        .execute("dbo.proc_GetEmployeeByJobType");

      const data = [];
      const resultMap = new Map();

      result.recordset.forEach(({ ssn, phone_number, ...rest }) => {
        let existEmployee = resultMap.get(ssn);
        if (!existEmployee) {
          existEmployee = { ssn, ...rest, phone_numbers: [] };
          resultMap.set(ssn, existEmployee);
          data.push(existEmployee);
        }
        existEmployee.phone_numbers.push(phone_number);
      });

      const timestamp = new Date().toISOString();
      console.log(`[${timestamp}] http: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`);
      
      return data;
    } catch (error) {
      throw new Error(error.message);
    }
  },

  findAll: (req, res) => {
    res.json({ message: "Get all employees." });
  },

  findOne: (req, res) => {
    res.json({ message: "Get an employee with id." });
  },

  update: (req, res) => {
    res.json({ message: "Update an employee with id." });
  },

  delete: (req, res) => {
    res.json({ message: "Delete an employee with id." });
  },
};

module.exports = Employee;
