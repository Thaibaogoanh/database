const { closeDB, connectDB } = require("./config.js");
const fs = require("fs");

const sqlScriptPath = "./app/models/db.sql";

async function executeSqlScript() {
  try {
    const sqlScript = fs.readFileSync(sqlScriptPath, "utf8");
    const commands = sqlScript.split(/\bGO\b/);

    const pool = await connectDB();
    console.log("Connected to MSSQL 🎉");
    // Remove last empty command if exists
    if (commands[commands.length - 1].trim() === "") {
      commands.pop();
    }

    for (let i = 0; i < commands.length; i++) {
      await pool.request().query(commands[i]);
    }
    console.log("Database setup completed 🚀");
  } catch (error) {
    console.error("💀 Error executing SQL script:", error);
    await closeDB();
    console.log("Connection to MSSQL is closed 🚪");
  }
}

executeSqlScript();
