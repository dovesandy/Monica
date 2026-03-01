@echo off
REM League of Legends Network Controller Quick Start Script
REM Double-click this file to start the main control interface

echo Starting League of Legends Network Controller...
echo Please wait...

cd /d "%~dp0"

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo Administrator privileges required!
    echo Please right-click this file and select "Run as administrator"
    timeout /t 5
    exit /b
)

start "" "LOLNetworkController.bat"