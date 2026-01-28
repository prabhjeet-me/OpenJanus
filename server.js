import express from "express";
const app = express();
const port = process.env.DEV_SERVER_PORT;

app.use(express.static("container/html"));

app.listen(port, () => {
  console.log(`🚀 HTML development server running at http://localhost:${port}`);
});
