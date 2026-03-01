@echo off
chcp 65001 >nul
title 英雄联盟网络控制器
color 0A

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%LOLNetworkController.ps1"
set "PID_FILE=%TEMP%\LOLController.pid"

echo ========================================
echo    英雄联盟网络控制器 V2.0
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
echo    英雄联盟网络控制器
echo ========================================
echo.
echo 请选择操作：
echo.
echo [1] 启动/重启控制器
echo [2] 停止控制器
echo [3] 查看状态
echo [4] 设置为开机启动
echo [5] 取消开机启动
echo [6] 查看日志
echo [7] 退出
echo.
set /p choice=请输入选项 (1-7): 

if "%choice%"=="1" goto START_CONTROLLER
if "%choice%"=="2" goto STOP_CONTROLLER
if "%choice%"=="3" goto CHECK_STATUS
if "%choice%"=="4" goto SETUP_AUTOSTART
if "%choice%"=="5" goto REMOVE_AUTOSTART
if "%choice%"=="6" goto VIEW_LOG
if "%choice%"=="7" goto EXIT
goto MAIN_MENU

:START_CONTROLLER
echo.
echo 正在检查当前运行状态...
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL网络控制器" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    echo 检测到控制器已在运行！
    set /p confirm=是否要重启？(Y/N): 
    if /i "%confirm%" neq "Y" goto MAIN_MENU
    call :STOP_CONTROLLER_SILENT
    timeout /t 2 >nul
)

echo.
echo 正在启动英雄联盟网络控制器...
echo 此窗口可以关闭，控制器将在后台运行

REM 创建PID文件记录进程ID
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ^
    "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""^
    ^$pid = [System.Diagnostics.Process]::GetCurrentProcess().Id; ^
    Set-Content -Path ''%PID_FILE%'' -Value ^$pid; ^
    ^$host.UI.RawUI.WindowTitle = ''LOL网络控制器''; ^
    . ''%PS_SCRIPT%''""' -Verb RunAs"

echo.
echo 控制器已启动！
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
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL网络控制器" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    taskkill /FI "WINDOWTITLE eq LOL网络控制器" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
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
taskkill /FI "WINDOWTITLE eq LOL网络控制器" /FI "IMAGENAME eq powershell.exe" /F >nul 2>&1
wmic process where "commandline like '%%LOLNetworkController%%'" delete >nul 2>&1
exit /b 0

:CHECK_STATUS
cls
echo ========================================
echo    控制器状态检查
echo ========================================
echo.

REM 检查是否在运行
set "isRunning=0"
tasklist /FI "IMAGENAME eq powershell.exe" /FI "WINDOWTITLE eq LOL网络控制器" 2>nul | find /I "powershell.exe" >nul
if %errorLevel% equ 0 (
    echo [状态] 控制器正在运行
    set "isRunning=1"
    
    REM 显示相关进程
    echo.
    echo 运行中的进程：
    tasklist /FI "WINDOWTITLE eq LOL网络控制器" /FI "IMAGENAME eq powershell.exe"
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
if exist "%TEMP%\LOL_Network_Control.log" (
    echo [日志文件] 存在: %TEMP%\LOL_Network_Control.log
    for /f %%i in ('powershell "(Get-Item '%TEMP%\LOL_Network_Control.log').length/1KB"') do (
        echo [日志大小] %%i KB
    )
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

:VIEW_LOG
cls
echo ========================================
echo    日志文件内容（最后50行）
echo ========================================
echo.

if exist "%TEMP%\LOL_Network_Control.log" (
    echo 日志文件: %TEMP%\LOL_Network_Control.log
    echo.
    powershell "Get-Content '%TEMP%\LOL_Network_Control.log' -Tail 50"
) else (
    echo 日志文件不存在！
)

echo.
echo ========================================
echo.
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