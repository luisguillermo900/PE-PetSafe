/*
**MENSAJES JSON
configuracion umbrales
{
  "umbralInferiorIluminancia": float,
  "umbralSuperiorIluminancia": float,
  "umbralInferiorTemperatura": float,
  "umbralSuperiorIluminancia": float,
}
control reles
{
  "iluminacionManual": true/false,
  "ventilacionManual": true/false,
  "ventilacionEncendida": true/false,
  "iluminacionEncendida": true/false,
}

mensajes de cambio de estado
{
  "dispositivo": iluminacion/ventilacion,
  "estado": enciendido/apagado,
  "hora y fecha": dd/mm/aa hh:mm,
}
*/

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <BH1750.h>
#include "secrets.h"
 
#define PIN_DHT11 4 //Pin del sensor DHT11
#define PIN_RELE_1 26 //Pin IN1 del relé (Iluminacion)
#define PIN_RELE_2 27 //Pin IN2 del relé (Ventilacion)
#define PIN_SDA_BH1750 18 //Pin "data" del sensor BH1750
#define PIN_SCL_BH1750 19 //Pin "clock" del sensor BH1750
#define DHTTYPE DHT11 // Tipo de sensor

#define AWS_IOT_PUBLISH_TOPIC_RELAY_CONTROL "esp32/control_reles"
#define AWS_IOT_PUBLISH_TOPIC_THRESHOLD_CONTROL "esp32/config_umbrales"
#define AWS_IOT_SUBSCRIBE_TOPIC_ESP_DATA "esp32/datos_esp32"
#define AWS_IOT_SUBSCRIBE_TOPIC_RELAY_STATUS "esp32/estado_reles"

long lastMsg = 0;
char msg[50];
int value = 0;

// Valores de medicion
float t = 0;
float h = 0;
float l = 0;

// Valores de configuracion
bool iluminacionManual = false;
bool ventilacionManual = false;
bool rele1Encendido = false;
bool rele2Encendido = false;
float umbralInferiorIluminancia = 5.0;
float umbralSuperiorIluminancia = 30.00;
float umbralSuperiorTemperatura = 28.0;
float umbralInferiorTemperatura = 17.0;
 
// Definiendo el sensor DHT11 y el BH1750
BH1750 luxometro;
DHT dht(PIN_DHT11, DHTTYPE);

WiFiClientSecure espClient = WiFiClientSecure();
PubSubClient client(espClient);

void setup() {
  // Control de los pines del rele
  pinMode(PIN_RELE_1, OUTPUT);
  pinMode(PIN_RELE_2, OUTPUT);
  // Reles establecidos como apagado
  digitalWrite(PIN_RELE_1, HIGH);
  digitalWrite(PIN_RELE_2, HIGH);
  rele1Encendido = false;
  rele2Encendido = false;
  // Inicializando comunicación serie
  Serial.begin(9600);
  // Inicializando sensor DHT y BH1750
  Wire.begin(PIN_SDA_BH1750, PIN_SCL_BH1750);
  luxometro.begin(BH1750::CONTINUOUS_HIGH_RES_MODE);
  dht.begin();

  coneccion_wifi();
  espClient.setCACert(AWS_CERT_CA);
  espClient.setCertificate(AWS_CERT_CRT);
  espClient.setPrivateKey(AWS_CERT_PRIVATE);
  client.setServer(AWS_IOT_ENDPOINT, 8883);
  client.setCallback(callback);
}

String obtenerTiempo() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    return "00/00/00 00:00:00";  // fallback
  }
  char buffer[25];
  strftime(buffer, sizeof(buffer), "%d/%m/%y %H:%M:%S", &timeinfo);
  return String(buffer);
}

void coneccion_wifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println(WiFi.localIP());
  Serial.println();
}

void publicarEstadoRele(const char* dispositivo, const char* estado, const char* modo) {
  StaticJsonDocument<200> doc;
  doc["dispositivo"] = dispositivo;
  doc["estado"] = estado;
  doc["modo"] = modo;
  doc["tiempo"] = obtenerTiempo();
  char estadoRele[512];
  serializeJson(doc, estadoRele);
  client.publish(AWS_IOT_SUBSCRIBE_TOPIC_RELAY_STATUS, estadoRele);
}

void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
  String messageTemp;
  
  for (int i = 0; i < length; i++) {
    Serial.print((char)message[i]);
    messageTemp += (char)message[i];
  }
  Serial.println();

  // Feel free to add more if statements to control more GPIOs with MQTT

  // If a message is received on the topic esp32/output, you check if the message is either "on" or "off". 
  // Changes the output state according to the message
  if (String(topic) == AWS_IOT_PUBLISH_TOPIC_RELAY_CONTROL) {
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, messageTemp);
    if (error) {
      Serial.print("Error al parsear JSON: ");
      Serial.println(error.f_str());
      return;
    }
    // Leer los valores del JSON
    iluminacionManual = doc["iluminacionManual"];
    bool iluminacionEncendida = doc["iluminacionEncendida"];

    Serial.print("iluminacionManual: ");
    Serial.println(iluminacionManual);
    Serial.print("iluminacionEncendida: ");
    Serial.println(iluminacionEncendida);
    Serial.print("Changing output to ");
    if (iluminacionManual) {
      if (iluminacionEncendida && !rele1Encendido) {
        digitalWrite(PIN_RELE_1, LOW);  // Encender
        rele1Encendido = true;
        Serial.println("Relé iluminación ENCENDIDO (manual)");
        publicarEstadoRele("iluminacion", "encendido", "manual");
      } else if (!iluminacionEncendida && rele1Encendido){
        digitalWrite(PIN_RELE_1, HIGH); // Apagar
        rele1Encendido = false;
        Serial.println("Relé iluminación APAGADO (manual)");
        publicarEstadoRele("iluminacion", "apagado", "manual");
      }
    } else {
      Serial.println("Modo automático, no se controla manualmente.");
    }

    ventilacionManual = doc["ventilacionManual"];
    bool ventilacionEncendida = doc["ventilacionEncendida"];

    if (ventilacionManual) {
      if (ventilacionEncendida && !rele2Encendido) {
        digitalWrite(PIN_RELE_2, LOW);  // Encender
        rele2Encendido = true;
        Serial.println("Relé ventilacion ENCENDIDO (manual)");
        publicarEstadoRele("ventilacion", "encendido", "manual");
      } else if (!ventilacionEncendida && rele2Encendido){
        digitalWrite(PIN_RELE_2, HIGH); // Apagar
        rele2Encendido = false;
        Serial.println("Relé ventilacion APAGADO (manual)");
        publicarEstadoRele("ventilacion", "apagado", "manual");
      }
    } else {
      Serial.println("Modo automático, no se controla manualmente.");
    }
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    Serial.println(WiFi.localIP());
    // Attempt to connect
    if (client.connect(THINGNAME)) {
      Serial.println("connected");
      // Subscribe
      client.subscribe(AWS_IOT_PUBLISH_TOPIC_RELAY_CONTROL);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
    // Esperamos 5 segundos entre medidas
  long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    t = dht.readTemperature();
    h = dht.readHumidity();
    l = luxometro.readLightLevel();
    StaticJsonDocument<200> doc;
    doc["temperatura"] = String(t, 2);
    doc["humedad"] = String(h, 1);
    doc["iluminancia"] = String(l, 1);
    char datosESP32[512];
    serializeJson(doc, datosESP32);
    client.publish(AWS_IOT_SUBSCRIBE_TOPIC_ESP_DATA, datosESP32);
    Serial.println("Temperatura: " + String(t, 2) + "°C Humedad: " + String(h, 1) + "%");
    Serial.println("Iluminancia: " + String(l, 1) + "lux");
    if (!iluminacionManual) {
      /*{
        "dispositivo": iluminacion/ventilacion,
        "estado": enciendido/apagado,
        "hora y fecha": dd/mm/aa hh:mm,
      }*/
      if (l < umbralInferiorIluminancia && !rele1Encendido) {
        digitalWrite(PIN_RELE_1, LOW); // Encender relé
        rele1Encendido = true;
        Serial.println("Encender relé");
        publicarEstadoRele("iluminacion", "encendido", "automatico");
      } else if (l > umbralSuperiorTemperatura && rele1Encendido) {
        digitalWrite(PIN_RELE_1, HIGH);  // Apagar relé
        rele1Encendido = false;
        Serial.println("Apagar relé");
        publicarEstadoRele("iluminacion", "apagado", "automatico");
      }
    }
    if (!ventilacionManual) {
      if (t > umbralSuperiorTemperatura && !rele2Encendido) {
        digitalWrite(PIN_RELE_2, LOW); // Encender relé
        rele2Encendido = true;
        Serial.println("Encender relé");
        publicarEstadoRele("ventilacion", "encendido", "automatico");
      } else if (t < umbralInferiorTemperatura && rele2Encendido) {
        digitalWrite(PIN_RELE_2, HIGH);  // Apagar relé
        rele2Encendido = false;
        Serial.println("Apagar relé");
        publicarEstadoRele("ventilacion", "apagado", "automatico");
      }
    }
  }
}