@echo off
REM LiteBank Automation - Service Status Check (Windows)
REM Usage: status.bat [--watch]

setlocal enabledelayedexpansion

set "WATCH=false"

REM Parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="--watch" set "WATCH=true" & shift & goto :parse_args
if "%~1"=="-w" set "WATCH=true" & shift & goto :parse_args

echo Unknown option: %~1
exit /b 1

:start
if "%WATCH%"=="true" goto :watch_mode
goto :check_status

:watch_mode
:watch_loop
cls
call :check_status
timeout /t 5 /nobreak >nul
goto :watch_loop

:check_status
echo LiteBank Automation - Service Status
echo =====================================
echo.

echo Docker Compose Status:
docker compose ps 2>nul || echo   WARNING - Docker Compose not running

echo.
echo Service Health Checks:
echo.

echo   Kafka Broker (9092):        ^
curl -fsS http://localhost:9092 >nul 2>&1 || docker exec qa-kafka-broker /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092 >nul 2>&1
if !errorlevel! equ 0 (
    echo OK
) else (
    echo NOT RESPONDING
)

echo   Kafka UI (8081):            ^
curl -fsS http://localhost:8081 >nul 2>&1
if !errorlevel! equ 0 (
    echo OK
) else (
    echo NOT RESPONDING
)

echo   Backend Server (8080):      ^
curl -fsS http://localhost:8080/health >nul 2>&1
if !errorlevel! equ 0 (
    echo OK
) else (
    echo NOT RESPONDING
)

echo   Frontend (5173):            ^
curl -fsS http://localhost:5173 >nul 2>&1
if !errorlevel! equ 0 (
    echo OK
) else (
    echo NOT RESPONDING
)

echo.

exit /b 0
