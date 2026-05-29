@echo off
REM LiteBank Automation - Local Test Runner (Windows)
REM Usage: run-tests.bat [--no-docker] [--debug]

setlocal enabledelayedexpansion

set "NO_DOCKER=false"
set "DEBUG_FLAG="

REM Parse arguments
:parse_args
if "%~1"=="" goto :start
if "%~1"=="--no-docker" set "NO_DOCKER=true" & shift & goto :parse_args
if "%~1"=="--debug" set "DEBUG_FLAG=-X" & shift & goto :parse_args

echo Unknown option: %~1
echo Usage: %0 [--no-docker] [--debug]
exit /b 1

:start
echo Running LiteBank Automation Tests...
echo.

if "%NO_DOCKER%"=="false" (
    echo Starting Docker stack...
    call scripts\docker-up.bat
    echo.
)

echo Running Maven tests...
echo.

mvn clean test %DEBUG_FLAG% ^
    -DBASE_URL=http://localhost:5173 ^
    -DBACKEND_URL=http://localhost:8080

set TEST_RESULT=%errorlevel%

echo.
if %TEST_RESULT% equ 0 (
    echo All tests passed!
) else (
    echo Some tests failed. Check the output above.
)

exit /b %TEST_RESULT%
