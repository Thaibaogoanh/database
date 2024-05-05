const { connectDB, sql } = require("../models/config.js");
const fs = require("fs");
const path = require("path");
const _ = require("lodash");

const Product = {
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
        `../../upload/product/${imageName}`
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
};

module.exports = Product;
