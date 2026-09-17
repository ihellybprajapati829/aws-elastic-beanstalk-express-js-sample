const express = require("express");
const app = express();
const port = 8000;
app.get("/", (req, res) => res.send("Hello World!"));
if (require.main === module) {
  app.listen(port);
  console.log(`App running on http://localhost:${port}`);
}
module.exports = app;
