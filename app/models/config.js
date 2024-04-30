const mysql = require("mysql");
const fs = require("fs");

// Create a MySQL connection
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});

const sqlScript = fs.readFileSync("./app/models/db.sql", "utf8");

const sqlStatements = sqlScript.split(';').filter(statement => statement.trim());

// Connect to the MySQL server
connection.connect((err) => {
  if (err) throw err;
  console.log("Connected to MySQL server");

  // Execute each SQL statement separately
  sqlStatements.forEach((sqlStatement) => {
    connection.query(sqlStatement, (err, result) => {
      if (err) throw err;
      console.log("SQL statement executed successfully");
    });
  });

  connection.end();
});

module.exports = connection;