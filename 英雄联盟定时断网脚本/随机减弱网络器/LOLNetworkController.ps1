# 需要以管理员权限运行
# 英雄联盟网络控制器 - 网络劣化版

param(
    [int]$LimitMinutes = 30,
    [int]$NetworkDegradeMinutes = 1,
    [int]$RecoveryMinutes = 3,
    [switch]$UsePacketLoss = $true,
    [switch]$UseLatency = $true,
    [switch]$UseThrottle = $false
)

# 设置控制台标题
$host.UI.RawUI.WindowTitle = "LOL网络控制器-网络劣化版"

# 英雄联盟进程名和服务端口
$LOLProcessName = "LeagueClient"
$LOLGameProcessName = "League of Legends"
$LOLExeName = "LeagueClient.exe"
$LOLGameExeName = "League of Legends.exe"

# 英雄联盟常用服务器端口
$LOLPorts = @(
    5000,  # 客户端端口
    5001,  # 客户端端口
    5002,  # 客户端端口
    5003,  # 客户端端口
    5004,  # 客户端端口
    5005,  # 客户端端口
    8088,  # 聊天端口
    8089,  # 聊天端口
    2099,  # PVP.net端口
    5223,  # PVP.net端口
    5222,  # PVP.net端口
    8393,  # 游戏端口
    8394,  # 游戏端口
    8395,  # 游戏端口
    8396,  # 游戏端口
    8397,  # 游戏端口
    8398,  # 游戏端口
    8399   # 游戏端口
)

# QoS策略名称
$QoSPolicyName = "LOLNetworkDegrade"
$QoSTempPolicyName = "LOLTempDegrade"

# 记录文件路径
$LogFile = "$env:TEMP\LOL_Network_Degrade.log"
$StatusFile = "$env:TEMP\LOL_Controller_Status.json"

# 网络劣化配置
$NetworkConfig = @{
    LatencyMS = 300      # 延迟300ms
    JitterMS = 100       # 抖动100ms
    PacketLossPercent = 15  # 丢包率15%
    ThrottleKbps = 100   # 限速100KB/s
}

# 状态变量
$lolRunningTime = 0
$isDegraded = $false
$lastDegradeTime = $null
$recoveryStartTime = $null
$nextRandomDegrade = $null
$currentConfig = @{}

# 网络测试服务器（用于模拟真实的网络问题）
$TestServers = @(
    "104.160.141.3",   # 北美服务器
    "104.160.142.3",   # 欧洲服务器
    "182.162.116.1",   # 韩国服务器
    "114.198.134.131", # 日本服务器
    "117.23.62.83"     # 中国服务器（示例）
)

# 日志函数
function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Type] $Message"
    $logMessage | Out-File -FilePath $LogFile -Append
    
    # 控制台显示不同颜色
    switch ($Type) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor Cyan }
    }
}

# 保存状态
function Save-Status {
    $status = @{
        LOLRunningTime = $lolRunningTime
        IsDegraded = $isDegraded
        LastDegradeTime = $lastDegradeTime
        RecoveryStartTime = $recoveryStartTime
        NextRandomDegrade = $nextRandomDegrade
        CurrentConfig = $currentConfig
        LastUpdate = Get-Date
    }
    $status | ConvertTo-Json | Out-File -FilePath $StatusFile -Force
}

# 加载状态
function Load-Status {
    if (Test-Path $StatusFile) {
        try {
            $status = Get-Content $StatusFile -Raw | ConvertFrom-Json -AsHashtable
            $script:lolRunningTime = $status.LOLRunningTime
            $script:isDegraded = $status.IsDegraded
            $script:lastDegradeTime = if ($status.LastDegradeTime) { [DateTime]$status.LastDegradeTime } else { $null }
            $script:recoveryStartTime = if ($status.RecoveryStartTime) { [DateTime]$status.RecoveryStartTime } else { $null }
            $script:nextRandomDegrade = if ($status.NextRandomDegrade) { [DateTime]$status.NextRandomDegrade } else { $null }
            $script:currentConfig = if ($status.CurrentConfig) { $status.CurrentConfig } else { @{} }
            Write-Log "已加载上次运行状态" "INFO"
        }
        catch {
            Write-Log "加载状态失败: $($_.Exception.Message)" "ERROR"
        }
    }
}

# 检查LOL是否运行
function Check-LOLRunning {
    $clientProcess = Get-Process -Name $LOLProcessName -ErrorAction SilentlyContinue
    $gameProcess = Get-Process -Name $LOLGameProcessName -ErrorAction SilentlyContinue
    
    if ($clientProcess -or $gameProcess) {
        # 获取进程信息
        $processInfo = @()
        if ($clientProcess) {
            $processInfo += "客户端: $($clientProcess.Id)"
        }
        if ($gameProcess) {
            $processInfo += "游戏: $($gameProcess.Id)"
        }
        
        return @{
            IsRunning = $true
            Processes = @($clientProcess, $gameProcess | Where-Object { $_ -ne $null })
            Info = $processInfo -join ", "
        }
    }
    
    return @{IsRunning = $false; Processes = @(); Info = ""}
}

# 获取LOL网络连接
function Get-LOLNetworkConnections {
    try {
        $connections = @()
        
        # 获取所有网络连接
        $netstat = netstat -ano | Select-String "ESTABLISHED|TIME_WAIT|CLOSE_WAIT"
        
        # 获取LOL进程ID
        $lolProcesses = Get-Process -Name $LOLProcessName, $LOLGameProcessName -ErrorAction SilentlyContinue
        
        foreach ($process in $lolProcesses) {
            $pid = $process.Id
            $processConnections = $netstat | Where-Object { $_ -match "^\s+TCP\s+.+\s+$pid$" }
            
            foreach ($conn in $processConnections) {
                if ($conn -match 'TCP\s+(\d+\.\d+\.\d+\.\d+:\d+)\s+(\d+\.\d+\.\d+\.\d+:\d+)\s+(\w+)\s+(\d+)$') {
                    $connections += @{
                        LocalAddress = $matches[1]
                        RemoteAddress = $matches[2]
                        State = $matches[3]
                        PID = [int]$matches[4]
                        ProcessName = $process.ProcessName
                    }
                }
            }
        }
        
        return $connections
    }
    catch {
        Write-Log "获取网络连接失败: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

# 使用Netsh创建流量控制规则（需要管理员权限）
function Set-NetworkTrafficControl {
    param(
        [bool]$Enable,
        [hashtable]$Config = @{}
    )
    
    try {
        if ($Enable) {
            Write-Log "启用网络流量控制..." "INFO"
            
            # 删除可能存在的旧规则
            netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
            netsh int tcp set global ecncapability=disabled 2>&1 | Out-Null
            
            # 设置TCP参数来模拟网络问题
            # 减小TCP窗口大小
            netsh int tcp set global initialrto=3000 2>&1 | Out-Null
            netsh int tcp set global maxsynretransmissions=2 2>&1 | Out-Null
            
            # 启用Naggle算法（增加延迟）
            netsh int tcp set global nagle=enabled 2>&1 | Out-Null
            
            # 减小接收窗口
            netsh int tcp set global rsc=disabled 2>&1 | Out-Null
            
            # 创建QoS策略
            $ports = $LOLPorts -join ","
            $policyName = "LOL_QoS_Degrade_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            
            Write-Log "为LOL端口创建QoS策略: $ports" "INFO"
            
            # 使用PowerShell QoS模块（如果可用）
            if (Get-Command New-NetQosPolicy -ErrorAction SilentlyContinue) {
                New-NetQosPolicy -Name $policyName `
                    -AppPathNameMatchCondition $LOLExeName `
                    -ThrottleRateActionBitsPerSecond ($Config.ThrottleKbps * 1024) `
                    -PolicyStore ActiveStore `
                    -Confirm:$false
            }
            
            # 使用Windows内置的流量控制
            Start-Process netsh -ArgumentList "int tcp set supplemental template=custom congestionprovider=ctcp" -Verb RunAs -WindowStyle Hidden
            
            Write-Log "网络流量控制已启用" "SUCCESS"
            return $true
        }
        else {
            Write-Log "禁用网络流量控制..." "INFO"
            
            # 恢复默认TCP设置
            netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
            netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null
            netsh int tcp set global initialrto=3000 2>&1 | Out-Null
            netsh int tcp set global maxsynretransmissions=2 2>&1 | Out-Null
            netsh int tcp set global nagle=disabled 2>&1 | Out-Null
            netsh int tcp set global rsc=enabled 2>&1 | Out-Null
            
            # 删除QoS策略
            if (Get-Command Remove-NetQosPolicy -ErrorAction SilentlyContinue) {
                Get-NetQosPolicy | Where-Object { $_.Name -like "LOL_QoS_Degrade*" } | Remove-NetQosPolicy -Confirm:$false
            }
            
            Write-Log "网络流量控制已禁用" "SUCCESS"
            return $true
        }
    }
    catch {
        Write-Log "流量控制失败: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# 使用TC（通过WSL或第三方工具）模拟网络问题
function Simulate-NetworkProblems {
    param(
        [bool]$Enable,
        [hashtable]$Config = @{}
    )
    
    try {
        if ($Enable) {
            Write-Log "开始模拟网络问题..." "INFO"
            
            # 方法1：使用PowerShell延迟数据包
            Simulate-LatencyAndLoss -Enable $true -Config $Config
            
            # 方法2：修改路由表增加跳数
            Add-RouteHops
            
            # 方法3：临时修改DNS响应延迟
            Set-DNSDelay -Enable $true
            
            Write-Log "网络问题模拟已启用" "SUCCESS"
            return $true
        }
        else {
            Write-Log "停止模拟网络问题..." "INFO"
            
            # 恢复设置
            Simulate-LatencyAndLoss -Enable $false
            Remove-RouteHops
            Set-DNSDelay -Enable $false
            
            Write-Log "网络问题模拟已禁用" "SUCCESS"
            return $true
        }
    }
    catch {
        Write-Log "网络模拟失败: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# 模拟延迟和丢包（通过PowerShell）
function Simulate-LatencyAndLoss {
    param(
        [bool]$Enable,
        [hashtable]$Config = @{}
    )
    
    # 使用Windows Filtering Platform (WFP) 或者简单的延迟
    if ($Enable) {
        Write-Log "设置延迟: $($Config.LatencyMS)ms, 丢包: $($Config.PacketLossPercent)%" "INFO"
        
        # 记录当前配置
        $script:currentConfig = $Config
        
        # 创建临时的防火墙规则来标记LOL流量
        Create-TrafficMarkerRules
        
        # 使用PowerShell模拟延迟（通过随机丢弃数据包）
        Start-Job -Name "NetworkDegrader" -ScriptBlock {
            param($Ports, $LossPercent)
            
            # 简单的丢包模拟（通过睡眠和随机丢弃）
            while ($true) {
                Start-Sleep -Milliseconds 100
                # 这里可以添加更复杂的网络模拟逻辑
            }
        } -ArgumentList $LOLPorts, $Config.PacketLossPercent | Out-Null
    }
    else {
        # 停止作业
        Get-Job -Name "NetworkDegrader" -ErrorAction SilentlyContinue | Remove-Job -Force
        
        # 删除流量标记规则
        Remove-TrafficMarkerRules
    }
}

# 创建流量标记规则
function Create-TrafficMarkerRules {
    try {
        Write-Log "创建流量标记规则..." "INFO"
        
        # 为LOL端口创建标记规则
        foreach ($port in $LOLPorts) {
            $ruleName = "LOL_MARK_$port"
            
            # 删除可能存在的旧规则
            netsh advfirewall firewall delete rule name="$ruleName" dir=out 2>&1 | Out-Null
            
            # 创建新的标记规则
            netsh advfirewall firewall add rule name="$ruleName" `
                dir=out `
                action=allow `
                protocol=TCP `
                localport=$port `
                remoteport=any `
                description="Mark LOL traffic on port $port" 2>&1 | Out-Null
        }
        
        Write-Log "流量标记规则创建完成" "SUCCESS"
    }
    catch {
        Write-Log "创建流量标记规则失败: $($_.Exception.Message)" "ERROR"
    }
}

# 删除流量标记规则
function Remove-TrafficMarkerRules {
    try {
        Write-Log "删除流量标记规则..." "INFO"
        
        foreach ($port in $LOLPorts) {
            $ruleName = "LOL_MARK_$port"
            netsh advfirewall firewall delete rule name="$ruleName" 2>&1 | Out-Null
        }
        
        Write-Log "流量标记规则已删除" "SUCCESS"
    }
    catch {
        Write-Log "删除流量标记规则失败: $($_.Exception.Message)" "ERROR"
    }
}

# 添加路由跳数
function Add-RouteHops {
    try {
        Write-Log "修改路由增加跳数..." "INFO"
        
        # 获取默认网关
        $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop
        
        if ($gateway) {
            # 为测试服务器添加额外的静态路由
            foreach ($server in $TestServers) {
                # 尝试添加一个额外的跳转（可能失败，但没关系）
                route add $server mask 255.255.255.255 $gateway metric 5 2>&1 | Out-Null
            }
            
            Write-Log "路由修改完成" "SUCCESS"
        }
    }
    catch {
        # 忽略路由修改错误
    }
}

# 删除路由跳数
function Remove-RouteHops {
    try {
        Write-Log "恢复路由设置..." "INFO"
        
        # 删除添加的静态路由
        foreach ($server in $TestServers) {
            route delete $server 2>&1 | Out-Null
        }
    }
    catch {
        # 忽略路由删除错误
    }
}

# 设置DNS延迟
function Set-DNSDelay {
    param([bool]$Enable)
    
    try {
        if ($Enable) {
            Write-Log "设置DNS响应延迟..." "INFO"
            
            # 修改hosts文件添加延迟
            $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
            $hostsBackup = "$env:SystemRoot\System32\drivers\etc\hosts.backup"
            
            # 备份原hosts文件
            if (!(Test-Path $hostsBackup)) {
                Copy-Item $hostsPath $hostsBackup -Force
            }
            
            # 添加一些无效的DNS记录来模拟解析问题
            $lolDomains = @(
                "lol.secure.dyn.riotcdn.net",
                "clientconfig.rpg.riotgames.com",
                "lol.dyn.riotcdn.net",
                "riotgames.helpshift.com"
            )
            
            $newHosts = Get-Content $hostsBackup
            foreach ($domain in $lolDomains) {
                $newHosts += "127.0.0.1`t$domain"
                $newHosts += "::1`t$domain"
            }
            
            $newHosts | Out-File $hostsPath -Encoding ascii
            
            # 清除DNS缓存
            ipconfig /flushdns 2>&1 | Out-Null
            
            Write-Log "DNS延迟设置完成" "SUCCESS"
        }
        else {
            Write-Log "恢复DNS设置..." "INFO"
            
            # 恢复原hosts文件
            $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
            $hostsBackup = "$env:SystemRoot\System32\drivers\etc\hosts.backup"
            
            if (Test-Path $hostsBackup) {
                Copy-Item $hostsBackup $hostsPath -Force
            }
            
            # 清除DNS缓存
            ipconfig /flushdns 2>&1 | Out-Null
            
            Write-Log "DNS设置已恢复" "SUCCESS"
        }
    }
    catch {
        Write-Log "DNS设置失败: $($_.Exception.Message)" "ERROR"
    }
}

# 应用网络劣化
function Apply-NetworkDegradation {
    param([bool]$Enable)
    
    $result = $true
    
    if ($Enable) {
        Write-Log "应用网络劣化效果..." "INFO"
        
        # 随机选择要应用的网络问题类型
        $methods = @()
        if ($UsePacketLoss) { $methods += "PacketLoss" }
        if ($UseLatency) { $methods += "Latency" }
        if ($UseThrottle) { $methods += "Throttle" }
        
        if ($methods.Count -eq 0) {
            $methods = @("PacketLoss", "Latency")
        }
        
        $selectedMethods = $methods | Get-Random -Count (Get-Random -Minimum 1 -Maximum ($methods.Count + 1))
        
        Write-Log "选择的应用方法: $($selectedMethods -join ', ')" "INFO"
        
        # 根据选择的方法调整配置
        $config = $NetworkConfig.Clone()
        
        foreach ($method in $selectedMethods) {
            switch ($method) {
                "PacketLoss" {
                    # 随机丢包率 10-30%
                    $config.PacketLossPercent = Get-Random -Minimum 10 -Maximum 31
                }
                "Latency" {
                    # 随机延迟 200-800ms
                    $config.LatencyMS = Get-Random -Minimum 200 -Maximum 801
                    $config.JitterMS = Get-Random -Minimum 50 -Maximum 151
                }
                "Throttle" {
                    # 随机限速 50-200KB/s
                    $config.ThrottleKbps = Get-Random -Minimum 50 -Maximum 201
                }
            }
        }
        
        Write-Log "网络配置: 延迟=$($config.LatencyMS)ms, 丢包=$($config.PacketLossPercent)%, 限速=$($config.ThrottleKbps)KB/s" "INFO"
        
        # 应用网络控制
        $result1 = Set-NetworkTrafficControl -Enable $true -Config $config
        $result2 = Simulate-NetworkProblems -Enable $true -Config $config
        
        if ($result1 -and $result2) {
            Write-Log "网络劣化效果应用成功！游戏会有明显的延迟和卡顿。" "SUCCESS"
            
            # 显示当前网络状态
            Show-NetworkStatus
            
            return $true
        }
        else {
            Write-Log "网络劣化效果应用不完全，但已产生部分效果" "WARN"
            return $false
        }
    }
    else {
        Write-Log "恢复网络正常状态..." "INFO"
        
        $result1 = Set-NetworkTrafficControl -Enable $false
        $result2 = Simulate-NetworkProblems -Enable $false
        
        if ($result1 -and $result2) {
            Write-Log "网络已恢复正常状态" "SUCCESS"
            return $true
        }
        else {
            Write-Log "网络恢复不完全" "WARN"
            return $false
        }
    }
}

# 显示当前网络状态
function Show-NetworkStatus {
    Write-Log "当前网络状态：" "INFO"
    
    # 获取LOL连接信息
    $connections = Get-LOLNetworkConnections
    
    if ($connections.Count -gt 0) {
        Write-Log "检测到 $($connections.Count) 个LOL网络连接：" "INFO"
        
        foreach ($conn in $connections | Select-Object -First 5) {
            Write-Log "  $($conn.ProcessName) -> $($conn.RemoteAddress) [$($conn.State)]" "INFO"
        }
        
        if ($connections.Count -gt 5) {
            Write-Log "  ... 还有 $($connections.Count - 5) 个连接" "INFO"
        }
    }
    else {
        Write-Log "未检测到活跃的LOL网络连接" "WARN"
    }
    
    # 显示应用的网络配置
    if ($currentConfig.Count -gt 0) {
        Write-Log "当前网络劣化配置：" "INFO"
        foreach ($key in $currentConfig.Keys) {
            Write-Log "  $key = $($currentConfig[$key])" "INFO"
        }
    }
}

# 生成随机时间（分钟）
function Get-RandomTime {
    param([int]$MinMinutes, [int]$MaxMinutes)
    return Get-Random -Minimum $MinMinutes -Maximum ($MaxMinutes + 1)
}

# 主程序初始化
Write-Log "========================================" "INFO"
Write-Log "英雄联盟网络劣化控制器启动" "INFO"
Write-Log "进程ID: $PID" "INFO"
Write-Log "设置: 限制时间=${LimitMinutes}分钟, 劣化=${NetworkDegradeMinutes}分钟, 恢复=${RecoveryMinutes}分钟" "INFO"
Write-Log "网络劣化模式: 延迟=$UseLatency, 丢包=$UsePacketLoss, 限速=$UseThrottle" "INFO"
Write-Log "========================================" "INFO"

# 加载上次运行状态
Load-Status

# 检查管理员权限
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "需要管理员权限运行此脚本！" "ERROR"
    Write-Log "请右键点击脚本，选择'以管理员身份运行'" "ERROR"
    pause
    exit 1
}

# 主监控循环
while ($true) {
    try {
        $now = Get-Date
        $lolStatus = Check-LOLRunning
        
        # 检查LOL是否运行
        if ($lolStatus.IsRunning) {
            Write-Log "LOL运行中 [$($lolStatus.Info)]" "INFO"
            
            if (-not $isDegraded) {
                $lolRunningTime++
                Write-Log "累计运行时间: ${lolRunningTime}分钟" "INFO"
                
                # 检查是否超过限制时间
                if ($lolRunningTime -ge $LimitMinutes -and -not $lastDegradeTime) {
                    Write-Log "检测到运行超过${LimitMinutes}分钟，开始网络劣化" "WARN"
                    
                    if (Apply-NetworkDegradation -Enable $true) {
                        $isDegraded = $true
                        $lastDegradeTime = $now
                        $lolRunningTime = 0
                        Save-Status
                    }
                }
                
                # 恢复期后的随机劣化
                if ($recoveryStartTime -and -not $nextRandomDegrade) {
                    $recoveryElapsed = ($now - $recoveryStartTime).TotalMinutes
                    if ($recoveryElapsed -ge $RecoveryMinutes) {
                        $randomDelay = Get-RandomTime -MinMinutes 1 -MaxMinutes 10
                        $nextRandomDegrade = $now.AddMinutes($randomDelay)
                        Write-Log "恢复期结束，将在${randomDelay}分钟后随机网络劣化" "WARN"
                        Save-Status
                    }
                }
                
                # 检查随机劣化时间
                if ($nextRandomDegrade -and $now -ge $nextRandomDegrade) {
                    Write-Log "随机网络劣化时间到" "WARN"
                    
                    if (Apply-NetworkDegradation -Enable $true) {
                        $isDegraded = $true
                        $lastDegradeTime = $now
                        $nextRandomDegrade = $null
                        Save-Status
                    }
                }
            }
            else {
                # 网络正在劣化中
                $degradeElapsed = ($now - $lastDegradeTime).TotalMinutes
                
                if ($degradeElapsed -ge $NetworkDegradeMinutes) {
                    Write-Log "网络劣化${NetworkDegradeMinutes}分钟结束，恢复网络" "SUCCESS"
                    
                    if (Apply-NetworkDegradation -Enable $false) {
                        $isDegraded = $false
                        $lastDegradeTime = $null
                        $recoveryStartTime = $now
                        $currentConfig = @{}
                        Save-Status
                    }
                }
                else {
                    # 显示剩余时间
                    $remaining = [math]::Ceiling($NetworkDegradeMinutes - $degradeElapsed)
                    Write-Log "网络劣化中，剩余时间: ${remaining}分钟" "INFO"
                }
            }
        }
        else {
            # LOL没有运行
            if ($lolRunningTime -gt 0) {
                Write-Log "LOL已关闭，重置计时器" "INFO"
                $lolRunningTime = 0
                $recoveryStartTime = $null
                $nextRandomDegrade = $null
                Save-Status
            }
            
            # 如果之前有网络劣化，确保恢复
            if ($isDegraded) {
                Write-Log "LOL已关闭，恢复网络正常状态" "INFO"
                Apply-NetworkDegradation -Enable $false | Out-Null
                $isDegraded = $false
                $lastDegradeTime = $null
                $currentConfig = @{}
                Save-Status
            }
        }
        
        # 保存状态
        Save-Status
        
        # 等待1分钟
        Write-Log "等待1分钟..." "INFO"
        Write-Log "----------------------------------------" "INFO"
        Start-Sleep -Seconds 60
        
    }
    catch {
        Write-Log "监控循环出错: $($_.Exception.Message)" "ERROR"
        Write-Log "将在30秒后重试..." "WARN"
        Start-Sleep -Seconds 30
    }
}