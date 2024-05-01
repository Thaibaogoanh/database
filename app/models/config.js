const sql = require("mssql");
const fs = require("fs");

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  options: {
    encrypt: false,
  },
};

const sqlScriptPath = "./app/models/db.sql";

async function executeSqlScript() {
  try {
    const sqlScript = fs.readFileSync(sqlScriptPath, "utf8");
    const commands = sqlScript.split(/\bGO\b/);

    const pool = await sql.connect(config);

    // Remove last empty command if exists
    if (commands[commands.length - 1].trim() === "") {
      commands.pop();
    }

    for (let i = 0; i < commands.length; i++) {
      await pool.request().query(commands[i]);
      console.log(`Command ${i + 1} executed successfully`);
    }

    await sql.close();
    console.log("Database setup completed.");
  } catch (error) {
    console.error("Error executing commands:", error);
    sql.close();
  }
}

executeSqlScript();

module.exports = sql;
