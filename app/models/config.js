const sql = require("mssql");

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
  } catch (error) {
    console.error("💀 Error closing connection:", error);
  }
};

module.exports = {
  connectDB,
  closeDB,
  sql,
};
