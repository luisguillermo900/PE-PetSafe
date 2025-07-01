#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <BH1750.h>
#include "secrets.h"
 
#define PIN_DHT11 4 //Pin del sensor DHT11
#define PIN_RELE_1 26 //Pin IN1 del relé
#define PIN_RELE_2 27 //Pin IN2 del relé
#define PIN_SDA_BH1750 18 //Pin "data" del sensor BH1750
#define PIN_SCL_BH1750 19 //Pin "clock" del sensor BH1750
#define DHTTYPE DHT11 // Tipo de sensor

#define AWS_IOT_PUBLISH_TOPIC   "esp32/control_reles"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/datos_esp32"

long lastMsg = 0;
char msg[50];
int value = 0;

float t = 0;
float h = 0;
float l = 0;
bool modoManual = false;
float umbralLux = 5.0;
 
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

void coneccion_wifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println(WiFi.localIP());
  Serial.println();
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
  if (String(topic) == AWS_IOT_PUBLISH_TOPIC) {
    Serial.print("Changing output to ");
    if(messageTemp == "on"){
      Serial.println("on");
      digitalWrite(PIN_RELE_1, HIGH);
    }
    else if(messageTemp == "off"){
      Serial.println("off");
      digitalWrite(PIN_RELE_1, LOW);
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
      client.subscribe(AWS_IOT_PUBLISH_TOPIC);
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
  if (now - lastMsg > 5000) {
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
    client.publish(AWS_IOT_SUBSCRIBE_TOPIC, datosESP32);
    Serial.println("Temperatura: " + String(t, 2) + "°C Humedad: " + String(h, 1) + "%");
    Serial.println("Iluminancia: " + String(l, 1) + "lux");
    if (!modoManual && l < umbralLux) {
      digitalWrite(PIN_RELE_1, LOW); // Encender relé
    } else {
      digitalWrite(PIN_RELE_1, HIGH);  // Apagar relé
    }
  }
}