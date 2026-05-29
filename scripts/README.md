# Scripts - Quick Reference

## Windows Users

### Start the Stack
```batch
scripts\docker-up.bat
# or with build
scripts\docker-up.bat --build
# or show logs after startup
scripts\docker-up.bat --logs
```

### Run Tests
```batch
scripts\run-tests.bat
# or without starting docker
scripts\run-tests.bat --no-docker
# or with debug output
scripts\run-tests.bat --debug
```

### Check Status
```batch
scripts\status.bat
# or watch in real-time
scripts\status.bat --watch
```

### Stop the Stack
```batch
scripts\docker-down.bat
# or remove volumes
scripts\docker-down.bat --volumes
# or force stop
scripts\docker-down.bat --force
```

---

## Linux/Mac Users

### Start the Stack
```bash
./scripts/docker-up.sh
# or with build
./scripts/docker-up.sh --build
# or show logs after startup
./scripts/docker-up.sh --logs
```

### Run Tests
```bash
./scripts/run-tests.sh
# or without starting docker
./scripts/run-tests.sh --no-docker
# or with debug output
./scripts/run-tests.sh --debug
```

### Check Status
```bash
./scripts/status.sh
# or watch in real-time
./scripts/status.sh --watch
```

### Stop the Stack
```bash
./scripts/docker-down.sh
# or remove volumes
./scripts/docker-down.sh --volumes
# or force stop
./scripts/docker-down.sh --force
```

---

## Manual Commands (All Platforms)

```bash
# Start stack
docker compose up -d --build

# Wait for services (use status script or check logs)
docker compose logs -f

# Run tests when ready
mvn clean test -DBASE_URL=http://localhost:5173 -DBACKEND_URL=http://localhost:8080

# Stop stack
docker compose down -v
```

---

## What Each Script Does

### docker-up / docker-up.bat
- Starts Docker Compose
- Waits for Kafka broker to be ready
- Creates the Kafka topic if needed
- Waits for backend server health check
- Waits for frontend to respond
- Confirms worker is running
- Shows service endpoints

### docker-down / docker-down.bat
- Stops all containers
- Removes volumes (with --volumes flag)
- Removes orphans

### run-tests / run-tests.bat
- Optionally starts the stack
- Runs Maven tests with environment variables set
- Returns exit code (0 = success, non-zero = failure)

### status / status.bat
- Shows Docker Compose service status
- Checks each service endpoint
- With --watch flag, updates every 5 seconds

---

## Endpoints

Once the stack is running:

| Service | URL |
|---------|-----|
| Frontend | http://localhost:5173 |
| Backend API | http://localhost:8080 |
| Kafka UI | http://localhost:8081 |
| Kafka Broker | localhost:9092 |

---

## Troubleshooting

### "Docker command not found"
- Install Docker Desktop
- Make sure Docker daemon is running

### "Port already in use"
Windows:
```batch
netstat -ano | findstr :5173
taskkill /PID <PID> /F
```

Linux/Mac:
```bash
lsof -i :5173
kill -9 <PID>
```

### Services not starting
- Check `./scripts/status.sh` or `scripts\status.bat`
- View logs: `docker compose logs <service_name>`

### Tests failing
- Make sure all services show "OK" in status check
- Run with debug: `./scripts/run-tests.sh --debug`

---

## Environment Setup

### Windows Prerequisites
- Docker Desktop (includes Docker & Docker Compose)
- Java 21 (add to PATH)
- Maven (add to PATH)
- Node.js 22+ (optional, already in Docker)

### Linux/Mac Prerequisites
```bash
# Install Docker & Docker Compose
# See https://docs.docker.com/engine/install/

# Install Java 21
sudo apt-get install openjdk-21-jdk  # Debian/Ubuntu

# Install Maven
sudo apt-get install maven

# Make scripts executable
chmod +x scripts/*.sh
```

---

## CI/CD Pipeline

The GitHub Actions pipeline (`test-pipeline.yml`) runs automatically on:
- Push to main branch
- Pull requests to main branch

It performs the same steps as the `run-tests` script but in a GitHub-hosted runner.
