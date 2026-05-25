# Dia 4 - Backend

Backend Express (API only) con productor Kafka y worker para flujo asíncrono.

## Requisitos

- Node.js 18+
- Kafka activo en localhost:9092

## Instalar

```bash
npm install
```

## Ejecutar servidor

```bash
npm run start-server
```

## Ejecutar worker (en otra terminal)

```bash
npm run start-worker
```

## Verificación

- API backend: http://localhost:3000
- Healthcheck: http://localhost:3000/health
- El frontend vive solo en `../frontend`.

## Simulacion de escenarios

La API `/api/transfer` acepta parametros opcionales para pruebas:

- `simulationProfile`: `RANDOM`, `FAST_5`, `FAST_10`, `FAST_15`, `SLOW_TIMEOUT`
- `speedFactor`: numero entre `0.05` y `1` para acelerar pruebas automatizadas

Regla por defecto (`RANDOM`):

- 80% de casos con respuesta entre 5 y 20 segundos (`APROBADO`)
- 20% de casos con respuesta entre 40 y 60 segundos (`ERROR_TIMEOUT`)
