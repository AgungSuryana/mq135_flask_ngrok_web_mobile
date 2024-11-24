from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import datetime

# Inisialisasi aplikasi Flask
app = Flask(__name__)
CORS(app)  # Menambahkan CORS agar frontend bisa mengakses API ini

# Koneksi ke MongoDB
client = MongoClient("mongodb://localhost:27017/")  # Pastikan MongoDB berjalan di localhost:27017
db = client["sensor_data"]
collection = db["mq135"]

# Endpoint untuk menerima data dari ESP32
@app.route('/api/sensor', methods=['POST'])
def receive_sensor_data():
    data = request.get_json()  # Mendapatkan data JSON dari request POST

    # Memeriksa apakah data yang diperlukan ada dalam request
    if "gasLevel" not in data or "voltage" not in data:
        return jsonify({"error": "Data tidak lengkap"}), 400

    gas_level = data["gasLevel"]
    voltage = data["voltage"]
    timestamp = datetime.datetime.now()

    # Menyimpan data ke MongoDB
    collection.insert_one({
        "gasLevel": gas_level,
        "voltage": voltage,
        "timestamp": timestamp
    })

    return jsonify({"message": "Data berhasil disimpan"}), 200

# Endpoint untuk mengambil data sensor dari MongoDB
@app.route('/api/data', methods=['GET'])
def get_sensor_data():
    data = list(collection.find().sort("timestamp", -1).limit(10))  # Mengambil 10 data terbaru
    result = []

    for d in data:
        result.append({
            "gasLevel": d["gasLevel"],
            "voltage": d["voltage"],
            "timestamp": d["timestamp"].isoformat()  # Format ISO untuk timestamp
        })

    return jsonify(result)

# Menjalankan aplikasi Flask
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
