const express = require('express');
const fs = require('fs');
const path = require('path');
const { Kafka } = require('kafkajs');

const app = express();
// Permite consumir la API desde el frontend Vite (http://localhost:5173)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }
  next();
});
app.use(express.json());
process.env.KAFKAJS_NO_PARTITIONER_WARNING = '1';

const DB_PATH = path.join(__dirname, 'db.json');
const KAFKA_BROKER = process.env.KAFKA_BROKER || 'localhost:9092';
const PORT = Number(process.env.PORT || 3000);

// Inicialización de cliente Kafka
const kafka = new Kafka({
  clientId: 'front-producer',
  brokers: [KAFKA_BROKER]
});
const producer = kafka.producer();
let producerConnected = false;

// Inicializar Productor
async function initProducer() {
  try {
    await producer.connect();
    producerConnected = true;
    console.log(' Conectado exitosamente al Broker de Kafka en: ' + KAFKA_BROKER);
  } catch (error) {
    producerConnected = false;
    console.error(' Fallo al conectar con Kafka:', error);
  }
}
initProducer();

async function ensureProducerConnected() {
  if (producerConnected) {
    return;
  }
  await producer.connect();
  producerConnected = true;
  console.log(' Productor reconectado a Kafka en: ' + KAFKA_BROKER);
}

async function publishTransferMessage(messagePayload) {
  await ensureProducerConnected();

  try {
    await producer.send(messagePayload);
    return;
  } catch (firstError) {
    // Reintento único tras reconexión para mitigar cortes transitorios del broker.
    producerConnected = false;
    await ensureProducerConnected();
    await producer.send(messagePayload);
  }
}

// Backend API puro: el frontend vive en /frontend (Vite/React)
app.get('/', (req, res) => {
  res.json({
    service: 'lite-bank-backend',
    status: 'OK',
    message: 'Frontend separado. Usa el proyecto frontend para la UI.'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'UP' });
});

// Endpoint 1: Crear Transacción (Inyecta a Kafka)
app.post('/api/transfer', async (req, res) => {
  const { target, amount, simulationProfile, speedFactor } = req.body;
  const transactionId = 'TX-' + Date.now();
  const createdAt = Date.now();
  const normalizedProfile = String(simulationProfile || 'RANDOM').toUpperCase();

  // Guardar estado inicial en la base de datos (db.json)
  const db = JSON.parse(fs.readFileSync(DB_PATH));
  db.transactions[transactionId] = {
    target,
    amount,
    status: 'PENDIENTE',
    simulationProfile: normalizedProfile,
    createdAt,
    processedAt: null,
    responseTimeMs: null,
    workerBucket: null
  };
  fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2));

  // Enviar evento de transacción a Kafka
  const kafkaMessage = {
    topic: 'transferencias-creadas',
    messages: [
      {
        key: transactionId,
        value: JSON.stringify({
          target,
          amount,
          status: 'PENDIENTE',
          simulationProfile: normalizedProfile,
          createdAt,
          speedFactor
        })
      }
    ]
  };

  try {
    await publishTransferMessage(kafkaMessage);
    console.log(` Publicado en 'transferencias-creadas': ${transactionId}`);
  } catch (error) {
    db.transactions[transactionId].status = 'ERROR_PUBLICACION';
    db.transactions[transactionId].publicationError = String(error?.message || error);
    fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2));
    console.error(' Fallo al publicar mensaje:', error);
    return res.status(503).json({
      id: transactionId,
      status: 'ERROR_PUBLICACION',
      message: 'No se pudo publicar en Kafka. Reintenta cuando el broker esté disponible.'
    });
  }

  // Devolver respuesta HTTP 202 (Accepted) para emular la asincronía real
  res.status(202).json({
    id: transactionId,
    status: 'PENDIENTE',
    simulationProfile: normalizedProfile,
    speedFactor,
    createdAt
  });
});

// Endpoint 2: Consultar estado (Sondeo por ID)
app.get('/api/status/:id', (req, res) => {
  const { id } = req.params;
  const db = JSON.parse(fs.readFileSync(DB_PATH));
  const tx = db.transactions[id] || { status: 'NO_ENCONTRADO' };
  res.json({ id, ...tx });
});

const server = app.listen(PORT, () => {
  console.log(`[APP] Servidor web listo en http://localhost:${PORT}`);
});

server.on('error', error => {
  if (error && error.code === 'EADDRINUSE') {
    console.error(`[APP] Puerto ${PORT} en uso. Ya existe otro servidor activo.`);
    console.error('[APP] Cierra el proceso anterior o usa otro puerto con PORT=3001 npm run start-server');
    process.exit(1);
  }
  throw error;
});
