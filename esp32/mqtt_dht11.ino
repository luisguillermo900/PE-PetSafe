#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <ESP32Ping.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include "secrets.h"
 
#define DHTPIN 4 //Pin del sensor DHT11
#define LEDPIN 18 //Pin del relé
#define DHTTYPE DHT11 // Tipo de sensor

#define AWS_IOT_PUBLISH_TOPIC   "esp32/control_rele"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/datos_dht11"

long lastMsg = 0;
char msg[50];
int value = 0;

float h = 0;
float t = 0;
float f = 0;
float hif = 0;
float hic = 0;
 
// Inicializamos el sensor DHT11
DHT dht(DHTPIN, DHTTYPE);

WiFiClientSecure espClient = WiFiClientSecure();
PubSubClient client(espClient);

void setup() {
  pinMode(LEDPIN, OUTPUT);
  // Inicializamos comunicación serie
  Serial.begin(9600);
  // Comenzamos el sensor DHT
  dht.begin();

  setup_wifi();

  espClient.setCACert(AWS_CERT_CA);
  espClient.setCertificate(AWS_CERT_CRT);
  espClient.setPrivateKey(AWS_CERT_PRIVATE);

  client.setServer(AWS_IOT_ENDPOINT, 8883);
  client.setCallback(callback);
}

void setup_wifi() {
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println(WiFi.localIP());
    Serial.println("Pinging PC...");
    bool reachable = Ping.ping("192.168.43.125"); // IP de tu PC
    if (reachable) {
      Serial.println(WIFI_SSID);
      Serial.println(WIFI_PASSWORD);
      Serial.println("PC reachable!");
    } else {
      Serial.println(WIFI_SSID);
      Serial.println(WIFI_PASSWORD);
      Serial.println("PC NOT reachable!");
    }
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
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
      digitalWrite(LEDPIN, HIGH);
    }
    else if(messageTemp == "off"){
      Serial.println("off");
      digitalWrite(LEDPIN, LOW);
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
    StaticJsonDocument<200> doc;
    doc["temperatura"] = String(t, 2);
    doc["humedad"] = String(h, 1);
    char datosDht11[512];
    serializeJson(doc, datosDht11);
    client.publish(AWS_IOT_SUBSCRIBE_TOPIC, datosDht11);

    Serial.println("Temperatura: " + String(t, 2) + "°C Humedad: " + String(h, 1) + "%");
  }
}