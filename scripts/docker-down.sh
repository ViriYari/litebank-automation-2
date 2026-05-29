#!/bin/bash

# LiteBank Automation - Docker Down Script
# Usage: ./scripts/docker-down.sh [--volumes] [--force]

set -e

VOLUMES_FLAG=""
FORCE_FLAG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --volumes|-v)
            VOLUMES_FLAG="-v"
            shift
            ;;
        --force|-f)
            FORCE_FLAG="--force"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--volumes] [--force]"
            exit 1
            ;;
    esac
done

echo "🛑 Stopping LiteBank Automation Stack..."
docker compose down $VOLUMES_FLAG $FORCE_FLAG --remove-orphans
echo "✅ Stack stopped successfully"
