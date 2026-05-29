@echo off
REM LiteBank Automation - Docker Setup Script (Windows)
REM Usage: docker-up.bat [--build] [--logs]

setlocal enabledelayedexpansion

set "BUILD_FLAG="
set "SHOW_LOGS=false"

REM Parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="--build" set "BUILD_FLAG=--build" & shift & goto :parse_args
if "%~1"=="--logs" set "SHOW_LOGS=true" & shift & goto :parse_args

echo Unknown option: %~1
echo Usage: %0 [--build] [--logs]
exit /b 1

:start
echo Starting LiteBank Automation Stack...
echo.

REM Start Docker Compose
echo Fetching images...
docker compose up -d %BUILD_FLAG%

echo.
echo Waiting for services to be ready...
echo.

REM Wait for Kafka
echo 1. Checking Kafka broker...
for /L %%i in (1,1,60) do (
    docker exec qa-kafka-broker ^
        /opt/kafka/bin/kafka-broker-api-versions.sh ^
        --bootstrap-server localhost:9092 >nul 2>&1
    if !errorlevel! equ 0 (
        echo    OK - Kafka is ready
        goto :kafka_ready
    )
    if %%i lss 60 (
        echo    Attempt %%i/60 - Kafka not ready yet...
        timeout /t 2 /nobreak >nul
    )
)
echo    ERROR - Kafka failed to start
docker logs qa-kafka-broker
exit /b 1

:kafka_ready
echo.
echo 2. Creating Kafka topic...
docker exec qa-kafka-broker ^
    /opt/kafka/bin/kafka-topics.sh ^
    --bootstrap-server localhost:9092 ^
    --create ^
    --if-not-exists ^
    --topic transferencias-creadas ^
    --partitions 1 ^
    --replication-factor 1 >nul 2>&1
echo    OK - Topic created

echo.
echo 3. Waiting for Backend Server...
for /L %%i in (1,1,60) do (
    curl -fsS http://localhost:8080/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo    OK - Backend Server is ready ^(http://localhost:8080^)
        goto :backend_ready
    )
    if %%i lss 60 (
        echo    Attempt %%i/60 - Backend not ready yet...
        timeout /t 2 /nobreak >nul
    )
)
echo    ERROR - Backend Server failed to start
docker logs qa-backend-server
exit /b 1

:backend_ready
echo.
echo 4. Waiting for Frontend...
for /L %%i in (1,1,60) do (
    curl -fsS http://localhost:5173 >nul 2>&1
    if !errorlevel! equ 0 (
        echo    OK - Frontend is ready ^(http://localhost:5173^)
        goto :frontend_ready
    )
    if %%i lss 60 (
        echo    Attempt %%i/60 - Frontend not ready yet...
        timeout /t 2 /nobreak >nul
    )
)
echo    ERROR - Frontend failed to start
docker logs qa-frontend
exit /b 1

:frontend_ready
echo.
echo 5. Checking Backend Worker...
for /L %%i in (1,1,30) do (
    docker inspect -f "{{.State.Running}}" qa-backend-worker 2>nul | findstr /r "true" >nul 2>&1
    if !errorlevel! equ 0 (
        echo    OK - Worker is running
        goto :worker_ready
    )
    if %%i lss 30 (
        echo    Attempt %%i/30 - Worker not ready yet...
        timeout /t 2 /nobreak >nul
    )
)
echo    WARNING - Worker not responding ^(may still be starting^)

:worker_ready
echo.
echo Stack is ready!
echo.
echo Services:
echo   Kafka UI:     http://localhost:8081
echo   Backend:      http://localhost:8080
echo   Frontend:     http://localhost:5173
echo.
echo Docker Status:
docker compose ps

if "%SHOW_LOGS%"=="true" (
    echo.
    echo Showing logs ^(press Ctrl+C to exit^)...
    docker compose logs -f
)
