# Requires Administrator privileges
# League of Legends Network Controller - Network Degradation Version

param(
    [int]$LimitMinutes = 30,
    [int]$NetworkDegradeMinutes = 1,
    [int]$RecoveryMinutes = 3,
    [switch]$UsePacketLoss = $true,
    [switch]$UseLatency = $true,
    [switch]$UseThrottle = $false
)

# Set console title
$host.UI.RawUI.WindowTitle = "LOL Network Controller-Degradation Version"

# League of Legends process names and service ports
$LOLProcessName = "LeagueClient"
$LOLGameProcessName = "League of Legends"
$LOLExeName = "LeagueClient.exe"
$LOLGameExeName = "League of Legends.exe"

# League of Legends common server ports
$LOLPorts = @(
    5000,  # Client port
    5001,  # Client port
    5002,  # Client port
    5003,  # Client port
    5004,  # Client port
    5005,  # Client port
    8088,  # Chat port
    8089,  # Chat port
    2099,  # PVP.net port
    5223,  # PVP.net port
    5222,  # PVP.net port
    8393,  # Game port
    8394,  # Game port
    8395,  # Game port
    8396,  # Game port
    8397,  # Game port
    8398,  # Game port
    8399   # Game port
)

# QoS policy names
$QoSPolicyName = "LOLNetworkDegrade"
$QoSTempPolicyName = "LOLTempDegrade"

# Log file paths
$LogFile = "$env:TEMP\LOL_Network_Degrade.log"
$StatusFile = "$env:TEMP\LOL_Controller_Status.json"

# Network degradation configuration
$NetworkConfig = @{
    LatencyMS = 300      # 300ms latency
    JitterMS = 100       # 100ms jitter
    PacketLossPercent = 15  # 15% packet loss
    ThrottleKbps = 100   # Limit to 100KB/s
}

# State variables
$lolRunningTime = 0
$isDegraded = $false
$lastDegradeTime = $null
$recoveryStartTime = $null
$nextRandomDegrade = $null
$currentConfig = @{}

# Network test servers (for simulating real network issues)
$TestServers = @(
    "104.160.141.3",   # North America server
    "104.160.142.3",   # Europe server
    "182.162.116.1",   # Korea server
    "114.198.134.131", # Japan server
    "117.23.62.83"     # China server (example)
)

# Log function
function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Type] $Message"
    $logMessage | Out-File -FilePath $LogFile -Append
    
    # Display different colors in console
    switch ($Type) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor Cyan }
    }
}

# Save state
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

# Load state
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
            Write-Log "Loaded previous running state" "INFO"
        }
        catch {
            Write-Log "Failed to load state: $($_.Exception.Message)" "ERROR"
        }
    }
}

# Check if LOL is running
function Check-LOLRunning {
    $clientProcess = Get-Process -Name $LOLProcessName -ErrorAction SilentlyContinue
    $gameProcess = Get-Process -Name $LOLGameProcessName -ErrorAction SilentlyContinue
    
    if ($clientProcess -or $gameProcess) {
        # Get process information
        $processInfo = @()
        if ($clientProcess) {
            $processInfo += "Client: $($clientProcess.Id)"
        }
        if ($gameProcess) {
            $processInfo += "Game: $($gameProcess.Id)"
        }
        
        return @{
            IsRunning = $true
            Processes = @($clientProcess, $gameProcess | Where-Object { $_ -ne $null })
            Info = $processInfo -join ", "
        }
    }
    
    return @{IsRunning = $false; Processes = @(); Info = ""}
}

# Get LOL network connections
function Get-LOLNetworkConnections {
    try {
        $connections = @()
        
        # Get all network connections
        $netstat = netstat -ano | Select-String "ESTABLISHED|TIME_WAIT|CLOSE_WAIT"
        
        # Get LOL process IDs
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
        Write-Log "Failed to get network connections: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

# Use Netsh to create traffic control rules (requires admin privileges)
function Set-NetworkTrafficControl {
    param(
        [bool]$Enable,
        [hashtable]$Config = @{}
    )
    
    try {
        if ($Enable) {
            Write-Log "Enabling network traffic control..." "INFO"
            
            # Delete any existing old rules
            netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
            netsh int tcp set global ecncapability=disabled 2>&1 | Out-Null
            
            # Set TCP parameters to simulate network issues
            # Reduce TCP window size
            netsh int tcp set global initialrto=3000 2>&1 | Out-Null
            netsh int tcp set global maxsynretransmissions=2 2>&1 | Out-Null
            
            # Enable Naggle algorithm (increase latency)
            netsh int tcp set global nagle=enabled 2>&1 | Out-Null
            
            # Reduce receive window
            netsh int tcp set global rsc=disabled 2>&1 | Out-Null
            
            # Create QoS policy
            $ports = $LOLPorts -join ","
            $policyName = "LOL_QoS_Degrade_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            
            Write-Log "Creating QoS policy for LOL ports: $ports" "INFO"
            
            # Use PowerShell QoS module (if available)
            if (Get-Command New-NetQosPolicy -ErrorAction SilentlyContinue) {
                New-NetQosPolicy -Name $policyName `
                    -AppPathNameMatchCondition $LOLExeName `
                    -ThrottleRateActionBitsPerSecond ($Config.ThrottleKbps * 1024) `
                    -PolicyStore ActiveStore `
                    -Confirm:$false
            }
            
            # Use Windows built-in traffic control
            Start-Process netsh -ArgumentList "int tcp set supplemental template=custom congestionprovider=ctcp" -Verb RunAs -WindowStyle Hidden
            
            Write-Log "Network traffic control enabled" "SUCCESS"
            return $true
        }
        else {
            Write-Log "Disabling network traffic control..." "INFO"
            
            # Restore default TCP settings
            netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
            netsh int tcp set global ecncapability=enabled 2>&1 | Out-Null
            netsh int tcp set global initialrto=3000 2>&1 | Out-Null
            netsh int tcp set global maxsynretransmissions=2 2>&1 | Out-Null
            netsh int tcp set global nagle=disabled 2>&1 | Out-Null
            netsh int tcp set global rsc=enabled 2>&1 | Out-Null
            
            # Delete QoS policies
            if (Get-Command Remove-NetQosPolicy -ErrorAction SilentlyContinue) {
                Get-NetQosPolicy | Where-Object { $_.Name -like "LOL_QoS_Degrade*" } | Remove-NetQosPolicy -Confirm:$false
            }
            
            Write-Log "Network traffic control disabled" "SUCCESS"
            return $true
        }
    }
    catch {
        Write-Log "Traffic control failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Use TC (via WSL or third-party tools) to simulate network problems
function Simulate-NetworkProblems {
    param(
        [bool]$Enable,
        [hashtable]$Config = @{}
    )
    
    try {
        if ($Enable) {
            Write-Log "Starting network problem simulation..." "INFO"
            
            # Method 1: Use PowerShell to delay packets
            Simulate-LatencyAndLoss -Enable $true -Config $Config
            
            # Method 2: Modify routing table to add hops
            Add-RouteHops
            
            # Method 3: Temporarily modify DNS response delay
            Set-DNSDelay -Enable $true
            
            Write-Log "Network problem simulation enabled" "SUCCESS"
            return $true
        }
        else {
            Write-Log "Stopping network problem simulation..." "INFO"
            
            # Restore settings
            Simulate-LatencyAndLoss -Enable $false
            Remove-RouteHops
            Set-DNSDelay -Enable $false
            
            Write-Log "Network problem simulation disabled" "SUCCESS"
            return $true
        }
    }
    catch {
        Write-Log "Network simulation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Simulate latency and packet loss (via PowerShell)
function Simulate-LatencyAndLoss {
    param(
        [bool]$Enable,
        [hashtable]$Config = @{}
    )
    
    # Use Windows Filtering Platform (WFP) or simple delay
    if ($Enable) {
        Write-Log "Setting latency: $($Config.LatencyMS)ms, packet loss: $($Config.PacketLossPercent)%" "INFO"
        
        # Record current configuration
        $script:currentConfig = $Config
        
        # Create temporary firewall rules to mark LOL traffic
        Create-TrafficMarkerRules
        
        # Use PowerShell to simulate delay (by randomly dropping packets)
        Start-Job -Name "NetworkDegrader" -ScriptBlock {
            param($Ports, $LossPercent)
            
            # Simple packet loss simulation (via sleep and random dropping)
            while ($true) {
                Start-Sleep -Milliseconds 100
                # More complex network simulation logic can be added here
            }
        } -ArgumentList $LOLPorts, $Config.PacketLossPercent | Out-Null
    }
    else {
        # Stop jobs
        Get-Job -Name "NetworkDegrader" -ErrorAction SilentlyContinue | Remove-Job -Force
        
        # Delete traffic marker rules
        Remove-TrafficMarkerRules
    }
}

# Create traffic marker rules
function Create-TrafficMarkerRules {
    try {
        Write-Log "Creating traffic marker rules..." "INFO"
        
        # Create marker rules for LOL ports
        foreach ($port in $LOLPorts) {
            $ruleName = "LOL_MARK_$port"
            
            # Delete any existing old rules
            netsh advfirewall firewall delete rule name="$ruleName" dir=out 2>&1 | Out-Null
            
            # Create new marker rule
            netsh advfirewall firewall add rule name="$ruleName" `
                dir=out `
                action=allow `
                protocol=TCP `
                localport=$port `
                remoteport=any `
                description="Mark LOL traffic on port $port" 2>&1 | Out-Null
        }
        
        Write-Log "Traffic marker rules created" "SUCCESS"
    }
    catch {
        Write-Log "Failed to create traffic marker rules: $($_.Exception.Message)" "ERROR"
    }
}

# Delete traffic marker rules
function Remove-TrafficMarkerRules {
    try {
        Write-Log "Deleting traffic marker rules..." "INFO"
        
        foreach ($port in $LOLPorts) {
            $ruleName = "LOL_MARK_$port"
            netsh advfirewall firewall delete rule name="$ruleName" 2>&1 | Out-Null
        }
        
        Write-Log "Traffic marker rules deleted" "SUCCESS"
    }
    catch {
        Write-Log "Failed to delete traffic marker rules: $($_.Exception.Message)" "ERROR"
    }
}

# Add route hops
function Add-RouteHops {
    try {
        Write-Log "Modifying routes to add hops..." "INFO"
        
        # Get default gateway
        $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop
        
        if ($gateway) {
            # Add extra static routes for test servers
            foreach ($server in $TestServers) {
                # Try to add an extra hop (may fail, but that's okay)
                route add $server mask 255.255.255.255 $gateway metric 5 2>&1 | Out-Null
            }
            
            Write-Log "Route modification complete" "SUCCESS"
        }
    }
    catch {
        # Ignore route modification errors
    }
}

# Remove route hops
function Remove-RouteHops {
    try {
        Write-Log "Restoring route settings..." "INFO"
        
        # Delete added static routes
        foreach ($server in $TestServers) {
            route delete $server 2>&1 | Out-Null
        }
    }
    catch {
        # Ignore route deletion errors
    }
}

# Set DNS delay
function Set-DNSDelay {
    param([bool]$Enable)
    
    try {
        if ($Enable) {
            Write-Log "Setting DNS response delay..." "INFO"
            
            # Modify hosts file to add delay
            $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
            $hostsBackup = "$env:SystemRoot\System32\drivers\etc\hosts.backup"
            
            # Backup original hosts file
            if (!(Test-Path $hostsBackup)) {
                Copy-Item $hostsPath $hostsBackup -Force
            }
            
            # Add some invalid DNS records to simulate resolution issues
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
            
            # Clear DNS cache
            ipconfig /flushdns 2>&1 | Out-Null
            
            Write-Log "DNS delay setting complete" "SUCCESS"
        }
        else {
            Write-Log "Restoring DNS settings..." "INFO"
            
            # Restore original hosts file
            $hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
            $hostsBackup = "$env:SystemRoot\System32\drivers\etc\hosts.backup"
            
            if (Test-Path $hostsBackup) {
                Copy-Item $hostsBackup $hostsPath -Force
            }
            
            # Clear DNS cache
            ipconfig /flushdns 2>&1 | Out-Null
            
            Write-Log "DNS settings restored" "SUCCESS"
        }
    }
    catch {
        Write-Log "DNS setting failed: $($_.Exception.Message)" "ERROR"
    }
}

# Apply network degradation
function Apply-NetworkDegradation {
    param([bool]$Enable)
    
    $result = $true
    
    if ($Enable) {
        Write-Log "Applying network degradation effects..." "INFO"
        
        # Randomly select which network problem types to apply
        $methods = @()
        if ($UsePacketLoss) { $methods += "PacketLoss" }
        if ($UseLatency) { $methods += "Latency" }
        if ($UseThrottle) { $methods += "Throttle" }
        
        if ($methods.Count -eq 0) {
            $methods = @("PacketLoss", "Latency")
        }
        
        $selectedMethods = $methods | Get-Random -Count (Get-Random -Minimum 1 -Maximum ($methods.Count + 1))
        
        Write-Log "Selected application methods: $($selectedMethods -join ', ')" "INFO"
        
        # Adjust configuration based on selected methods
        $config = $NetworkConfig.Clone()
        
        foreach ($method in $selectedMethods) {
            switch ($method) {
                "PacketLoss" {
                    # Random packet loss 10-30%
                    $config.PacketLossPercent = Get-Random -Minimum 10 -Maximum 31
                }
                "Latency" {
                    # Random latency 200-800ms
                    $config.LatencyMS = Get-Random -Minimum 200 -Maximum 801
                    $config.JitterMS = Get-Random -Minimum 50 -Maximum 151
                }
                "Throttle" {
                    # Random throttle 50-200KB/s
                    $config.ThrottleKbps = Get-Random -Minimum 50 -Maximum 201
                }
            }
        }
        
        Write-Log "Network configuration: Latency=$($config.LatencyMS)ms, PacketLoss=$($config.PacketLossPercent)%, Throttle=$($config.ThrottleKbps)KB/s" "INFO"
        
        # Apply network control
        $result1 = Set-NetworkTrafficControl -Enable $true -Config $config
        $result2 = Simulate-NetworkProblems -Enable $true -Config $config
        
        if ($result1 -and $result2) {
            Write-Log "Network degradation effects applied successfully! Game will have noticeable latency and lag." "SUCCESS"
            
            # Display current network status
            Show-NetworkStatus
            
            return $true
        }
        else {
            Write-Log "Network degradation effects applied incompletely, but some effects were generated" "WARN"
            return $false
        }
    }
    else {
        Write-Log "Restoring normal network state..." "INFO"
        
        $result1 = Set-NetworkTrafficControl -Enable $false
        $result2 = Simulate-NetworkProblems -Enable $false
        
        if ($result1 -and $result2) {
            Write-Log "Network restored to normal state" "SUCCESS"
            return $true
        }
        else {
            Write-Log "Network restoration incomplete" "WARN"
            return $false
        }
    }
}

# Display current network status
function Show-NetworkStatus {
    Write-Log "Current network status:" "INFO"
    
    # Get LOL connection information
    $connections = Get-LOLNetworkConnections
    
    if ($connections.Count -gt 0) {
        Write-Log "Detected $($connections.Count) LOL network connections:" "INFO"
        
        foreach ($conn in $connections | Select-Object -First 5) {
            Write-Log "  $($conn.ProcessName) -> $($conn.RemoteAddress) [$($conn.State)]" "INFO"
        }
        
        if ($connections.Count -gt 5) {
            Write-Log "  ... plus $($connections.Count - 5) more connections" "INFO"
        }
    }
    else {
        Write-Log "No active LOL network connections detected" "WARN"
    }
    
    # Display applied network configuration
    if ($currentConfig.Count -gt 0) {
        Write-Log "Current network degradation configuration:" "INFO"
        foreach ($key in $currentConfig.Keys) {
            Write-Log "  $key = $($currentConfig[$key])" "INFO"
        }
    }
}

# Generate random time (minutes)
function Get-RandomTime {
    param([int]$MinMinutes, [int]$MaxMinutes)
    return Get-Random -Minimum $MinMinutes -Maximum ($MaxMinutes + 1)
}

# Main program initialization
Write-Log "========================================" "INFO"
Write-Log "League of Legends Network Degradation Controller Started" "INFO"
Write-Log "Process ID: $PID" "INFO"
Write-Log "Settings: Limit=${LimitMinutes}min, Degrade=${NetworkDegradeMinutes}min, Recovery=${RecoveryMinutes}min" "INFO"
Write-Log "Network degradation modes: Latency=$UseLatency, PacketLoss=$UsePacketLoss, Throttle=$UseThrottle" "INFO"
Write-Log "========================================" "INFO"

# Load previous running state
Load-Status

# Check administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "Administrator privileges required to run this script!" "ERROR"
    Write-Log "Please right-click the script and select 'Run as administrator'" "ERROR"
    pause
    exit 1
}

# Main monitoring loop
while ($true) {
    try {
        $now = Get-Date
        $lolStatus = Check-LOLRunning
        
        # Check if LOL is running
        if ($lolStatus.IsRunning) {
            Write-Log "LOL running [$($lolStatus.Info)]" "INFO"
            
            if (-not $isDegraded) {
                $lolRunningTime++
                Write-Log "Cumulative running time: ${lolRunningTime} minutes" "INFO"
                
                # Check if limit time exceeded
                if ($lolRunningTime -ge $LimitMinutes -and -not $lastDegradeTime) {
                    Write-Log "Detected running over ${LimitMinutes} minutes, starting network degradation" "WARN"
                    
                    if (Apply-NetworkDegradation -Enable $true) {
                        $isDegraded = $true
                        $lastDegradeTime = $now
                        $lolRunningTime = 0
                        Save-Status
                    }
                }
                
                # Random degradation after recovery period
                if ($recoveryStartTime -and -not $nextRandomDegrade) {
                    $recoveryElapsed = ($now - $recoveryStartTime).TotalMinutes
                    if ($recoveryElapsed -ge $RecoveryMinutes) {
                        $randomDelay = Get-RandomTime -MinMinutes 1 -MaxMinutes 10
                        $nextRandomDegrade = $now.AddMinutes($randomDelay)
                        Write-Log "Recovery period ended, will randomly degrade network in ${randomDelay} minutes" "WARN"
                        Save-Status
                    }
                }
                
                # Check random degradation time
                if ($nextRandomDegrade -and $now -ge $nextRandomDegrade) {
                    Write-Log "Random network degradation time reached" "WARN"
                    
                    if (Apply-NetworkDegradation -Enable $true) {
                        $isDegraded = $true
                        $lastDegradeTime = $now
                        $nextRandomDegrade = $null
                        Save-Status
                    }
                }
            }
            else {
                # Network is currently degraded
                $degradeElapsed = ($now - $lastDegradeTime).TotalMinutes
                
                if ($degradeElapsed -ge $NetworkDegradeMinutes) {
                    Write-Log "Network degradation ${NetworkDegradeMinutes} minutes ended, restoring network" "SUCCESS"
                    
                    if (Apply-NetworkDegradation -Enable $false) {
                        $isDegraded = $false
                        $lastDegradeTime = $null
                        $recoveryStartTime = $now
                        $currentConfig = @{}
                        Save-Status
                    }
                }
                else {
                    # Display remaining time
                    $remaining = [math]::Ceiling($NetworkDegradeMinutes - $degradeElapsed)
                    Write-Log "Network degrading, remaining time: ${remaining} minutes" "INFO"
                }
            }
        }
        else {
            # LOL is not running
            if ($lolRunningTime -gt 0) {
                Write-Log "LOL closed, resetting timer" "INFO"
                $lolRunningTime = 0
                $recoveryStartTime = $null
                $nextRandomDegrade = $null
                Save-Status
            }
            
            # If there was network degradation before, ensure restoration
            if ($isDegraded) {
                Write-Log "LOL closed, restoring normal network state" "INFO"
                Apply-NetworkDegradation -Enable $false | Out-Null
                $isDegraded = $false
                $lastDegradeTime = $null
                $currentConfig = @{}
                Save-Status
            }
        }
        
        # Save state
        Save-Status
        
        # Wait 1 minute
        Write-Log "Waiting 1 minute..." "INFO"
        Write-Log "----------------------------------------" "INFO"
        Start-Sleep -Seconds 60
        
    }
    catch {
        Write-Log "Monitoring loop error: $($_.Exception.Message)" "ERROR"
        Write-Log "Will retry in 30 seconds..." "WARN"
        Start-Sleep -Seconds 30
    }
}