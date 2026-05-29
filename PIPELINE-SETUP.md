# 🚀 LiteBank Automation - Pipeline Setup

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Java 21
- Maven 3.9+
- Node.js 22+

### Option 1: Using Helper Scripts (Recommended)

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

**Start the stack:**
```bash
./scripts/docker-up.sh --build
```

**Check service status:**
```bash
./scripts/status.sh
# or watch status in real-time
./scripts/status.sh --watch
```

**Run tests:**
```bash
./scripts/run-tests.sh
```

**Stop the stack:**
```bash
./scripts/docker-down.sh --volumes
```

### Option 2: Manual Docker Commands

**Start services:**
```bash
docker compose up -d --build
```

**Wait for services to be ready:**
```bash
# Check logs in real-time
docker compose logs -f
```

**Run tests when all services are ready:**
```bash
mvn clean test \
  -DBASE_URL=http://localhost:5173 \
  -DBACKEND_URL=http://localhost:8080
```

**Stop services:**
```bash
docker compose down -v
```

## Service Endpoints

| Service | URL | Port |
|---------|-----|------|
| Frontend | http://localhost:5173 | 5173 |
| Backend API | http://localhost:8080 | 8080 |
| Kafka Broker | localhost:9092 | 9092 |
| Kafka UI | http://localhost:8081 | 8081 |

## Architecture

```
┌─────────────────────────────────────────┐
│     Frontend (React + Vite)             │
│     http://localhost:5173               │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│   Backend Server (Node.js + Express)    │
│   http://localhost:8080                 │
└────────────────┬────────────────────────┘
                 │
          ┌──────┴──────┐
          ▼             ▼
    ┌─────────────┐  ┌──────────────┐
    │   Kafka     │  │   Backend    │
    │   Broker    │  │   Worker     │
    │ (9092/29092)│  │  (Consumer)  │
    └─────────────┘  └──────────────┘
         ▲                   │
         └───────────────────┘
              Messages:
         transferencias-creadas
```

## Pipeline Workflow

The GitHub Actions pipeline (`test-pipeline.yml`) automatically runs on push to `main`:

1. ✅ Checkout code
2. ✅ Setup Java 21 (with Maven cache)
3. ✅ Start Docker Compose
4. ✅ Wait for Kafka broker
5. ✅ Create Kafka topic
6. ✅ Wait for backend-server
7. ✅ Wait for frontend
8. ✅ Wait for backend-worker
9. ✅ Run Maven Selenium tests
10. ✅ Collect logs (if failed)
11. ✅ Cleanup

## Docker Compose Improvements

The `docker-compose.yml` includes:

- **Health checks** for all services (Kafka, backend-server, frontend)
- **Restart policies** for failed containers
- **Proper dependency ordering** using `depends_on` with `service_healthy`
- **Environment variables** for configuration
- **Volume management** for development
- **Network isolation** with custom `qa-network`

## Scripts Overview

### docker-up.sh
Starts the Docker stack with intelligent waiting.

```bash
./scripts/docker-up.sh              # Start with existing images
./scripts/docker-up.sh --build      # Rebuild images
./scripts/docker-up.sh --logs       # Show live logs after startup
```

### docker-down.sh
Stops and removes all containers.

```bash
./scripts/docker-down.sh            # Stop containers
./scripts/docker-down.sh --volumes  # Stop and remove volumes
./scripts/docker-down.sh --force    # Force stop
```

### run-tests.sh
Runs the Selenium test suite.

```bash
./scripts/run-tests.sh              # Start stack and run tests
./scripts/run-tests.sh --no-docker  # Run tests against existing stack
./scripts/run-tests.sh --debug      # Run with Maven debug output
```

### status.sh
Checks service health.

```bash
./scripts/status.sh                 # One-time check
./scripts/status.sh --watch         # Monitor with 5-second refresh
```

## Troubleshooting

### Services not starting
```bash
# Check logs for specific service
docker logs qa-backend-server
docker logs qa-frontend
docker logs qa-backend-worker
docker logs qa-kafka-broker

# Check all services
./scripts/status.sh --watch
```

### Port conflicts
```bash
# Check what's using the port (example for 5173)
lsof -i :5173
# or kill process
kill -9 <PID>
```

### Maven tests failing
```bash
# Run with debug output
./scripts/run-tests.sh --debug

# Or manually with Maven
mvn clean test -X -DBASE_URL=http://localhost:5173
```

### Kafka not ready
```bash
# Check if topic was created
docker exec qa-kafka-broker \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --list

# Check broker logs
docker logs qa-kafka-broker
```

## Development Workflow

1. **Start stack:**
   ```bash
   ./scripts/docker-up.sh --build
   ```

2. **Monitor services:**
   ```bash
   ./scripts/status.sh --watch
   ```

3. **Make changes:**
   - Frontend changes auto-reload (Vite HMR)
   - Backend changes require container restart

4. **Run tests:**
   ```bash
   ./scripts/run-tests.sh --no-docker
   ```

5. **Stop stack:**
   ```bash
   ./scripts/docker-down.sh --volumes
   ```

## CI/CD Pipeline

The pipeline runs automatically on:
- ✅ Push to `main` branch
- ✅ Pull requests to `main` branch

**Pipeline steps:**
- Tests run with 25-minute timeout
- Concurrent runs are cancelled (concurrency control)
- Maven cache is used for faster builds
- Full Docker Compose stack is built
- Comprehensive logging on failure
- Clean cleanup with orphan removal

## Environment Variables

### Backend Server
- `KAFKA_BROKER`: kafka:29092 (set automatically)
- `NODE_ENV`: production

### Backend Worker
- `KAFKA_BROKER`: kafka:29092 (set automatically)
- `NODE_ENV`: production

### Frontend
- `CHOKIDAR_USEPOLLING`: true (for file watching in containers)
- `NODE_ENV`: development

## Notes

- All scripts use `set -e` for fail-on-error behavior
- Docker Compose uses bridge networking (`qa-network`)
- Kafka runs in KRaft mode (controller + broker in one)
- Services have health checks with appropriate timeouts
- Frontend uses Vite for fast development experience
