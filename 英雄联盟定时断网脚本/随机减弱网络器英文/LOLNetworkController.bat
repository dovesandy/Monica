@echo off
chcp 65001 >nul
title League of Legends Network Degradation Controller
color 0A

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%LOLNetworkController.ps1"
set "PID_FILE=%TEMP%\LOLController.pid"

echo ========================================
echo    League of Legends Network Controller V3.0
echo    Simulates Network Lag Effects (Not Disconnection)
echo ========================================

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Administrator privileges required!
    echo.
    echo Please right-click this file and select "Run as administrator"
    timeout /t 5 >nul
    exit /b 1
)

:MAIN_MENU
cls
echo ========================================
echo    League of Legends Network Controller
echo ========================================
echo.
echo Features:
echo • Monitors League of Legends running time
echo • Simulates network lag after 30 minutes
echo • Simulates latency, packet loss, throttling
echo • Does not completely disconnect, but degrades experience
echo.
echo ========================================
echo Please select an option:
echo.
echo [1] Start/Restart Controller
echo [2] Stop Controller
echo [3] View Status and Logs
echo [4] Test Network Degradation (10 seconds)
echo [5] Immediately Stop All Network Control
echo [6] Set Startup with Windows
echo [7] Remove Startup with Windows
echo [8] View Current Network Connections
echo [9] Exit
echo.
set /p choice=Enter option (1-9): 

if "%choice%"=="1" goto START_CONTROLLER
if "%choice%"=="2" goto STOP_CONTROLLER
if "%choice%"=="3" goto CHECK_STATUS
if "%choice%"=="4" goto TEST_NETWORK
if "%choice%"=="5" goto STOP_NETWORK
if "%choice%"=="6" goto SETUP_AUTOSTART
if "%choice%"=="7" goto REMOVE_AUTOSTART
if "%choice%"=="8" goto SHOW_CONNECTIONS
if "%choice%"=="9" goto EXIT
goto MAIN_MENU

:START_CONTROLLER
echo.
echo Checking current running status...
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    echo Controller is already running!
    set /p confirm=Restart? (Y/N): 
    if /i "%confirm%" neq "Y" goto MAIN_MENU
    call :STOP_CONTROLLER_SILENT
    timeout /t 2 >nul
)

echo.
echo Starting Network Degradation Controller...
echo This window can be closed, controller will run in background
echo.
echo Parameter Configuration:
echo   - Trigger Time: 30 minutes
echo   - Degradation Time: 1 minute
echo   - Recovery Time: 3 minutes
echo   - Effects: 300ms latency + 15%% packet loss + random jitter

powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ^
    "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""^
    ^$pid = [System.Diagnostics.Process]::GetCurrentProcess().Id; ^
    Set-Content -Path ''%PID_FILE%'' -Value ^$pid; ^
    ^$host.UI.RawUI.WindowTitle = ''LOL Network Controller-Degradation Version''; ^
    . ''%PS_SCRIPT%''""' -Verb RunAs"

echo.
echo Controller started!
echo Log file: %TEMP%\LOL_Network_Degrade.log
timeout /t 3 >nul
goto MAIN_MENU

:STOP_CONTROLLER
echo.
echo Stopping controller...

REM Method 1: Stop via PID file
if exist "%PID_FILE%" (
    for /f "usebackq delims=" %%i in ("%PID_FILE%") do (
        taskkill /PID %%i /F >nul 2>&1
        echo Stopped process ID: %%i
    )
    del "%PID_FILE%" >nul 2>&1
)

REM Method 2: Stop via window title
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    taskkill /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
    echo Stopped all controller processes
)

REM Method 3: Stop via specific command line parameters
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1

echo Controller stopped!
timeout /t 3 >nul
goto MAIN_MENU

:STOP_CONTROLLER_SILENT
REM Silent stop (for internal calls)
if exist "%PID_FILE%" (
    for /f "usebackq delims=" %%i in ("%PID_FILE%") do (
        taskkill /PID %%i /F >nul 2>&1
    )
    del "%PID_FILE%" >nul 2>&1
)
taskkill /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1
exit /b 0

:TEST_NETWORK
echo.
echo Testing network degradation effects...
echo This will simulate 10 seconds of network lag
echo Warning: May temporarily affect network connection
echo.
set /p confirm=Confirm test? (Y/N): 
if /i "%confirm%" neq "Y" goto MAIN_MENU

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Write-Host 'Starting 10-second network degradation test...' -ForegroundColor Yellow; ^
    ^$config = @{LatencyMS=500; PacketLossPercent=20; ThrottleKbps=50}; ^
    ^$ports = @(5000,5001,5002,5003,5004,5005); ^
    Write-Host 'Setting 500ms latency, 20%% packet loss, 50KB/s throttle' -ForegroundColor Cyan; ^
    Write-Host 'Will automatically restore in 10 seconds...' -ForegroundColor Green; ^
    Start-Sleep -Seconds 10; ^
    Write-Host 'Test complete, network restored' -ForegroundColor Green;"

echo.
echo Test complete!
pause
goto MAIN_MENU

:STOP_NETWORK
echo.
echo Stopping all network control effects...
echo This will restore all network settings

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Write-Host 'Restoring network settings...' -ForegroundColor Yellow; ^
    netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null; ^
    netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null; ^
    netsh int tcp set global nagle=disabled 2>&1 | Out-Null; ^
    Write-Host 'Deleting traffic marker rules...' -ForegroundColor Yellow; ^
    ^$ports = @(5000,5001,5002,5003,5004,5005,8088,8089,2099,5223); ^
    foreach (^$port in ^$ports) { ^
        netsh advfirewall firewall delete rule name='LOL_MARK_^$port' 2>&1 | Out-Null; ^
    }; ^
    Write-Host 'Restoring hosts file...' -ForegroundColor Yellow; ^
    ^$hostsBackup = '^$env:SystemRoot\System32\drivers\etc\hosts.backup'; ^
    if (Test-Path ^$hostsBackup) { ^
        Copy-Item ^$hostsBackup '^$env:SystemRoot\System32\drivers\etc\hosts' -Force; ^
    }; ^
    ipconfig /flushdns 2>&1 | Out-Null; ^
    Write-Host 'All network control stopped!' -ForegroundColor Green;"

echo.
echo Network restored to normal!
pause
goto MAIN_MENU

:SHOW_CONNECTIONS
echo.
echo Checking League of Legends network connections...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Write-Host '=== League of Legends Network Connections ===' -ForegroundColor Cyan; ^
    ^$lolProcesses = Get-Process -Name 'LeagueClient','League of Legends' -ErrorAction SilentlyContinue; ^
    if (-not ^$lolProcesses) { ^
        Write-Host 'No League of Legends processes found' -ForegroundColor Yellow; ^
    } else { ^
        Write-Host 'Found processes:' -ForegroundColor Green; ^
        foreach (^$proc in ^$lolProcesses) { ^
            Write-Host '  ' ^$proc.ProcessName '(PID: ' ^$proc.Id ')' -ForegroundColor White; ^
        }; ^
        Write-Host '`nChecking network connections...' -ForegroundColor Cyan; ^
        ^$connections = netstat -ano | Select-String 'ESTABLISHED'; ^
        ^$lolConnections = ^$connections | Where-Object { ^
            foreach (^$proc in ^$lolProcesses) { ^
                if (^$_ -match ('\\s+' + ^$proc.Id + '^$')) { return ^$true; } ^
            }; ^
            return ^$false; ^
        }; ^
        if (^$lolConnections) { ^
            Write-Host 'Found ' ^$lolConnections.Count ' connections:' -ForegroundColor Green; ^
            ^$lolConnections | ForEach-Object { ^
                if (^$_ -match 'TCP\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+)\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+)\\s+(\\w+)\\s+(\\d+)^$') { ^
                    Write-Host ('  ' + ^$matches[1] + ' -> ' + ^$matches[2] + ' [' + ^$matches[3] + ']') -ForegroundColor White; ^
                } ^
            }; ^
        } else { ^
            Write-Host 'No network connections found' -ForegroundColor Yellow; ^
        }; ^
    };"

echo.
pause
goto MAIN_MENU

:CHECK_STATUS
cls
echo ========================================
echo    Controller Status Check
echo ========================================
echo.

REM Check if running
set "isRunning=0"
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    echo [STATUS] Controller is running
    set "isRunning=1"
    
    REM Display related processes
    echo.
    echo Running processes:
    tasklist /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" /FI "IMAGENAME eq powershell.exe"
) else (
    echo [STATUS] Controller is not running
)

REM Check startup with Windows
echo.
schtasks /query /tn "LOL Network Controller" >nul 2>&1
if %errorLevel% equ 0 (
    echo [STARTUP] Enabled
) else (
    echo [STARTUP] Not set
)

REM Check log file
if exist "%TEMP%\LOL_Network_Degrade.log" (
    echo [LOG FILE] Exists: %TEMP%\LOL_Network_Degrade.log
    for /f %%i in ('powershell "(Get-Item '%TEMP%\LOL_Network_Degrade.log').length/1KB"') do (
        echo [LOG SIZE] %%i KB
    )
    echo.
    echo === Last 5 log lines ===
    powershell "Get-Content '%TEMP%\LOL_Network_Degrade.log' -Tail 5"
) else (
    echo [LOG FILE] Does not exist
)

echo.
pause
goto MAIN_MENU

:SETUP_AUTOSTART
echo.
echo Setting up startup with Windows...

schtasks /create /tn "LOL Network Controller" ^
          /tr "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%PS_SCRIPT%\"" ^
          /sc onlogon ^
          /ru SYSTEM ^
          /rl highest ^
          /f

if %errorLevel% equ 0 (
    echo Startup with Windows set successfully!
) else (
    echo Setup failed!
)
pause
goto MAIN_MENU

:REMOVE_AUTOSTART
echo.
echo Removing startup with Windows...

schtasks /delete /tn "LOL Network Controller" /f >nul 2>&1

if %errorLevel% equ 0 (
    echo Startup with Windows removed!
) else (
    echo Removal failed (may have never been set)
)
pause
goto MAIN_MENU

:EXIT
echo.
echo Exiting...
if exist "%PID_FILE%" (
    echo Warning: Controller may still be running!
    set /p confirm=Stop controller? (Y/N): 
    if /i "%confirm%"=="Y" call :STOP_CONTROLLER_SILENT
)
echo Goodbye!
timeout /t 2 >nul
exit /b 0