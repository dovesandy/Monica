@echo off
chcp 65001 >nul
REM 英雄联盟网络控制器快速启动脚本
REM 双击此文件启动主控制界面

echo 正在启动英雄联盟网络控制器...
echo 请稍候...

cd /d "%~dp0"

REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo 需要管理员权限！
    echo 请右键点击此文件，选择"以管理员身份运行"
    timeout /t 5
    exit /b
)

start "" "LOLNetworkController.bat"