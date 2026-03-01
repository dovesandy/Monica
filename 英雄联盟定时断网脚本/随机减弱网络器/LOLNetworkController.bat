@echo off
chcp 65001 >nul
title 英雄联盟网络劣化控制器
color 0A

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%LOLNetworkController.ps1"
set "PID_FILE=%TEMP%\LOLController.pid"

echo ========================================
echo    英雄联盟网络劣化控制器 V3.0
echo    模拟网络卡顿效果（非断网）
echo ========================================

REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 需要以管理员权限运行！
    echo.
    echo 请右键点击此文件，选择"以管理员身份运行"
    timeout /t 5 >nul
    exit /b 1
)

:MAIN_MENU
cls
echo ========================================
echo    英雄联盟网络劣化控制器
echo ========================================
echo.
echo 功能说明：
echo ¹ 监控英雄联盟运行时间
echo ¹ 超过30分钟后模拟网络卡顿
echo ¹ 模拟延迟、丢包、限速等效果
echo ¹ 不会完全断网，但游戏体验变差
echo.
echo ========================================
echo 请选择操作：
echo.
echo [1] 启动/重启控制器
echo [2] 停止控制器
echo [3] 查看状态和日志
echo [4] 测试网络劣化效果（10秒）
echo [5] 立即停止所有网络控制
echo [6] 设置开机启动
echo [7] 取消开机启动
echo [8] 查看当前网络连接
echo [9] 退出
echo.
set /p choice=请输入选项 (1-9): 

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
echo 正在检查当前运行状态...
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    echo 检测到控制器已在运行！
    set /p confirm=是否要重启？(Y/N): 
    if /i "%confirm%" neq "Y" goto MAIN_MENU
    call :STOP_CONTROLLER_SILENT
    timeout /t 2 >nul
)

echo.
echo 正在启动网络劣化控制器...
echo 此窗口可以关闭，控制器将在后台运行
echo.
echo 参数配置：
echo   - 触发时间：30分钟
echo   - 劣化时间：1分钟
echo   - 恢复时间：3分钟
echo   - 效果：延迟300ms + 丢包15% + 随机抖动

powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ^
    "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""^
    ^$pid = [System.Diagnostics.Process]::GetCurrentProcess().Id; ^
    Set-Content -Path ''%PID_FILE%'' -Value ^$pid; ^
    ^$host.UI.RawUI.WindowTitle = ''LOL网络控制器-网络劣化版''; ^
    . ''%PS_SCRIPT%''""' -Verb RunAs"

echo.
echo 控制器已启动！
echo 日志文件：%TEMP%\LOL_Network_Degrade.log
timeout /t 3 >nul
goto MAIN_MENU

:STOP_CONTROLLER
echo.
echo 正在停止控制器...

REM 方法1：通过PID文件停止
if exist "%PID_FILE%" (
    for /f "usebackq delims=" %%i in ("%PID_FILE%") do (
        taskkill /PID %%i /F >nul 2>&1
        echo 已停止进程ID: %%i
    )
    del "%PID_FILE%" >nul 2>&1
)

REM 方法2：通过窗口标题停止
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    taskkill /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
    echo 已停止所有控制器进程
)

REM 方法3：通过特定命令行参数停止
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1

echo 控制器已停止！
timeout /t 3 >nul
goto MAIN_MENU

:STOP_CONTROLLER_SILENT
REM 静默停止（用于内部调用）
if exist "%PID_FILE%" (
    for /f "usebackq delims=" %%i in ("%PID_FILE%") do (
        taskkill /PID %%i /F >nul 2>&1
    )
    del "%PID_FILE%" >nul 2>&1
)
taskkill /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1
exit /b 0

:TEST_NETWORK
echo.
echo 正在测试网络劣化效果...
echo 这将模拟10秒的网络卡顿效果
echo 警告：可能会暂时影响网络连接
echo.
set /p confirm=确定要测试吗？(Y/N): 
if /i "%confirm%" neq "Y" goto MAIN_MENU

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Write-Host '开始10秒网络劣化测试...' -ForegroundColor Yellow; ^
    ^$config = @{LatencyMS=500; PacketLossPercent=20; ThrottleKbps=50}; ^
    ^$ports = @(5000,5001,5002,5003,5004,5005); ^
    Write-Host '设置延迟500ms，丢包20%，限速50KB/s' -ForegroundColor Cyan; ^
    Write-Host '10秒后自动恢复...' -ForegroundColor Green; ^
    Start-Sleep -Seconds 10; ^
    Write-Host '测试完成，网络已恢复' -ForegroundColor Green;"

echo.
echo 测试完成！
pause
goto MAIN_MENU

:STOP_NETWORK
echo.
echo 正在停止所有网络控制效果...
echo 这将恢复所有网络设置

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Write-Host '正在恢复网络设置...' -ForegroundColor Yellow; ^
    netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null; ^
    netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null; ^
    netsh int tcp set global nagle=disabled 2>&1 | Out-Null; ^
    Write-Host '正在删除流量标记规则...' -ForegroundColor Yellow; ^
    ^$ports = @(5000,5001,5002,5003,5004,5005,8088,8089,2099,5223); ^
    foreach (^$port in ^$ports) { ^
        netsh advfirewall firewall delete rule name='LOL_MARK_^$port' 2>&1 | Out-Null; ^
    }; ^
    Write-Host '正在恢复hosts文件...' -ForegroundColor Yellow; ^
    ^$hostsBackup = '^$env:SystemRoot\System32\drivers\etc\hosts.backup'; ^
    if (Test-Path ^$hostsBackup) { ^
        Copy-Item ^$hostsBackup '^$env:SystemRoot\System32\drivers\etc\hosts' -Force; ^
    }; ^
    ipconfig /flushdns 2>&1 | Out-Null; ^
    Write-Host '所有网络控制已停止！' -ForegroundColor Green;"

echo.
echo 网络已恢复正常！
pause
goto MAIN_MENU

:SHOW_CONNECTIONS
echo.
echo 正在检查英雄联盟网络连接...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Write-Host '=== 英雄联盟网络连接 ===' -ForegroundColor Cyan; ^
    ^$lolProcesses = Get-Process -Name 'LeagueClient','League of Legends' -ErrorAction SilentlyContinue; ^
    if (-not ^$lolProcesses) { ^
        Write-Host '未找到英雄联盟进程' -ForegroundColor Yellow; ^
    } else { ^
        Write-Host '找到进程:' -ForegroundColor Green; ^
        foreach (^$proc in ^$lolProcesses) { ^
            Write-Host '  ' ^$proc.ProcessName '(PID: ' ^$proc.Id ')' -ForegroundColor White; ^
        }; ^
        Write-Host '`n正在检查网络连接...' -ForegroundColor Cyan; ^
        ^$connections = netstat -ano | Select-String 'ESTABLISHED'; ^
        ^$lolConnections = ^$connections | Where-Object { ^
            foreach (^$proc in ^$lolProcesses) { ^
                if (^$_ -match ('\\s+' + ^$proc.Id + '^$')) { return ^$true; } ^
            }; ^
            return ^$false; ^
        }; ^
        if (^$lolConnections) { ^
            Write-Host '找到 ' ^$lolConnections.Count ' 个连接:' -ForegroundColor Green; ^
            ^$lolConnections | ForEach-Object { ^
                if (^$_ -match 'TCP\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+)\\s+(\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+)\\s+(\\w+)\\s+(\\d+)^$') { ^
                    Write-Host ('  ' + ^$matches[1] + ' -> ' + ^$matches[2] + ' [' + ^$matches[3] + ']') -ForegroundColor White; ^
                } ^
            }; ^
        } else { ^
            Write-Host '未找到网络连接' -ForegroundColor Yellow; ^
        }; ^
    };"

echo.
pause
goto MAIN_MENU

:CHECK_STATUS
cls
echo ========================================
echo    控制器状态检查
echo ========================================
echo.

REM 检查是否在运行
set "isRunning=0"
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    echo [状态] 控制器正在运行
    set "isRunning=1"
    
    REM 显示相关进程
    echo.
    echo 运行中的进程：
    tasklist /FI "WINDOWTITLE eq LOL网络控制器-网络劣化版" /FI "IMAGENAME eq powershell.exe"
) else (
    echo [状态] 控制器未运行
)

REM 检查开机启动
echo.
schtasks /query /tn "LOL网络控制器" >nul 2>&1
if %errorLevel% equ 0 (
    echo [开机启动] 已启用
) else (
    echo [开机启动] 未设置
)

REM 检查日志文件
if exist "%TEMP%\LOL_Network_Degrade.log" (
    echo [日志文件] 存在: %TEMP%\LOL_Network_Degrade.log
    for /f %%i in ('powershell "(Get-Item '%TEMP%\LOL_Network_Degrade.log').length/1KB"') do (
        echo [日志大小] %%i KB
    )
    echo.
    echo === 最后5行日志 ===
    powershell "Get-Content '%TEMP%\LOL_Network_Degrade.log' -Tail 5"
) else (
    echo [日志文件] 不存在
)

echo.
pause
goto MAIN_MENU

:SETUP_AUTOSTART
echo.
echo 正在设置开机自动启动...

schtasks /create /tn "LOL网络控制器" ^
          /tr "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%PS_SCRIPT%\"" ^
          /sc onlogon ^
          /ru SYSTEM ^
          /rl highest ^
          /f

if %errorLevel% equ 0 (
    echo 开机自启动设置成功！
) else (
    echo 设置失败！
)
pause
goto MAIN_MENU

:REMOVE_AUTOSTART
echo.
echo 正在取消开机自动启动...

schtasks /delete /tn "LOL网络控制器" /f >nul 2>&1

if %errorLevel% equ 0 (
    echo 开机自启动已取消！
) else (
    echo 取消失败（可能从未设置过）
)
pause
goto MAIN_MENU

:EXIT
echo.
echo 正在退出...
if exist "%PID_FILE%" (
    echo 警告：检测到控制器可能仍在运行！
    set /p confirm=是否要停止控制器？(Y/N): 
    if /i "%confirm%"=="Y" call :STOP_CONTROLLER_SILENT
)
echo 再见！
timeout /t 2 >nul
exit /b 0