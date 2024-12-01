#include <WiFi.h>
#include <HTTPClient.h>

#define WIFI_SSID "AGUNG"            
#define WIFI_PASSWORD "agungsuryana18"  

#define MQ135_PIN 34  

// URL API Flask (ganti dengan URL NGROK atau server Flask lokal)
const char* serverUrl = "https://072f-125-164-20-239.ngrok-free.app/api/sensor";  

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Mencoba terhubung ke WiFi...");
  }
  Serial.println("Terhubung ke WiFi");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    int gasLevel = analogRead(MQ135_PIN);  
    Serial.print("Gas Level yang dikirim: ");
    Serial.println(gasLevel);

    // Membuat objek JSON untuk dikirimkan ke Flask
    String jsonData = "{\"gasLevel\": " + String(gasLevel) + "}";

    // Mengirim data ke server Flask
    http.begin(serverUrl);  
    http.addHeader("Content-Type", "application/json");  

    int httpResponseCode = http.POST(jsonData); 

    if (httpResponseCode == 200) {
      Serial.println("Data berhasil dikirim!");
    } else {
      Serial.print("Gagal mengirim data. Kode respons: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("Tidak terhubung ke WiFi!");
  }
  delay(10000);
}
