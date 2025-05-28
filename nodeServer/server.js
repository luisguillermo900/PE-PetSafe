const mqtt = require('mqtt')
const host = 'localhost'
const port = '1883'
const topic = 'dispositivo/gps'
const connectUrl = `mqtt://${host}:${port}`

const client = mqtt.connect(connectUrl);

client.on('connect', () => {
  console.log('Conectado el broker MQTT');
  client.subscribe(topic, (err) => {
    if (!err) {
      console.log(`Suscrito al topico ${topic}`);
    }
  });
  client.publish(topic, 'Hola desde el cliente MQTT');
});

client.on('message', (topic, message) => {
  console.log('Mensaje recibido en el topico:', topic);
  console.log('Contenido del mensaje:', message.toString());
});

client.on('error', (err) => {
  console.error('Error en el cliente MQTT:', err);
});