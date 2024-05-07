const { connectDB, sql } = require("../models/config.js");
const fs = require("fs");
const path = require("path");
const _ = require("lodash");

const Product = {
  
  countSold: async (req, res) => {
    return 0;
  },

  findAll: async (req, res) => {
    try {
      const { start, end } = req.query;

      let startDate = null;
      let endDate = null;
      if (start) {
        startDate = new Date(start);
      }
      if (end) {
        endDate = new Date(end);
      }

      const pool = await connectDB();
      const request = pool.request();

      const [beverageResult] = await Promise.all([
        request.query(
          `SELECT * 
            FROM beverage
           `
        ),
      ]);

      const beverageData = beverageResult.recordset;

      const sizePromises = beverageData.map((beverage, index) => {
        const paramName = `beverage_name_${index}`;
        return request.input(paramName, beverage.beverage_name).query(
          `SELECT size, price
           FROM size
           WHERE beverage_name = @${paramName}`
        );
      });

      const sizeResults = await Promise.all(sizePromises);

      let data = beverageData.map((beverage, index) => {
        const sizes = sizeResults[index].recordset;
        return {
          ...beverage,
          sizes,
        };
      });

      const totalSoldQuantityPromises = data.flatMap((beverage, i) =>
        beverage.sizes.map((size, j) => {
          return new Promise((resolve, reject) => {
            request
              .input(`beverageName_${i}_${j}`, beverage.beverage_name)
              .input(`size_${i}_${j}`, size.size)
              .input(`startDate_${i}_${j}`, startDate)
              .input(`endDate_${i}_${j}`, endDate)
              .query(
                `
              DECLARE @totalQuantity_${i}_${j} INT;
              SET @totalQuantity_${i}_${j} = dbo.CalculateTotalSoldQuantity(@beverageName_${i}_${j}, @size_${i}_${j}, @startDate_${i}_${j}, @endDate_${i}_${j});
              SELECT @totalQuantity_${i}_${j} AS TotalSoldQuantity;
            `,
                (err, result) => {
                  if (err) {
                    reject(err);
                  } else {
                    resolve(result.recordset[0].TotalSoldQuantity);
                  }
                }
              );
          });
        })
      );

      const totalSoldQuantities = await Promise.allSettled(
        totalSoldQuantityPromises
      );

      data = data.map((beverage, i) => {
        const sizes = beverage.sizes.map((size, j) => {
          return {
            ...size,
            sold_quantity:
              totalSoldQuantities[i * beverage.sizes.length + j].value,
          };
        });

        return {
          ...beverage,
          sizes,
        };
      });

      const timestamp = new Date().toISOString();
      console.log(
        `[${timestamp}] \x1b[32mhttp\x1b[0m: ${req.method} ${req.originalUrl} (${res.statusCode} ms) ${res.statusCode}`
      );

      return res.status(200).json({
        status: 200,
        message: "Success",
        data,
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
