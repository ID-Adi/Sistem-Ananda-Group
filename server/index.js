require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Debugging
console.log('Current directory:', __dirname);
const projectRoot = path.resolve(__dirname, '..');
console.log('Project root:', projectRoot);

// Middleware
app.use(cors({
  origin: ['http://localhost:5173', 'http://127.0.0.1:5173', 'http://localhost:3000'],
  credentials: true
}));
app.use(express.json());
app.use(morgan('dev'));

// Cek apakah direktori client/dist ada
const clientDistPath = path.resolve(__dirname, '../client/dist');
console.log('Looking for client dist at:', clientDistPath);

if (fs.existsSync(clientDistPath)) {
  console.log(`Client dist path ditemukan: ${clientDistPath}`);
  // Serve static files from the client/dist directory
  app.use(express.static(clientDistPath));
} else {
  console.error(`Error: Client dist path tidak ditemukan: ${clientDistPath}`);
  
  // List directories untuk debugging
  const clientPath = path.resolve(__dirname, '../client');
  if (fs.existsSync(clientPath)) {
    console.log('Client directory exists. Contents:');
    fs.readdirSync(clientPath).forEach(file => {
      console.log(` - ${file}`);
    });
  } else {
    console.error('Client directory does not exist');
  }
}

// API Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server berjalan dengan baik' });
});

// Contoh endpoint untuk data akuntansi (dummy)
app.get('/api/accounting/summary', (req, res) => {
  // Nantinya data ini akan diambil dari Supabase
  res.json({
    totalRevenue: 15000000,
    totalExpenses: 7500000,
    netProfit: 7500000,
    lastUpdated: new Date().toISOString()
  });
});

// Contoh endpoint untuk data inventory (dummy)
app.get('/api/inventory/summary', (req, res) => {
  // Nantinya data ini akan diambil dari Supabase
  res.json({
    totalItems: 250,
    lowStockItems: 15,
    totalValue: 25000000,
    lastUpdated: new Date().toISOString()
  });
});

// Fallback route for SPA (Single Page Application)
app.get('*', (req, res) => {
  const indexPath = path.join(clientDistPath, 'index.html');
  console.log('Looking for index.html at:', indexPath);
  
  if (fs.existsSync(indexPath)) {
    console.log('Index file found, serving:', indexPath);
    res.sendFile(indexPath);
  } else {
    console.error('Index file not found at:', indexPath);
    res.status(404).send(`File not found: ${indexPath}`);
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err.stack);
  res.status(500).json({ error: 'Terjadi kesalahan pada server!' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server berjalan di port ${PORT}`);
});
