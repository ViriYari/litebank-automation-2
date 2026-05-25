const { Kafka } = require('kafkajs');
const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, 'db.json');
const KAFKA_BROKER = process.env.KAFKA_BROKER || 'localhost:9092';

const kafka = new Kafka({
  clientId: 'bank-worker',
  brokers: [KAFKA_BROKER]
});
const consumer = kafka.consumer({ groupId: 'bank-processing-group' });

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

function randomBetween(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function resolveSimulation(simulationProfile) {
  const profile = String(simulationProfile || 'RANDOM').toUpperCase();

  switch (profile) {
    case 'FAST_5':
      return { delayMs: 5000, finalStatus: 'APROBADO', bucket: 'FAST_5' };
    case 'FAST_10':
      return { delayMs: 10000, finalStatus: 'APROBADO', bucket: 'FAST_10' };
    case 'FAST_15':
      return { delayMs: 15000, finalStatus: 'APROBADO', bucket: 'FAST_15' };
    case 'SLOW_TIMEOUT':
      return {
        delayMs: randomBetween(40000, 60000),
        finalStatus: 'ERROR_TIMEOUT',
        bucket: 'SLOW_TIMEOUT'
      };
    case 'RANDOM':
    default: {
      // Regla de negocio: 80% casos <= 20s, 20% casos timeout 40-60s.
      const isFast = Math.random() < 0.8;
      if (isFast) {
        return {
          delayMs: randomBetween(5000, 20000),
          finalStatus: 'APROBADO',
          bucket: 'RANDOM_FAST'
        };
      }
      return {
        delayMs: randomBetween(40000, 60000),
        finalStatus: 'ERROR_TIMEOUT',
        bucket: 'RANDOM_SLOW_TIMEOUT'
      };
    }
  }
}

function clampSpeedFactor(value) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return 1;
  }
  return Math.min(1, Math.max(0.05, parsed));
}

async function subscribeWhenTopicAvailable() {
  while (true) {
    try {
      await consumer.subscribe({ topic: 'transferencias-creadas', fromBeginning: false });
      return;
    } catch (error) {
      if (error && (error.type === 'UNKNOWN_TOPIC_OR_PARTITION' || error.code === 3)) {
        console.log(" Tópico aún no disponible, reintentando en 2s...");
        await delay(2000);
        continue;
      }
      throw error;
    }
  }
}

async function runWorker() {
  await consumer.connect();
  // El consumidor se suscribe al casillero específico de transferencias creadas
  await subscribeWhenTopicAvailable();
  console.log(" Escuchando eventos en el tópico 'transferencias-creadas'...");

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const eventData = JSON.parse(message.value.toString());
      const txId = message.key.toString();

      // Registro Estructurado (Structured Logging)
      console.log(JSON.stringify({
        timestamp: new Date().toISOString(),
        level: "INFO",
        service: "bank-worker",
        message: "Evento recibido de Kafka",
        transactionId: txId,
        data: eventData
      }));

      // Simulación de procesamiento asíncrono complejo (Retraso configurable, 10s por defecto)
      const simulation = resolveSimulation(eventData.simulationProfile);
      const speedFactor = clampSpeedFactor(eventData.speedFactor);
      const finalDelayMs = Math.max(200, Math.floor(simulation.delayMs * speedFactor));

      console.log(
        ` Procesando ${txId} | profile=${eventData.simulationProfile || 'RANDOM'} | bucket=${simulation.bucket} | delay=${finalDelayMs}ms`
      );
      await delay(finalDelayMs);

      // Actualizar resultado final en db.json
      const db = JSON.parse(fs.readFileSync(DB_PATH));
      if (db.transactions[txId]) {
        const createdAt = Number(db.transactions[txId].createdAt || Date.now());
        const processedAt = Date.now();
        db.transactions[txId].status = simulation.finalStatus;
        db.transactions[txId].workerBucket = simulation.bucket;
        db.transactions[txId].processedAt = processedAt;
        db.transactions[txId].responseTimeMs = processedAt - createdAt;
        db.transactions[txId].effectiveDelayMs = finalDelayMs;
        fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2));
        
        console.log(JSON.stringify({
          timestamp: new Date().toISOString(),
          level: "INFO",
          service: "bank-worker",
          message: "Transacción procesada",
          transactionId: txId,
          status: simulation.finalStatus,
          bucket: simulation.bucket,
          effectiveDelayMs: finalDelayMs
        }));
      }
    }
  });
}

runWorker().catch(console.error);
