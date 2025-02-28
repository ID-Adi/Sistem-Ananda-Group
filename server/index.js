require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
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

// Start server
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});
