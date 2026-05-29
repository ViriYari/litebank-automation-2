#!/bin/bash

# LiteBank Automation - Docker Setup Script
# Usage: ./scripts/docker-up.sh [--build] [--logs]

set -e

BUILD_FLAG=""
SHOW_LOGS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD_FLAG="--build"
            shift
            ;;
        --logs)
            SHOW_LOGS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--build] [--logs]"
            exit 1
            ;;
    esac
done

echo "🚀 Starting LiteBank Automation Stack..."
echo ""

# Start Docker Compose
echo "📦 Starting Docker Compose..."
docker compose up -d $BUILD_FLAG

echo ""
echo "⏳ Waiting for services to be ready..."
echo ""

# Wait for Kafka
echo "1️⃣  Checking Kafka broker..."
for i in {1..60}; do
    if docker exec qa-kafka-broker \
        /opt/kafka/bin/kafka-broker-api-versions.sh \
        --bootstrap-server localhost:9092 > /dev/null 2>&1; then
        echo "   ✓ Kafka is ready"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "   ✗ Kafka failed to start"
        docker logs qa-kafka-broker
        exit 1
    fi
    echo "   ⏳ Attempt $i/60 - Kafka not ready yet..."
    sleep 2
done

echo ""
echo "2️⃣  Creating Kafka topic..."
docker exec qa-kafka-broker \
    /opt/kafka/bin/kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create \
    --if-not-exists \
    --topic transferencias-creadas \
    --partitions 1 \
    --replication-factor 1 > /dev/null 2>&1
echo "   ✓ Topic created"

echo ""
echo "3️⃣  Waiting for Backend Server..."
for i in {1..60}; do
    if curl -fsS http://localhost:8080/health > /dev/null 2>&1; then
        echo "   ✓ Backend Server is ready (http://localhost:8080)"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "   ✗ Backend Server failed to start"
        docker logs qa-backend-server
        exit 1
    fi
    echo "   ⏳ Attempt $i/60 - Backend not ready yet..."
    sleep 2
done

echo ""
echo "4️⃣  Waiting for Frontend..."
for i in {1..60}; do
    if curl -fsS http://localhost:5173 > /dev/null 2>&1; then
        echo "   ✓ Frontend is ready (http://localhost:5173)"
        break
    fi
    if [ $i -eq 60 ]; then
        echo "   ✗ Frontend failed to start"
        docker logs qa-frontend
        exit 1
    fi
    echo "   ⏳ Attempt $i/60 - Frontend not ready yet..."
    sleep 2
done

echo ""
echo "5️⃣  Checking Backend Worker..."
for i in {1..30}; do
    if docker inspect -f '{{.State.Running}}' qa-backend-worker 2>/dev/null | grep -q true; then
        echo "   ✓ Worker is running"
        # Extra wait for worker to connect to Kafka
        echo "   ⏳ Waiting for worker to connect to Kafka..."
        sleep 3
        echo "   ✓ Worker ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "   ✗ Worker not responding (may still be starting)"
        break
    fi
    echo "   ⏳ Attempt $i/30 - Worker not ready yet..."
    sleep 2
done

echo ""
echo "✅ Stack is ready!"
echo ""
echo "📊 Services:"
echo "  • Kafka UI:     http://localhost:8081"
echo "  • Backend:      http://localhost:8080"
echo "  • Frontend:     http://localhost:5173"
echo ""
echo "🐳 Docker Status:"
docker compose ps

if [ "$SHOW_LOGS" = true ]; then
    echo ""
    echo "📋 Showing logs (press Ctrl+C to exit)..."
    docker compose logs -f
fi
