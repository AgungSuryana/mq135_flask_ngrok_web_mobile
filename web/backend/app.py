from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import datetime

app = Flask(__name__)
CORS(app) 

# Koneksi ke MongoDB
client = MongoClient("mongodb://localhost:27017/") 
db = client["sensor_data"]
collection = db["mq135"]

# Endpoint untuk menerima data dari ESP32
@app.route('/api/sensor', methods=['POST'])
def receive_sensor_data():
    data = request.get_json() 
    if "gasLevel" not in data:
        return jsonify({"error": "Data tidak lengkap"}), 400

    gas_level = data["gasLevel"]
    timestamp = datetime.datetime.now()
    collection.insert_one({
        "gasLevel": gas_level,
        "timestamp": timestamp
    })

    return jsonify({"message": "Data berhasil disimpan"}), 200

# Endpoint untuk mengambil data sensor dari MongoDB
@app.route('/api/data', methods=['GET'])
def get_sensor_data():
    data = list(collection.find().sort("timestamp", -1).limit(10))
    result = []

    for d in data:
        result.append({
            "gasLevel": d["gasLevel"],
            "timestamp": d["timestamp"].isoformat() 
        })

    return jsonify(result)

# Menjalankan aplikasi Flask
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
