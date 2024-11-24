#include <WiFi.h>
#include <HTTPClient.h>

#define WIFI_SSID "AGUNG"            // Ganti dengan SSID Wi-Fi kamu
#define WIFI_PASSWORD "agungsuryana18"    // Ganti dengan password Wi-Fi kamu

// Pin sensor MQ-135
#define MQ135_PIN 34  // Pin untuk sensor MQ-135 (sesuaikan dengan pin yang digunakan)

// URL API Flask (ganti dengan URL NGROK atau server Flask lokal)
const char* serverUrl = "https://e455-125-164-21-68.ngrok-free.app/api/sensor";  // Ganti dengan URL NGROK atau IP server Flask

void setup() {
  Serial.begin(115200);

  // Menghubungkan ke Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  // Menunggu koneksi Wi-Fi
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Mencoba terhubung ke WiFi...");
  }
  Serial.println("Terhubung ke WiFi");
}

void loop() {
  // Memeriksa status koneksi Wi-Fi
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    // Membaca nilai sensor MQ-135
    int gasLevel = analogRead(MQ135_PIN);  // Membaca nilai analog dari sensor MQ-135
    float voltage = gasLevel * (3.3 / 1023.0);  // Menghitung tegangan (0-3.3V)

    // Membuat objek JSON untuk dikirimkan ke Flask
    String jsonData = "{\"gasLevel\": " + String(gasLevel) + ", \"voltage\": " + String(voltage) + "}";

    // Mengirim data ke server Flask
    http.begin(serverUrl);  // Tentukan URL endpoint API Flask
    http.addHeader("Content-Type", "application/json");  // Header untuk JSON

    int httpResponseCode = http.POST(jsonData);  // Mengirim data ke server Flask

    if (httpResponseCode == 200) {
      Serial.println("Data berhasil dikirim!");
    } else {
      Serial.println("Gagal mengirim data");
    }

    http.end();
  }

  // Delay 10 detik sebelum mengirim data lagi
  delay(10000);
}
