# 需要以管理员权限运行
# 英雄联盟网络控制器

param(
    [int]$LimitMinutes = 30,
    [int]$DisconnectMinutes = 1,
    [int]$RecoveryMinutes = 3
)

# 设置控制台标题（用于进程识别）
$host.UI.RawUI.WindowTitle = "LOL网络控制器"

# 英雄联盟进程名
$LOLProcessName = "LeagueClient"
$LOLExeName = "LeagueClient.exe"

# 防火墙规则名称
$FirewallRuleName = "TempBlockLOL"

# 记录文件路径
$LogFile = "$env:TEMP\LOL_Network_Control.log"

# 状态变量
$lolRunningTime = 0
$isBlocked = $false
$lastBlockTime = $null
$recoveryStartTime = $null
$nextRandomBlock = $null

# 日志函数
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    $logMessage | Out-File -FilePath $LogFile -Append
    # 可选：在控制台也显示
    Write-Host $logMessage -ForegroundColor Cyan
}

# 创建防火墙规则（如果不存在）
function Create-FirewallRule {
    try {
        # 检查规则是否存在
        $rule = Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue
        
        if (-not $rule) {
            Write-Log "正在创建防火墙规则..."
            
            # 获取LOL可执行文件路径
            $lolPath = ""
            
            # 尝试多种方式查找LOL路径
            $possiblePaths = @(
                "$env:ProgramData\Riot Games\Metadata\league_of_legends.live\league_of_legends.live.product_settings.yaml",
                "$env:LOCALAPPDATA\Riot Games\Riot Client\Config\RiotGamesPrivateSettings.yaml",
                "C:\Riot Games\League of Legends\LeagueClient.exe",
                "$env:ProgramFiles\Riot Games\League of Legends\LeagueClient.exe"
            )
            
            foreach ($configFile in $possiblePaths) {
                if (Test-Path $configFile) {
                    if ($configFile -like "*.yaml" -or $configFile -like "*.yml") {
                        $content = Get-Content $configFile -Raw
                        if ($content -match '"product_install_full_path"\s*:\s*"([^"]+)"') {
                            $lolPath = $matches[1]
                            break
                        }
                    } else {
                        $lolPath = $configFile
                        break
                    }
                }
            }
            
            # 如果还是找不到，使用默认路径
            if ([string]::IsNullOrEmpty($lolPath)) {
                $lolPath = "$env:ProgramFiles\Riot Games\League of Legends\LeagueClient.exe"
            }
            
            Write-Log "使用路径: $lolPath"
            
            if (Test-Path $lolPath) {
                New-NetFirewallRule -DisplayName $FirewallRuleName `
                                   -Program $lolPath `
                                   -Direction Outbound `
                                   -Action Block `
                                   -Enabled False `
                                   -ErrorAction Stop
                Write-Log "防火墙规则创建成功: $FirewallRuleName"
            } else {
                Write-Log "警告：未找到LeagueClient.exe，将在检测到进程时创建规则"
            }
        } else {
            Write-Log "防火墙规则已存在"
        }
    }
    catch {
        Write-Log "防火墙规则创建失败: $($_.Exception.Message)"
    }
}

# 启用/禁用防火墙规则
function Set-LOLNetworkAccess {
    param([bool]$Block)
    
    try {
        # 确保规则存在
        Create-FirewallRule
        
        if ($Block) {
            Enable-NetFirewallRule -DisplayName $FirewallRuleName
            Write-Log "已阻断英雄联盟网络连接"
        }
        else {
            Disable-NetFirewallRule -DisplayName $FirewallRuleName
            Write-Log "已恢复英雄联盟网络连接"
        }
        return $true
    }
    catch {
        Write-Log "网络控制失败: $($_.Exception.Message)"
        return $false
    }
}

# 检查LOL是否运行
function Check-LOLRunning {
    $process = Get-Process -Name $LOLProcessName -ErrorAction SilentlyContinue
    if ($process) {
        # 如果有进程但防火墙规则不存在，尝试创建
        if (-not (Get-NetFirewallRule -DisplayName $FirewallRuleName -ErrorAction SilentlyContinue)) {
            $lolPath = $process.Path
            if ($lolPath -and (Test-Path $lolPath)) {
                try {
                    New-NetFirewallRule -DisplayName $FirewallRuleName `
                                       -Program $lolPath `
                                       -Direction Outbound `
                                       -Action Block `
                                       -Enabled False `
                                       -ErrorAction Stop
                    Write-Log "检测到LOL运行时创建了防火墙规则"
                }
                catch {
                    Write-Log "创建防火墙规则失败: $($_.Exception.Message)"
                }
            }
        }
        return $true
    }
    return $false
}

# 生成随机时间（分钟）
function Get-RandomTime {
    param([int]$MinMinutes, [int]$MaxMinutes)
    return Get-Random -Minimum $MinMinutes -Maximum ($MaxMinutes + 1)
}

# 主循环
Write-Log "========================================"
Write-Log "英雄联盟网络控制器启动"
Write-Log "进程ID: $PID"
Write-Log "设置: 限制时间=${LimitMinutes}分钟, 断网=${DisconnectMinutes}分钟, 恢复=${RecoveryMinutes}分钟"
Write-Log "========================================"

# 创建防火墙规则
Create-FirewallRule

# 主监控循环
while ($true) {
    try {
        $now = Get-Date
        
        # 检查LOL是否运行
        if (Check-LOLRunning) {
            if (-not $isBlocked) {
                $lolRunningTime++
                Write-Log "LOL运行中 (累计: ${lolRunningTime}分钟)"
                
                # 检查是否超过限制时间
                if ($lolRunningTime -ge $LimitMinutes -and -not $lastBlockTime) {
                    Write-Log "检测到运行超过${LimitMinutes}分钟，开始首次断网"
                    if (Set-LOLNetworkAccess -Block $true) {
                        $isBlocked = $true
                        $lastBlockTime = $now
                        $lolRunningTime = 0
                    }
                }
                
                # 恢复期后的随机断网
                if ($recoveryStartTime -and -not $nextRandomBlock) {
                    $recoveryElapsed = ($now - $recoveryStartTime).TotalMinutes
                    if ($recoveryElapsed -ge $RecoveryMinutes) {
                        $randomDelay = Get-RandomTime -MinMinutes 1 -MaxMinutes 10
                        $nextRandomBlock = $now.AddMinutes($randomDelay)
                        Write-Log "恢复期结束，将在${randomDelay}分钟后随机断网"
                    }
                }
                
                # 检查随机断网时间
                if ($nextRandomBlock -and $now -ge $nextRandomBlock) {
                    Write-Log "随机断网时间到"
                    if (Set-LOLNetworkAccess -Block $true) {
                        $isBlocked = $true
                        $lastBlockTime = $now
                        $nextRandomBlock = $null
                    }
                }
            }
            else {
                # LOL正在被阻断网络
                $blockElapsed = ($now - $lastBlockTime).TotalMinutes
                
                if ($blockElapsed -ge $DisconnectMinutes) {
                    Write-Log "断网${DisconnectMinutes}分钟结束，恢复网络"
                    if (Set-LOLNetworkAccess -Block $false) {
                        $isBlocked = $false
                        $lastBlockTime = $null
                        $recoveryStartTime = $now
                    }
                }
            }
        }
        else {
            # LOL没有运行
            if ($lolRunningTime -gt 0) {
                Write-Log "LOL已关闭，重置计时器"
                $lolRunningTime = 0
                $recoveryStartTime = $null
                $nextRandomBlock = $null
            }
            
            # 如果之前阻断了网络，确保恢复
            if ($isBlocked) {
                Write-Log "LOL已关闭，恢复网络连接"
                Set-LOLNetworkAccess -Block $false | Out-Null
                $isBlocked = $false
                $lastBlockTime = $null
            }
        }
        
        # 等待1分钟
        Start-Sleep -Seconds 60
    }
    catch {
        Write-Log "监控循环出错: $($_.Exception.Message)"
        Start-Sleep -Seconds 30
    }
}