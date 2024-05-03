const sql = require("mssql");
const fs = require("fs");
const multer = require("multer");

const employeeStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = "upload/employee";
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, "upload/employee");
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const uploadEmployee = multer({ storage: employeeStorage });

const productStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = "upload/product";
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, "upload/product");
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const uploadProduct = multer({ storage: productStorage });

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  options: {
    encrypt: false,
  },
};

const connectDB = async () => {
  try {
    const pool = await sql.connect(config);
    return pool;
  } catch (error) {
    console.error("💀 Error connecting to MSSQL:", error);
  }
};

const closeDB = async () => {
  try {
    await sql.close();
    console.log("💀 Somethings wrong with the connection");
  } catch (error) {
    console.error("💀 Error closing connection:", error);
  }
};

module.exports = {
  connectDB,
  closeDB,
  sql,
  uploadEmployee,
  uploadProduct,
};
