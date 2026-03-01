@echo off
chcp 65001 >nul
REM 英雄联盟网络控制器卸载脚本
echo ========================================
echo    英雄联盟网络控制器卸载程序
echo ========================================
echo.
echo 警告：这将停止并移除所有相关设置
echo.
set /p confirm=确定要卸载吗？(Y/N): 

if /i "%confirm%" neq "Y" (
    echo 取消卸载。
    timeout /t 2
    exit /b
)

echo.
echo 正在停止控制器...
call :STOP_CONTROLLER

echo.
echo 正在取消开机启动...
schtasks /delete /tn "LOL网络控制器" /f >nul 2>&1

echo.
echo 正在清理临时文件...
del "%TEMP%\LOLController.pid" 2>nul
del "%TEMP%\LOL_Network_Degrade.log" 2>nul
del "%TEMP%\LOL_Controller_Status.json" 2>nul

echo.
echo 正在恢复网络设置...
netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null
netsh int tcp set global nagle=disabled 2>&1 | Out-Null

echo.
echo 正在删除防火墙规则...
for %%p in (5000,5001,5002,5003,5004,5005,8088,8089,2099,5223,8393,8394,8395,8396,8397,8398,8399) do (
    netsh advfirewall firewall delete rule name="LOL_MARK_%%p" 2>nul
)

echo.
echo 正在恢复hosts文件...
if exist "%SystemRoot%\System32\drivers\etc\hosts.backup" (
    copy "%SystemRoot%\System32\drivers\etc\hosts.backup" "%SystemRoot%\System32\drivers\etc\hosts" /Y >nul
)

echo.
ipconfig /flushdns 2>&1 | Out-Null

echo ========================================
echo    卸载完成！
echo    建议重启计算机以确保所有设置生效
echo ========================================
echo.
pause
exit /b

:STOP_CONTROLLER
REM 停止所有相关进程
taskkill /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq LOL网络控制器" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1
exit /b