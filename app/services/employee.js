const { connectDB, sql } = require("../models/config.js");
const fs = require("fs");
const path = require("path");

const Employee = {
  create: async (req, res) => {
    try {
      const {
        cccd,
        address,
        job_type,
        date_of_work,
        gender,
        date_of_birth,
        last_name,
        middle_name,
        first_name,
        super_ssn,
      } = req.body;

      if (!req.file) {
        throw new Error("Image is required");
      }

      const pool = await connectDB();
      const request = pool.request();
      request
        .input("cccd", sql.NVarChar, cccd)
        .input("address", sql.NVarChar, address)
        .input("job_type", sql.NVarChar, job_type)
        .input("date_of_work", sql.DateTime2, date_of_work)
        .input("gender", sql.NVarChar, gender)
        .input("date_of_birth", sql.Date, date_of_birth)
        .input("last_name", sql.NVarChar, last_name)
        .input("middle_name", sql.NVarChar, middle_name)
        .input("first_name", sql.NVarChar, first_name)
        .input(
          "image_url",
          sql.NVarChar,
          `${process.env.URL}/employees/images/${req.file.filename}`
        );

      if (super_ssn) {
        request.input("super_ssn", sql.Int, super_ssn);
      } else {
        request.input("super_ssn", sql.Int, null);
      }

      await request.execute("dbo.proc_InsertEmployee");

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return {
        status: 200,
        message: "Success",
        data: {
          ...req.body,
          imageURL: `${process.env.URL}/employees/images/${req.file.filename}`,
        },
      };
    } catch (error) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      throw new Error(error.message);
    }
  },

  findByFilter: async (req, res) => {
    try {
      const { jobType, gender, phoneNumber, dob } = req.query;
      const page = parseInt(req.query.page) || 1;
      const perPage = parseInt(req.query.perPage) || 10;
      const pool = await connectDB();

      const request = pool.request();
      request.input("page", sql.Int, page).input("per_page", sql.Int, perPage);

      if (jobType) {
        request.input("job_type", sql.NVarChar, jobType);
      }
      if (gender) {
        request.input("gender", sql.NVarChar, gender);
      }
      if (phoneNumber) {
        request.input("phone_number", sql.NVarChar, phoneNumber);
      }
      if (dob) {
        request.input("date_of_birth", sql.Date, dob);
      }

      request.output("total_count", sql.Int);

      const result = await request.execute("dbo.proc_GetEmployeeByFilter");

      const total = result.output.total_count;

      let data = [];
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
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return {
        data,
        total: total,
        page: page,
        perPage: perPage,
        perCurrentPage: data.length,
        totalPage: Math.ceil(total / perPage),
      };
    } catch (error) {
      throw new Error(error.message);
    }
  },

  getImage: async (req, res) => {
    try {
      const { imageName } = req.params;
      const imagePath = path.join(
        __dirname,
        `../../upload/employee/${imageName}`
      );

      res.sendFile(imagePath);
    } catch (error) {
      throw new Error(error.message);
    }
  },

  findOne: async (req, res) => {
    try {
      const { id } = req.params;
      const pool = await connectDB();

      const request = pool.request();
      request.input("ssn", sql.Int, id);

      const [resultEmployee, resultPhone, resultDependent] = await Promise.all([
        request.query(`
            SELECT *
            FROM employee
            WHERE employee.ssn = @ssn;
        `),
        request.query(`
            SELECT phone_number
            FROM employee_phone_number
            WHERE employee_phone_number.ssn = @ssn;
        `),
        request.query(`
            SELECT name, relationship, phone_number, address, date_of_birth, gender, created_at, updated_at
            FROM employee_dependent
            WHERE employee_dependent.ssn = @ssn;
        `),
      ]);

      if (resultEmployee.recordset.length === 0) {
        return {
          status: 404,
          message: "Employee not found",
          data: null,
        };
      }

      const employee = {
        ...resultEmployee.recordset[0],
        phone_numbers:
          resultPhone.recordset.length == 0
            ? null
            : resultPhone.recordset.map((item) => item.phone_number),
        dependents:
          resultDependent.recordset == 0
            ? null
            : resultDependent.recordset.map((item) => ({
                name: item.name,
                relationship: item.relationship,
                phone_number: item.phone_number,
                address: item.address,
                date_of_birth: item.date_of_birth,
                gender: item.gender,
              })),
      };

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return {
        status: 200,
        message: "Success",
        data: employee,
      };
    } catch (error) {
      throw new Error(error.message);
    }
  },

  update: (req, res) => {
    res.json({ message: "Update an employee with id." });
  },

  delete: (req, res) => {
    res.json({ message: "Delete an employee with id." });
  },
};

module.exports = Employee;
