const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const PDFDocument = require('pdfkit');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Data storage
let users = [];

// Log user activity (only for users)
app.post('/log', (req, res) => {
  const { name, ip } = req.body;
  const time = new Date().toLocaleString();
  const status = "Online";

  // Check if user exists
  let user = users.find(u => u.ip === ip);
  if (!user) {
    user = { name, ip, logs: [] };
    users.push(user);
  }

  user.logs.push({ status, time });

  res.json({ message: 'Log updated successfully', users });
});

// Fetch all logs (Admin only)
app.get('/logs', (req, res) => {
  res.json(users);
});

// Generate PDF for all logs (Admin only)
app.get('/download/pdf', (req, res) => {
  const doc = new PDFDocument();
  const fileName = 'user_logs.pdf';
  const filePath = `./${fileName}`;

  doc.pipe(fs.createWriteStream(filePath));

  doc.fontSize(18).text('User Logs', { align: 'center' });
  doc.moveDown();

  users.forEach(user => {
    doc.fontSize(14).text(`Name: ${user.name}, IP: ${user.ip}`);
    user.logs.forEach(log => {
      doc.text(`  - Status: ${log.status}, Time: ${log.time}`);
    });
    doc.moveDown();
  });

  doc.end();

  res.download(filePath, fileName, err => {
    if (err) console.error(err);
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});




  
