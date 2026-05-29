@echo off
REM LiteBank Automation - Docker Down Script (Windows)
REM Usage: docker-down.bat [--volumes] [--force]

setlocal enabledelayedexpansion

set "VOLUMES_FLAG="
set "FORCE_FLAG="

REM Parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="--volumes" set "VOLUMES_FLAG=-v" & shift & goto :parse_args
if "%~1"=="-v" set "VOLUMES_FLAG=-v" & shift & goto :parse_args
if "%~1"=="--force" set "FORCE_FLAG=--force" & shift & goto :parse_args
if "%~1"=="-f" set "FORCE_FLAG=--force" & shift & goto :parse_args

echo Unknown option: %~1
echo Usage: %0 [--volumes] [--force]
exit /b 1

:start
echo Stopping LiteBank Automation Stack...
docker compose down %VOLUMES_FLAG% %FORCE_FLAG% --remove-orphans
echo ✓ Stack stopped successfully
