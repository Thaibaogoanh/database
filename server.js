const express = require("express");
const cors = require("cors");

require("dotenv").config();

const app = express();

app.use(cors());

app.use(express.json());

app.use(
  express.urlencoded({
    extended: true,
  })
);

app.get("/", (req, res) => {
  res.json({ message: "Coffee Management Dashboard." });
});

const swaggerUi = require("swagger-ui-express");
const swaggerDocument = require("./swagger.json");

// Swagger UI
app.use("/api/v1/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

require("./app/models/connection.js");
require("./app/routes/employee.js")(app);
require("./app/routes/product.js")(app);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT} ✨`);
});
