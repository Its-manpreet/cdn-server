const express = require('express');
const fileUpload = require('express-fileupload');
const path = require('path');
const fs = require('fs');

const app = express();

// Enable file uploads
app.use(fileUpload());

// Serve uploaded files
app.use('/files', express.static(path.join(__dirname, 'uploads')));

// Handle file uploads
app.post('/upload', (req, res) => {
  if (!req.files || Object.keys(req.files).length === 0) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const file = req.files.file;

  // Move the uploaded file to a desired location
  const uploadPath = path.join(__dirname, 'uploads', file.name);
  file.mv(uploadPath, (err) => {
    if (err) {
      return res.status(500).json({ error: 'Error uploading file' });
    }

    res.json({ message: 'File uploaded successfully' });
  });
});

// Handle file deletion
app.delete('/delete/:filename', (req, res) => {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, 'uploads', filename);

  fs.unlink(filePath, (err) => {
    if (err) {
      console.error('Failed to delete file:', err);
      res.status(500).send('Failed to delete file');
    } else {
      console.log('File deleted:', filename);
      res.sendStatus(200);
    }
  });
});

// Start the server
const port = 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
