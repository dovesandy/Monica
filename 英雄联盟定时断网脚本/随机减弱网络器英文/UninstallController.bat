@echo off
REM League of Legends Network Controller Uninstall Script
echo ========================================
echo    League of Legends Network Controller Uninstaller
echo ========================================
echo.
echo Warning: This will stop and remove all related settings
echo.
set /p confirm=Confirm uninstall? (Y/N): 

if /i "%confirm%" neq "Y" (
    echo Uninstall cancelled.
    timeout /t 2
    exit /b
)

echo.
echo Stopping controller...
call :STOP_CONTROLLER

echo.
echo Removing startup with Windows...
schtasks /delete /tn "LOL Network Controller" /f >nul 2>&1

echo.
echo Cleaning temporary files...
del "%TEMP%\LOLController.pid" 2>nul
del "%TEMP%\LOL_Network_Degrade.log" 2>nul
del "%TEMP%\LOL_Controller_Status.json" 2>nul

echo.
echo Restoring network settings...
netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null
netsh int tcp set global nagle=disabled 2>&1 | Out-Null

echo.
echo Deleting firewall rules...
for %%p in (5000,5001,5002,5003,5004,5005,8088,8089,2099,5223,8393,8394,8395,8396,8397,8398,8399) do (
    netsh advfirewall firewall delete rule name="LOL_MARK_%%p" 2>nul
)

echo.
echo Restoring hosts file...
if exist "%SystemRoot%\System32\drivers\etc\hosts.backup" (
    copy "%SystemRoot%\System32\drivers\etc\hosts.backup" "%SystemRoot%\System32\drivers\etc\hosts" /Y >nul
)

echo.
ipconfig /flushdns 2>&1 | Out-Null

echo ========================================
echo    Uninstall complete!
echo    Recommended to restart computer to ensure all settings take effect
echo ========================================
echo.
pause
exit /b

:STOP_CONTROLLER
REM Stop all related processes
taskkill /FI "WINDOWTITLE eq LOL Network Controller-Degradation Version" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq LOL Network Controller" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1
exit /b