const { connectDB, sql } = require("../models/config.js");
const fs = require("fs");
const path = require("path");
const _ = require("lodash");

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
        return res.status(400).json({
          status: 400,
          message: "Image is required",
          data: null,
        });
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

      request.output("ssn", sql.Int);

      const result = await request.execute("dbo.proc_InsertEmployee");

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return res.status(200).json({
        status: 200,
        message: "Success",
        data: {
          ssn: result.output.ssn,
          ...req.body,
          super_ssn: super_ssn === "" ? null : super_ssn,
          image_url: `${process.env.URL}/employees/images/${req.file.filename}`,
        },
      });
    } catch (error) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(500).json({
        status: 500,
        message: error.message,
        data: null,
      });
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
          data.push(_.omit(existEmployee, ["created_at", "updated_at"]));
        }
        existEmployee.phone_numbers.push(phone_number);
      });

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return res.status(200).json({
        status: 200,
        message: "Success",
        data,
        total: total,
        page: page,
        perPage: perPage,
        perCurrentPage: data.length,
        totalPage: Math.ceil(total / perPage),
      });
    } catch (error) {
      return res.status(500).json({
        status: 500,
        message: error.message,
        data: null,
      });
    }
  },

  getImage: async (req, res) => {
    try {
      const { imageName } = req.params;
      const imagePath = path.join(
        __dirname,
        `../../upload/employee/${imageName}`
      );

      return res.sendFile(imagePath);
    } catch (error) {
      return res.status(500).json({
        status: 500,
        message: error.message,
        data: null,
      });
    }
  },

  findById: async (req, res) => {
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
        return res.status(404).json({
          status: 404,
          message: "Employee not found",
          data: null,
        });
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

      res.status(200).json({
        status: 200,
        message: "Success",
        data: _.omit(employee,['created_at', 'updated_at']),
      });
    } catch (error) {
      return res.status(500).json({
        status: 500,
        message: error.message,
        data: null,
      });
    }
  },

  update: async (req, res) => {
    try {
      const { id } = req.params;
      const { cccd, address, job_type, date_of_birth, super_ssn } = req.body;

      const pool = await connectDB();
      const request = pool.request();

      const oldImageResult = await request.query(
        `SELECT image_url FROM employee WHERE ssn = ${id}`
      );

      if (oldImageResult.recordset.length === 0) {
        return res.status(404).json({
          status: 404,
          message: "Employee not found",
          data: null,
        });
      }

      const oldImageUrl = oldImageResult.recordset[0].image_url;

      if (req.file && oldImageUrl) {
        const oldImageFileName = oldImageUrl.split("/").pop();
        const oldImagePath = path.join(
          __dirname,
          "../../upload/employee",
          oldImageFileName
        );
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath);
        }
      }

      if (req.file) {
        request.input(
          "image_url",
          sql.NVarChar,
          `${process.env.URL}/employees/images/${req.file.filename}`
        );
      }

      request.input("ssn", sql.Int, id);

      if (cccd && cccd !== "") {
        request.input("cccd", sql.NVarChar, cccd);
      }

      if (address && address !== "") {
        request.input("address", sql.NVarChar, address);
      }

      if (job_type && job_type !== "") {
        request.input("job_type", sql.NVarChar, job_type);
      }

      if (date_of_birth && date_of_birth !== "") {
        request.input("date_of_birth", sql.Date, date_of_birth);
      }

      if (super_ssn && super_ssn !== "") {
        request.input("super_ssn", sql.Int, super_ssn);
      }

      await request.execute("dbo.proc_UpdateEmployee");

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return res.status(200).json({
        status: 200,
        message: "Success",
        data: {
          ssn: Number(id),
          cccd: cccd === "" ? null : cccd,
          address: address === "" ? null : address,
          job_type: job_type === "" ? null : job_type,
          date_of_birth: date_of_birth === "" ? null : date_of_birth,
          super_ssn: super_ssn === "" ? null : Number(super_ssn),
          image_url: req.file
            ? `${process.env.URL}/employees/images/${req.file.filename}`
            : oldImageUrl,
        },
      });
    } catch (error) {
      if (req.file) fs.unlinkSync(req.file.path);
      return res.status(500).json({
        status: 500,
        message: error.message,
        data: null,
      });
    }
  },

  delete: async (req, res) => {
    try {
      const { ids } = req.body;
      const pool = await connectDB();
      const request = pool.request();

      const imageUrlsResult = await request.query(`
      SELECT image_url FROM employee WHERE ssn IN (${ids.join(",")})
    `);

      const imageUrls = imageUrlsResult.recordset
        .map((record) => record.image_url)
        .filter((imageUrl) => imageUrl !== null);

      const table = new sql.Table();
      table.columns.add("SSN", sql.Int);

      ids.forEach((id) => {
        table.rows.add(id);
      });

      request.input("SSNs", table);

      await request.execute("dbo.proc_DeleteEmployees");

      imageUrls.forEach((imageUrl) => {
        const imageName = imageUrl.split("/").pop();
        const imagePath = path.join(
          __dirname,
          "../../upload/employee",
          imageName
        );
        if (fs.existsSync(imagePath)) {
          fs.unlinkSync(imagePath);
        }
      });

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return res.status(200).json({
        status: 200,
        message: "Success",
        data: null,
      });
    } catch (error) {
      return res.status(500).json({
        status: 500,
        message: error.message,
        data: null,
      });
    }
  },
};

module.exports = Employee;
