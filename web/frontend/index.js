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
        const response = await axios.get('https://e455-125-164-21-68.ngrok-free.app/api/data');  // URL API Flask
        res.json(response.data);
    } catch (error) {
        console.error('Error fetching data from Flask API:', error);
        res.status(500).json({ error: 'Gagal mengambil data' });
    }
});

// Menjalankan server
app.listen(port, () => {
    console.log(`Server frontend berjalan di http://localhost:${port}`);
});
