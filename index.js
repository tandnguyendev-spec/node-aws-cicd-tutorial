require('dotenv').config()
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const master = process.env.MASTER || 'default';

app.get('/', (req, res) => {
  res.send(`Hello World!, master: ${master}`);
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});