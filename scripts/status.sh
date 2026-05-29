#!/bin/bash

# LiteBank Automation - Service Status Check
# Usage: ./scripts/status.sh [--watch]

WATCH=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --watch|-w)
            WATCH=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

check_status() {
    echo "📊 LiteBank Automation - Service Status"
    echo "========================================"
    echo ""
    
    # Docker Compose Status
    echo "🐳 Docker Compose Status:"
    docker compose ps 2>/dev/null || echo "  ⚠️  Docker Compose not running"
    
    echo ""
    echo "🔍 Service Health Checks:"
    echo ""
    
    # Check Kafka
    echo -n "  Kafka Broker (9092):        "
    if curl -fsS http://localhost:9092 > /dev/null 2>&1 || \
       docker exec qa-kafka-broker /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1; then
        echo "✓ Ready"
    else
        echo "✗ Not responding"
    fi
    
    # Check Kafka UI
    echo -n "  Kafka UI (8081):            "
    if curl -fsS http://localhost:8081 > /dev/null 2>&1; then
        echo "✓ Ready"
    else
        echo "✗ Not responding"
    fi
    
    # Check Backend Server
    echo -n "  Backend Server (8080):      "
    if curl -fsS http://localhost:8080/health > /dev/null 2>&1; then
        echo "✓ Ready"
    else
        echo "✗ Not responding"
    fi
    
    # Check Frontend
    echo -n "  Frontend (5173):            "
    if curl -fsS http://localhost:5173 > /dev/null 2>&1; then
        echo "✓ Ready"
    else
        echo "✗ Not responding"
    fi
    
    echo ""
}

if [ "$WATCH" = true ]; then
    while true; do
        clear
        check_status
        sleep 5
    done
else
    check_status
fi
