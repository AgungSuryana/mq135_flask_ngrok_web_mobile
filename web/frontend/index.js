const express = require('express');
const axios = require('axios');
const path = require('path');
const app = express();
const port = 3000;

// Serve static HTML
app.use(express.static(path.join(__dirname, 'public')));

// Route untuk mengambil data dari Flask API
app.get('/api/data', async (req, res) => {
    try {
        const response = await axios.get('https://f580-125-164-25-162.ngrok-free.app/api/data');  // URL API Flask
        res.json(response.data);
    } catch (error) {
        console.error('Error fetching data from Flask API:',);
        res.status(500).json({ error: 'Gagal mengambil data' });
    }
});

// Menjalankan server
app.listen(port, () => {
    console.log(`Server frontend berjalan di http://localhost:${port}`);
});
