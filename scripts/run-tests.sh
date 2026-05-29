#!/bin/bash

# LiteBank Automation - Local Test Runner
# Usage: ./scripts/run-tests.sh [--no-docker] [--debug]

set -e

NO_DOCKER=false
DEBUG_FLAG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-docker)
            NO_DOCKER=true
            shift
            ;;
        --debug)
            DEBUG_FLAG="-X"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--no-docker] [--debug]"
            exit 1
            ;;
    esac
done

echo "🧪 Running LiteBank Automation Tests..."
echo ""

if [ "$NO_DOCKER" = false ]; then
    echo "📦 Starting Docker stack..."
    ./scripts/docker-up.sh
    echo ""
fi

echo "🏃 Running Maven tests..."
echo ""

mvn clean test $DEBUG_FLAG \
    -DBASE_URL=http://localhost:5173 \
    -DBACKEND_URL=http://localhost:8080

TEST_RESULT=$?

echo ""
if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed. Check the output above."
fi

exit $TEST_RESULT
