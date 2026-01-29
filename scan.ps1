<#
.SYNOPSIS
    Multi-threaded Port Scanner for Private IPv4 Ranges
.DESCRIPTION
    A PowerShell 5 compatible port scanner that can scan private IPv4 ranges
    using runspaces for multi-threading. Produces HTML summary reports.
.NOTES
    Author: Network Scanner Tool
    Requires: PowerShell 5.0+
    Encoding: UTF-8 with BOM for PS5 compatibility
#>

#Requires -Version 5.0

# Set encoding for consistency across systems
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Script configuration
$Script:MaxThreads = 100
$Script:ConnectionTimeout = 1000  # milliseconds
$Script:UdpTimeout = 2000  # UDP needs longer timeout

#region Helper Functions

function Convert-CIDRToIPRange {
    <#
    .SYNOPSIS
        Converts CIDR notation to an array of IP addresses
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$CIDR
    )
    
    try {
        if ($CIDR -match '^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/(\d{1,2})$') {
            $NetworkAddress = $Matches[1]
            $PrefixLength = [int]$Matches[2]
        }
        elseif ($CIDR -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
            # Single IP address
            return @($CIDR)
        }
        else {
            Write-Warning "Invalid CIDR format: $CIDR"
            return @()
        }
        
        # Convert IP to integer
        $IPBytes = [System.Net.IPAddress]::Parse($NetworkAddress).GetAddressBytes()
        [Array]::Reverse($IPBytes)
        $IPInt = [BitConverter]::ToUInt32($IPBytes, 0)
        
        # Calculate network and broadcast addresses
        $HostBits = 32 - $PrefixLength
        $NetworkMask = [uint32]([Math]::Pow(2, 32) - [Math]::Pow(2, $HostBits))
        $NetworkInt = $IPInt -band $NetworkMask
        $BroadcastInt = $NetworkInt -bor (-bnot $NetworkMask -band [uint32]::MaxValue)
        
        # Generate IP list (exclude network and broadcast for /31 and larger)
        $IPList = [System.Collections.ArrayList]::new()
        
        if ($PrefixLength -ge 31) {
            # For /31 and /32, include all addresses
            for ($i = $NetworkInt; $i -le $BroadcastInt; $i++) {
                $Bytes = [BitConverter]::GetBytes([uint32]$i)
                [Array]::Reverse($Bytes)
                $null = $IPList.Add(([System.Net.IPAddress]::new($Bytes)).ToString())
            }
        }
        else {
            # Exclude network and broadcast addresses
            for ($i = $NetworkInt + 1; $i -lt $BroadcastInt; $i++) {
                $Bytes = [BitConverter]::GetBytes([uint32]$i)
                [Array]::Reverse($Bytes)
                $null = $IPList.Add(([System.Net.IPAddress]::new($Bytes)).ToString())
            }
        }
        
        return $IPList.ToArray()
    }
    catch {
        Write-Warning "Error converting CIDR $CIDR : $_"
        return @()
    }
}

function Parse-PortInput {
    <#
    .SYNOPSIS
        Parses port input string into array of port numbers
    .EXAMPLE
        Parse-PortInput "80,443,8080-8090"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$PortString
    )
    
    $Ports = [System.Collections.ArrayList]::new()
    $Parts = $PortString -split ','
    
    foreach ($Part in $Parts) {
        $Part = $Part.Trim()
        
        if ($Part -match '^(\d+)-(\d+)$') {
            # Port range
            $Start = [int]$Matches[1]
            $End = [int]$Matches[2]
            
            if ($Start -gt $End) {
                $Start, $End = $End, $Start
            }
            
            for ($i = $Start; $i -le $End; $i++) {
                if ($i -ge 1 -and $i -le 65535) {
                    $null = $Ports.Add($i)
                }
            }
        }
        elseif ($Part -match '^\d+$') {
            # Single port
            $Port = [int]$Part
            if ($Port -ge 1 -and $Port -le 65535) {
                $null = $Ports.Add($Port)
            }
        }
    }
    
    return ($Ports | Sort-Object -Unique)
}

function Get-PrivateIPRanges {
    <#
    .SYNOPSIS
        Returns the private IPv4 address ranges
    #>
    return @(
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16"
    )
}

function Get-CommonPrivateSubnets {
    <#
    .SYNOPSIS
        Returns commonly used private subnets for faster scanning
    #>
    return @(
        "10.0.0.0/24",
        "10.0.1.0/24",
        "10.1.0.0/24",
        "10.1.1.0/24",
        "172.16.0.0/24",
        "172.16.1.0/24",
        "192.168.0.0/24",
        "192.168.1.0/24",
        "192.168.2.0/24",
        "192.168.10.0/24",
        "192.168.100.0/24"
    )
}

#endregion

#region Port Scanning Functions

function Test-TCPPort {
    <#
    .SYNOPSIS
        Tests a TCP port on a target host
    #>
    param(
        [string]$IP,
        [int]$Port,
        [int]$Timeout = 1000
    )
    
    $Result = [PSCustomObject]@{
        IP       = $IP
        Port     = $Port
        Protocol = 'TCP'
        Status   = 'Closed'
        Service  = Get-CommonPortService -Port $Port -Protocol 'TCP'
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    try {
        $TcpClient = New-Object System.Net.Sockets.TcpClient
        $AsyncResult = $TcpClient.BeginConnect($IP, $Port, $null, $null)
        $Wait = $AsyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
        
        if ($Wait -and $TcpClient.Connected) {
            $Result.Status = 'Open'
            $TcpClient.EndConnect($AsyncResult)
        }
        else {
            $Result.Status = 'Closed'
        }
    }
    catch [System.Net.Sockets.SocketException] {
        switch ($_.Exception.SocketErrorCode) {
            'ConnectionRefused' { $Result.Status = 'Closed' }
            'HostUnreachable' { $Result.Status = 'Filtered' }
            'TimedOut' { $Result.Status = 'Filtered' }
            default { $Result.Status = 'Filtered' }
        }
    }
    catch {
        $Result.Status = 'Error'
    }
    finally {
        if ($TcpClient) {
            $TcpClient.Close()
            $TcpClient.Dispose()
        }
    }
    
    return $Result
}

function Test-UDPPort {
    <#
    .SYNOPSIS
        Tests a UDP port on a target host
    .NOTES
        UDP scanning is inherently unreliable due to the connectionless nature of UDP
    #>
    param(
        [string]$IP,
        [int]$Port,
        [int]$Timeout = 2000
    )
    
    $Result = [PSCustomObject]@{
        IP       = $IP
        Port     = $Port
        Protocol = 'UDP'
        Status   = 'Open|Filtered'
        Service  = Get-CommonPortService -Port $Port -Protocol 'UDP'
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    try {
        $UdpClient = New-Object System.Net.Sockets.UdpClient
        $UdpClient.Client.ReceiveTimeout = $Timeout
        $UdpClient.Client.SendTimeout = $Timeout
        
        # Send empty UDP packet
        $Bytes = [byte[]]@(0x00)
        $null = $UdpClient.Send($Bytes, $Bytes.Length, $IP, $Port)
        
        # Try to receive response
        $RemoteEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        
        try {
            $null = $UdpClient.Receive([ref]$RemoteEndPoint)
            $Result.Status = 'Open'
        }
        catch [System.Net.Sockets.SocketException] {
            switch ($_.Exception.SocketErrorCode) {
                'ConnectionReset' { 
                    # ICMP Port Unreachable received - port is closed
                    $Result.Status = 'Closed' 
                }
                'TimedOut' { 
                    # No response - could be open or filtered
                    $Result.Status = 'Open|Filtered' 
                }
                default { 
                    $Result.Status = 'Open|Filtered' 
                }
            }
        }
    }
    catch {
        $Result.Status = 'Error'
    }
    finally {
        if ($UdpClient) {
            $UdpClient.Close()
            $UdpClient.Dispose()
        }
    }
    
    return $Result
}

function Get-CommonPortService {
    <#
    .SYNOPSIS
        Returns common service name for well-known ports
    #>
    param(
        [int]$Port,
        [string]$Protocol = 'TCP'
    )
    
    $Services = @{
        20   = 'FTP-Data'
        21   = 'FTP'
        22   = 'SSH'
        23   = 'Telnet'
        25   = 'SMTP'
        53   = 'DNS'
        67   = 'DHCP-Server'
        68   = 'DHCP-Client'
        69   = 'TFTP'
        80   = 'HTTP'
        110  = 'POP3'
        111  = 'RPC'
        119  = 'NNTP'
        123  = 'NTP'
        135  = 'MS-RPC'
        137  = 'NetBIOS-NS'
        138  = 'NetBIOS-DGM'
        139  = 'NetBIOS-SSN'
        143  = 'IMAP'
        161  = 'SNMP'
        162  = 'SNMP-Trap'
        389  = 'LDAP'
        443  = 'HTTPS'
        445  = 'SMB'
        465  = 'SMTPS'
        500  = 'IKE'
        514  = 'Syslog'
        515  = 'LPD'
        520  = 'RIP'
        587  = 'SMTP-Submission'
        636  = 'LDAPS'
        993  = 'IMAPS'
        995  = 'POP3S'
        1080 = 'SOCKS'
        1433 = 'MSSQL'
        1434 = 'MSSQL-UDP'
        1521 = 'Oracle'
        1723 = 'PPTP'
        2049 = 'NFS'
        3306 = 'MySQL'
        3389 = 'RDP'
        3690 = 'SVN'
        4443 = 'HTTPS-Alt'
        5060 = 'SIP'
        5061 = 'SIPS'
        5432 = 'PostgreSQL'
        5900 = 'VNC'
        5985 = 'WinRM-HTTP'
        5986 = 'WinRM-HTTPS'
        6379 = 'Redis'
        8000 = 'HTTP-Alt'
        8080 = 'HTTP-Proxy'
        8443 = 'HTTPS-Alt'
        9000 = 'HTTP-Alt'
        9090 = 'Web-Console'
        9200 = 'Elasticsearch'
        11211 = 'Memcached'
        27017 = 'MongoDB'
    }
    
    if ($Services.ContainsKey($Port)) {
        return $Services[$Port]
    }
    return 'Unknown'
}

#endregion

#region Multi-threading with Runspaces

function Start-PortScan {
    <#
    .SYNOPSIS
        Main function to perform multi-threaded port scanning
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Targets,
        
        [Parameter(Mandatory = $true)]
        [int[]]$Ports,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'UDP', 'Both')]
        [string]$Protocol,
        
        [int]$MaxThreads = 100,
        
        [int]$Timeout = 1000
    )
    
    # Build list of scan tasks
    $ScanTasks = [System.Collections.ArrayList]::new()
    
    $Protocols = switch ($Protocol) {
        'TCP' { @('TCP') }
        'UDP' { @('UDP') }
        'Both' { @('TCP', 'UDP') }
    }
    
    foreach ($Target in $Targets) {
        foreach ($Port in $Ports) {
            foreach ($Proto in $Protocols) {
                $null = $ScanTasks.Add([PSCustomObject]@{
                    IP       = $Target
                    Port     = $Port
                    Protocol = $Proto
                })
            }
        }
    }
    
    $TotalTasks = $ScanTasks.Count
    Write-Host "`n[*] Total scan tasks: $TotalTasks" -ForegroundColor Cyan
    Write-Host "[*] Using $MaxThreads threads" -ForegroundColor Cyan
    Write-Host "[*] Starting scan...`n" -ForegroundColor Green
    
    # Create runspace pool
    $SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $RunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $MaxThreads, $SessionState, $Host)
    $RunspacePool.Open()
    
    # Script blocks for scanning
    $TCPScriptBlock = {
        param($IP, $Port, $Timeout)
        
        $Result = [PSCustomObject]@{
            IP        = $IP
            Port      = $Port
            Protocol  = 'TCP'
            Status    = 'Closed'
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        try {
            $TcpClient = New-Object System.Net.Sockets.TcpClient
            $AsyncResult = $TcpClient.BeginConnect($IP, $Port, $null, $null)
            $Wait = $AsyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
            
            if ($Wait -and $TcpClient.Connected) {
                $Result.Status = 'Open'
                $TcpClient.EndConnect($AsyncResult)
            }
        }
        catch [System.Net.Sockets.SocketException] {
            switch ($_.Exception.SocketErrorCode) {
                'ConnectionRefused' { $Result.Status = 'Closed' }
                'HostUnreachable' { $Result.Status = 'Filtered' }
                'TimedOut' { $Result.Status = 'Filtered' }
                default { $Result.Status = 'Filtered' }
            }
        }
        catch {
            $Result.Status = 'Error'
        }
        finally {
            if ($TcpClient) {
                $TcpClient.Close()
                $TcpClient.Dispose()
            }
        }
        
        return $Result
    }
    
    $UDPScriptBlock = {
        param($IP, $Port, $Timeout)
        
        $Result = [PSCustomObject]@{
            IP        = $IP
            Port      = $Port
            Protocol  = 'UDP'
            Status    = 'Open|Filtered'
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        try {
            $UdpClient = New-Object System.Net.Sockets.UdpClient
            $UdpClient.Client.ReceiveTimeout = $Timeout
            $UdpClient.Client.SendTimeout = $Timeout
            
            $Bytes = [byte[]]@(0x00)
            $null = $UdpClient.Send($Bytes, $Bytes.Length, $IP, $Port)
            
            $RemoteEndPoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
            
            try {
                $null = $UdpClient.Receive([ref]$RemoteEndPoint)
                $Result.Status = 'Open'
            }
            catch [System.Net.Sockets.SocketException] {
                switch ($_.Exception.SocketErrorCode) {
                    'ConnectionReset' { $Result.Status = 'Closed' }
                    'TimedOut' { $Result.Status = 'Open|Filtered' }
                    default { $Result.Status = 'Open|Filtered' }
                }
            }
        }
        catch {
            $Result.Status = 'Error'
        }
        finally {
            if ($UdpClient) {
                $UdpClient.Close()
                $UdpClient.Dispose()
            }
        }
        
        return $Result
    }
    
    # Start all jobs
    $Jobs = [System.Collections.ArrayList]::new()
    $CompletedCount = 0
    
    foreach ($Task in $ScanTasks) {
        $PowerShell = [PowerShell]::Create()
        $PowerShell.RunspacePool = $RunspacePool
        
        if ($Task.Protocol -eq 'TCP') {
            $null = $PowerShell.AddScript($TCPScriptBlock)
            $null = $PowerShell.AddArgument($Task.IP)
            $null = $PowerShell.AddArgument($Task.Port)
            $null = $PowerShell.AddArgument($Timeout)
        }
        else {
            $null = $PowerShell.AddScript($UDPScriptBlock)
            $null = $PowerShell.AddArgument($Task.IP)
            $null = $PowerShell.AddArgument($Task.Port)
            $null = $PowerShell.AddArgument($Script:UdpTimeout)
        }
        
        $Job = [PSCustomObject]@{
            PowerShell = $PowerShell
            Handle     = $PowerShell.BeginInvoke()
            Task       = $Task
        }
        
        $null = $Jobs.Add($Job)
    }
    
    # Collect results with visual progress bar
    $Results = [System.Collections.ArrayList]::new()
    $StartTime = Get-Date
    $LastProgressUpdate = Get-Date
    $OpenPortCount = 0
    $ProgressBarWidth = 50
    
    # Reserve space for progress display
    Write-Host ""
    Write-Host ""
    Write-Host ""
    $ProgressTop = [Console]::CursorTop - 3
    
    while ($Jobs.Count -gt 0) {
        $CompletedJobs = $Jobs | Where-Object { $_.Handle.IsCompleted }
        
        foreach ($Job in $CompletedJobs) {
            try {
                $Result = $Job.PowerShell.EndInvoke($Job.Handle)
                if ($Result) {
                    # Add service name
                    $Result | ForEach-Object {
                        $_ | Add-Member -NotePropertyName 'Service' -NotePropertyValue (Get-CommonPortService -Port $_.Port -Protocol $_.Protocol) -Force
                        $null = $Results.Add($_)
                        
                        # Track open ports for live display
                        if ($_.Status -eq 'Open' -or $_.Status -eq 'Open|Filtered') {
                            $OpenPortCount++
                        }
                    }
                }
            }
            catch {
                # Silently continue
            }
            finally {
                $Job.PowerShell.Dispose()
            }
            
            $CompletedCount++
            $Jobs.Remove($Job)
        }
        
        # Update progress bar every 100ms for performance
        $Now = Get-Date
        if (($Now - $LastProgressUpdate).TotalMilliseconds -ge 100) {
            $LastProgressUpdate = $Now
            
            if ($TotalTasks -gt 0) {
                $PercentComplete = [math]::Round(($CompletedCount / $TotalTasks) * 100, 1)
                $ElapsedTime = $Now - $StartTime
                
                # Calculate ETA
                $EstimatedTotal = if ($CompletedCount -gt 0) { 
                    [TimeSpan]::FromTicks($ElapsedTime.Ticks * $TotalTasks / $CompletedCount) 
                } else { 
                    [TimeSpan]::Zero 
                }
                $Remaining = $EstimatedTotal - $ElapsedTime
                if ($Remaining.TotalSeconds -lt 0) { $Remaining = [TimeSpan]::Zero }
                
                # Calculate speed
                $Speed = if ($ElapsedTime.TotalSeconds -gt 0) {
                    [math]::Round($CompletedCount / $ElapsedTime.TotalSeconds, 1)
                } else { 0 }
                
                # Build visual progress bar (ASCII for compatibility)
                $FilledWidth = [math]::Floor(($CompletedCount / $TotalTasks) * $ProgressBarWidth)
                $EmptyWidth = $ProgressBarWidth - $FilledWidth
                $ProgressBar = "[" + ("#" * $FilledWidth) + ("-" * $EmptyWidth) + "]"
                
                # Format time strings
                $ElapsedStr = "{0:hh\:mm\:ss}" -f $ElapsedTime
                $RemainingStr = "{0:hh\:mm\:ss}" -f $Remaining
                
                # Build progress lines
                $Line1 = "  $ProgressBar $PercentComplete%"
                $Line2 = "  Completed: $CompletedCount/$TotalTasks | Open Ports: $OpenPortCount | Speed: $Speed/s"
                $Line3 = "  Elapsed: $ElapsedStr | ETA: $RemainingStr"
                
                # Update console display
                try {
                    [Console]::SetCursorPosition(0, $ProgressTop)
                    Write-Host "$Line1$(' ' * 20)" -ForegroundColor Cyan
                    Write-Host "$Line2$(' ' * 20)" -ForegroundColor White
                    Write-Host "$Line3$(' ' * 20)" -ForegroundColor DarkGray
                }
                catch {
                    # Fallback to Write-Progress if console manipulation fails
                }
                
                # Also use Write-Progress for ISE/terminal compatibility
                Write-Progress -Activity "Port Scanning" `
                    -Status "$CompletedCount/$TotalTasks ($PercentComplete%) - Open: $OpenPortCount - Speed: $Speed/s" `
                    -PercentComplete ([math]::Min($PercentComplete, 100)) `
                    -SecondsRemaining ([math]::Max(0, $Remaining.TotalSeconds))
            }
        }
        
        Start-Sleep -Milliseconds 50
    }
    
    # Clear progress display
    Write-Progress -Activity "Port Scanning" -Completed
    try {
        [Console]::SetCursorPosition(0, $ProgressTop)
        Write-Host "$(' ' * 80)"
        Write-Host "$(' ' * 80)"
        Write-Host "$(' ' * 80)"
        [Console]::SetCursorPosition(0, $ProgressTop)
    }
    catch { }
    
    # Cleanup
    $RunspacePool.Close()
    $RunspacePool.Dispose()
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Host "`n[+] Scan completed in $($Duration.ToString('hh\:mm\:ss'))" -ForegroundColor Green
    Write-Host "[+] Open ports found: $OpenPortCount" -ForegroundColor Green
    
    return $Results
}

#endregion

#region HTML Report Generation

function New-HTMLReport {
    <#
    .SYNOPSIS
        Generates an HTML report from scan results
    #>
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$Results,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [string]$ScanTargets,
        [string]$ScanPorts,
        [string]$ScanProtocol
    )
    
    $OpenPorts = $Results | Where-Object { $_.Status -eq 'Open' -or $_.Status -eq 'Open|Filtered' }
    $ClosedPorts = $Results | Where-Object { $_.Status -eq 'Closed' }
    $FilteredPorts = $Results | Where-Object { $_.Status -eq 'Filtered' }
    
    $UniqueHosts = ($Results | Select-Object -ExpandProperty IP -Unique).Count
    $TotalScanned = $Results.Count
    
    # Group open ports by host
    $HostSummary = $OpenPorts | Group-Object -Property IP | Sort-Object -Property Name
    
    $HTMLContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Port Scan Report - $(Get-Date -Format "yyyy-MM-dd HH:mm")</title>
    <style>
        :root {
            --bg-primary: #1a1a2e;
            --bg-secondary: #16213e;
            --bg-card: #0f3460;
            --text-primary: #eaeaea;
            --text-secondary: #a0a0a0;
            --accent-green: #00d26a;
            --accent-red: #ff4757;
            --accent-yellow: #ffa502;
            --accent-blue: #3498db;
            --border-color: #2c3e50;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            text-align: center;
            padding: 30px 0;
            border-bottom: 2px solid var(--border-color);
            margin-bottom: 30px;
        }
        
        header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            background: linear-gradient(135deg, var(--accent-blue), var(--accent-green));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        header .timestamp {
            color: var(--text-secondary);
            font-size: 1.1em;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: var(--bg-secondary);
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            border: 1px solid var(--border-color);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card h3 {
            font-size: 2.5em;
            margin-bottom: 5px;
        }
        
        .stat-card p {
            color: var(--text-secondary);
            font-size: 1em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .stat-card.open h3 { color: var(--accent-green); }
        .stat-card.closed h3 { color: var(--accent-red); }
        .stat-card.filtered h3 { color: var(--accent-yellow); }
        .stat-card.total h3 { color: var(--accent-blue); }
        
        .scan-info {
            background: var(--bg-secondary);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
        }
        
        .scan-info h2 {
            margin-bottom: 15px;
            color: var(--accent-blue);
        }
        
        .scan-info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }
        
        .scan-info-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .scan-info-item strong {
            color: var(--text-secondary);
            min-width: 100px;
        }
        
        .section {
            background: var(--bg-secondary);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
        }
        
        .section h2 {
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section h2::before {
            content: '';
            width: 4px;
            height: 24px;
            background: var(--accent-green);
            border-radius: 2px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        th {
            background: var(--bg-card);
            color: var(--accent-blue);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85em;
            letter-spacing: 1px;
        }
        
        tr:hover {
            background: rgba(52, 152, 219, 0.1);
        }
        
        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            display: inline-block;
        }
        
        .status-open {
            background: rgba(0, 210, 106, 0.2);
            color: var(--accent-green);
        }
        
        .status-closed {
            background: rgba(255, 71, 87, 0.2);
            color: var(--accent-red);
        }
        
        .status-filtered {
            background: rgba(255, 165, 2, 0.2);
            color: var(--accent-yellow);
        }
        
        .host-section {
            margin-bottom: 25px;
            background: var(--bg-card);
            border-radius: 8px;
            overflow: hidden;
        }
        
        .host-header {
            background: linear-gradient(135deg, var(--bg-card), var(--bg-secondary));
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
        }
        
        .host-header:hover {
            background: var(--bg-secondary);
        }
        
        .host-ip {
            font-size: 1.2em;
            font-weight: 600;
            color: var(--accent-blue);
        }
        
        .host-count {
            background: var(--accent-green);
            color: var(--bg-primary);
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 600;
        }
        
        .host-ports {
            padding: 0 20px 20px;
        }
        
        .port-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }
        
        .port-item {
            background: var(--bg-secondary);
            padding: 8px 15px;
            border-radius: 6px;
            display: flex;
            flex-direction: column;
            align-items: center;
            min-width: 100px;
            border: 1px solid var(--border-color);
        }
        
        .port-number {
            font-size: 1.2em;
            font-weight: 600;
            color: var(--accent-green);
        }
        
        .port-service {
            font-size: 0.8em;
            color: var(--text-secondary);
        }
        
        .port-protocol {
            font-size: 0.7em;
            color: var(--accent-blue);
            text-transform: uppercase;
        }
        
        footer {
            text-align: center;
            padding: 20px;
            color: var(--text-secondary);
            border-top: 1px solid var(--border-color);
            margin-top: 30px;
        }
        
        .no-results {
            text-align: center;
            padding: 40px;
            color: var(--text-secondary);
            font-size: 1.2em;
        }
        
        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            header h1 {
                font-size: 1.8em;
            }
            
            .host-header {
                flex-direction: column;
                gap: 10px;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>Port Scan Report</h1>
            <p class="timestamp">Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
        </header>
        
        <div class="stats-grid">
            <div class="stat-card open">
                <h3>$($OpenPorts.Count)</h3>
                <p>Open Ports</p>
            </div>
            <div class="stat-card closed">
                <h3>$($ClosedPorts.Count)</h3>
                <p>Closed Ports</p>
            </div>
            <div class="stat-card filtered">
                <h3>$($FilteredPorts.Count)</h3>
                <p>Filtered Ports</p>
            </div>
            <div class="stat-card total">
                <h3>$UniqueHosts</h3>
                <p>Hosts Scanned</p>
            </div>
        </div>
        
        <div class="scan-info">
            <h2>Scan Configuration</h2>
            <div class="scan-info-grid">
                <div class="scan-info-item">
                    <strong>Targets:</strong>
                    <span>$ScanTargets</span>
                </div>
                <div class="scan-info-item">
                    <strong>Ports:</strong>
                    <span>$ScanPorts</span>
                </div>
                <div class="scan-info-item">
                    <strong>Protocol:</strong>
                    <span>$ScanProtocol</span>
                </div>
                <div class="scan-info-item">
                    <strong>Total Tasks:</strong>
                    <span>$TotalScanned</span>
                </div>
            </div>
        </div>
        
        <div class="section">
            <h2>Open Ports by Host</h2>
"@
    
    if ($HostSummary.Count -gt 0) {
        foreach ($HostEntry in $HostSummary) {
            $HostIP = $HostEntry.Name
            $HostPorts = $HostEntry.Group | Sort-Object Port
            
            $HTMLContent += @"
            <div class="host-section">
                <div class="host-header">
                    <span class="host-ip">$HostIP</span>
                    <span class="host-count">$($HostPorts.Count) open port(s)</span>
                </div>
                <div class="host-ports">
                    <div class="port-list">
"@
            foreach ($PortInfo in $HostPorts) {
                $HTMLContent += @"
                        <div class="port-item">
                            <span class="port-number">$($PortInfo.Port)</span>
                            <span class="port-service">$($PortInfo.Service)</span>
                            <span class="port-protocol">$($PortInfo.Protocol)</span>
                        </div>
"@
            }
            
            $HTMLContent += @"
                    </div>
                </div>
            </div>
"@
        }
    }
    else {
        $HTMLContent += @"
            <div class="no-results">
                <p>No open ports found during the scan.</p>
            </div>
"@
    }
    
    $HTMLContent += @"
        </div>
        
        <div class="section">
            <h2>Detailed Results</h2>
            <table>
                <thead>
                    <tr>
                        <th>IP Address</th>
                        <th>Port</th>
                        <th>Protocol</th>
                        <th>Status</th>
                        <th>Service</th>
                        <th>Timestamp</th>
                    </tr>
                </thead>
                <tbody>
"@
    
    # Show open ports first, then others
    $SortedResults = $Results | Sort-Object @{Expression = {
        switch ($_.Status) {
            'Open' { 0 }
            'Open|Filtered' { 1 }
            'Filtered' { 2 }
            'Closed' { 3 }
            default { 4 }
        }
    }}, IP, Port
    
    # Limit detailed results to prevent huge HTML files
    $MaxDetailedResults = 1000
    $DisplayResults = $SortedResults | Select-Object -First $MaxDetailedResults
    
    foreach ($Result in $DisplayResults) {
        $StatusClass = switch ($Result.Status) {
            'Open' { 'status-open' }
            'Open|Filtered' { 'status-open' }
            'Closed' { 'status-closed' }
            'Filtered' { 'status-filtered' }
            default { '' }
        }
        
        $HTMLContent += @"
                    <tr>
                        <td>$($Result.IP)</td>
                        <td>$($Result.Port)</td>
                        <td>$($Result.Protocol)</td>
                        <td><span class="status-badge $StatusClass">$($Result.Status)</span></td>
                        <td>$($Result.Service)</td>
                        <td>$($Result.Timestamp)</td>
                    </tr>
"@
    }
    
    if ($SortedResults.Count -gt $MaxDetailedResults) {
        $HTMLContent += @"
                    <tr>
                        <td colspan="6" style="text-align: center; color: var(--text-secondary);">
                            ... and $($SortedResults.Count - $MaxDetailedResults) more results (showing first $MaxDetailedResults)
                        </td>
                    </tr>
"@
    }
    
    $HTMLContent += @"
                </tbody>
            </table>
        </div>
        
        <footer>
            <p>PowerShell Port Scanner - Generated with PowerShell $($PSVersionTable.PSVersion.ToString())</p>
        </footer>
    </div>
    
    <script>
        // Add click-to-expand functionality for host sections
        document.querySelectorAll('.host-header').forEach(function(header) {
            header.addEventListener('click', function() {
                var ports = this.nextElementSibling;
                if (ports.style.display === 'none') {
                    ports.style.display = 'block';
                } else {
                    ports.style.display = 'block';
                }
            });
        });
    </script>
</body>
</html>
"@
    
    # Write with UTF8 encoding (with BOM for PS5 compatibility)
    $UTF8BOM = New-Object System.Text.UTF8Encoding $true
    [System.IO.File]::WriteAllText($OutputPath, $HTMLContent, $UTF8BOM)
    
    Write-Host "[+] HTML report saved to: $OutputPath" -ForegroundColor Green
}

#endregion

#region Main Interactive Menu

function Show-Banner {
    Clear-Host
    Write-Host @"
    
    ██████╗  ██████╗ ██████╗ ████████╗    ███████╗ ██████╗ █████╗ ███╗   ██╗
    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝    ██╔════╝██╔════╝██╔══██╗████╗  ██║
    ██████╔╝██║   ██║██████╔╝   ██║       ███████╗██║     ███████║██╔██╗ ██║
    ██╔═══╝ ██║   ██║██╔══██╗   ██║       ╚════██║██║     ██╔══██║██║╚██╗██║
    ██║     ╚██████╔╝██║  ██║   ██║       ███████║╚██████╗██║  ██║██║ ╚████║
    ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
                                                                             
    Multi-Threaded Port Scanner for Private IPv4 Ranges
    PowerShell 5.0+ Compatible
    
"@ -ForegroundColor Cyan
}

function Show-MainMenu {
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host " TARGET SELECTION" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [1] Scan specific IP(s) or Subnet(s)" -ForegroundColor White
    Write-Host "  [2] Scan ALL private IPv4 ranges (10.x, 172.16-31.x, 192.168.x)" -ForegroundColor White
    Write-Host "  [3] Scan common private subnets (faster)" -ForegroundColor White
    Write-Host "  [4] Load targets from file" -ForegroundColor White
    Write-Host "  [5] Exit" -ForegroundColor White
    Write-Host ""
}

function Get-UserTargets {
    $Targets = [System.Collections.ArrayList]::new()
    
    Show-MainMenu
    
    $Choice = Read-Host "Select option [1-5]"
    
    switch ($Choice) {
        '1' {
            Write-Host ""
            Write-Host "Enter IP addresses or CIDR subnets (comma-separated)" -ForegroundColor Cyan
            Write-Host "Examples: 192.168.1.1, 192.168.1.0/24, 10.0.0.1-10.0.0.50" -ForegroundColor DarkGray
            Write-Host ""
            $Input = Read-Host "Targets"
            
            $InputParts = $Input -split ','
            foreach ($Part in $InputParts) {
                $Part = $Part.Trim()
                
                if ($Part -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}-\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
                    # IP range (e.g., 10.0.0.1-10.0.0.50)
                    $RangeParts = $Part -split '-'
                    $StartIP = [System.Net.IPAddress]::Parse($RangeParts[0])
                    $EndIP = [System.Net.IPAddress]::Parse($RangeParts[1])
                    
                    $StartBytes = $StartIP.GetAddressBytes()
                    [Array]::Reverse($StartBytes)
                    $StartInt = [BitConverter]::ToUInt32($StartBytes, 0)
                    
                    $EndBytes = $EndIP.GetAddressBytes()
                    [Array]::Reverse($EndBytes)
                    $EndInt = [BitConverter]::ToUInt32($EndBytes, 0)
                    
                    for ($i = $StartInt; $i -le $EndInt; $i++) {
                        $Bytes = [BitConverter]::GetBytes([uint32]$i)
                        [Array]::Reverse($Bytes)
                        $null = $Targets.Add(([System.Net.IPAddress]::new($Bytes)).ToString())
                    }
                }
                elseif ($Part -match '/') {
                    # CIDR notation
                    $IPs = Convert-CIDRToIPRange -CIDR $Part
                    foreach ($IP in $IPs) {
                        $null = $Targets.Add($IP)
                    }
                }
                elseif ($Part -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
                    # Single IP
                    $null = $Targets.Add($Part)
                }
            }
        }
        '2' {
            Write-Host ""
            Write-Host "[!] WARNING: Scanning all private ranges will take a VERY long time!" -ForegroundColor Yellow
            Write-Host "    Total IPs: ~17.9 million addresses" -ForegroundColor Yellow
            Write-Host ""
            $Confirm = Read-Host "Are you sure? (yes/no)"
            
            if ($Confirm -eq 'yes') {
                foreach ($Range in (Get-PrivateIPRanges)) {
                    Write-Host "[*] Expanding $Range..." -ForegroundColor Cyan
                    $IPs = Convert-CIDRToIPRange -CIDR $Range
                    foreach ($IP in $IPs) {
                        $null = $Targets.Add($IP)
                    }
                }
            }
            else {
                Write-Host "Cancelled." -ForegroundColor Yellow
                return $null
            }
        }
        '3' {
            Write-Host ""
            Write-Host "[*] Loading common private subnets..." -ForegroundColor Cyan
            foreach ($Subnet in (Get-CommonPrivateSubnets)) {
                $IPs = Convert-CIDRToIPRange -CIDR $Subnet
                foreach ($IP in $IPs) {
                    $null = $Targets.Add($IP)
                }
            }
        }
        '4' {
            Write-Host ""
            $FilePath = Read-Host "Enter path to targets file (one IP/CIDR per line)"
            
            if (Test-Path $FilePath) {
                $Lines = Get-Content -Path $FilePath -Encoding UTF8
                foreach ($Line in $Lines) {
                    $Line = $Line.Trim()
                    if ([string]::IsNullOrWhiteSpace($Line) -or $Line.StartsWith('#')) {
                        continue
                    }
                    
                    if ($Line -match '/') {
                        $IPs = Convert-CIDRToIPRange -CIDR $Line
                        foreach ($IP in $IPs) {
                            $null = $Targets.Add($IP)
                        }
                    }
                    elseif ($Line -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
                        $null = $Targets.Add($Line)
                    }
                }
            }
            else {
                Write-Host "[!] File not found: $FilePath" -ForegroundColor Red
                return $null
            }
        }
        '5' {
            Write-Host "Exiting..." -ForegroundColor Yellow
            return $null
        }
        default {
            Write-Host "[!] Invalid option" -ForegroundColor Red
            return $null
        }
    }
    
    # Remove duplicates
    $Targets = [System.Collections.ArrayList]@($Targets | Sort-Object -Unique)
    
    return $Targets
}

function Get-UserPorts {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host " PORT SELECTION" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [1] Single port" -ForegroundColor White
    Write-Host "  [2] Multiple ports or port range" -ForegroundColor White
    Write-Host "  [3] Common ports (top 100)" -ForegroundColor White
    Write-Host "  [4] Well-known ports (1-1024)" -ForegroundColor White
    Write-Host "  [5] All ports (1-65535) - WARNING: Very slow!" -ForegroundColor White
    Write-Host ""
    
    $Choice = Read-Host "Select option [1-5]"
    
    switch ($Choice) {
        '1' {
            Write-Host ""
            $PortInput = Read-Host "Enter port number (1-65535)"
            if ($PortInput -match '^\d+$') {
                $Port = [int]$PortInput
                if ($Port -ge 1 -and $Port -le 65535) {
                    Write-Host "[+] Scanning port $Port" -ForegroundColor Green
                    return @($Port)
                }
                else {
                    Write-Host "[!] Invalid port number. Must be between 1-65535." -ForegroundColor Red
                    return $null
                }
            }
            else {
                Write-Host "[!] Invalid input. Please enter a number." -ForegroundColor Red
                return $null
            }
        }
        '2' {
            Write-Host ""
            Write-Host "Enter ports (comma-separated, ranges with dash)" -ForegroundColor Cyan
            Write-Host "Examples: 22,80,443 or 8080-8090 or 22,80,443,8080-8090" -ForegroundColor DarkGray
            Write-Host ""
            $PortInput = Read-Host "Ports"
            $Ports = Parse-PortInput -PortString $PortInput
            if ($Ports.Count -gt 0) {
                Write-Host "[+] Scanning $($Ports.Count) port(s)" -ForegroundColor Green
                return $Ports
            }
            else {
                Write-Host "[!] No valid ports specified." -ForegroundColor Red
                return $null
            }
        }
        '3' {
            # Top 100 common ports
            Write-Host "[+] Using top 100 common ports" -ForegroundColor Green
            return @(21, 22, 23, 25, 53, 80, 110, 111, 135, 139, 143, 443, 445, 993, 995, 
                    1433, 1521, 1723, 3306, 3389, 5432, 5900, 5985, 5986, 6379, 8000, 
                    8080, 8443, 9000, 9090, 9200, 11211, 27017, 20, 69, 123, 137, 138, 
                    161, 162, 389, 465, 500, 514, 515, 520, 587, 636, 873, 902, 1080, 
                    1194, 1434, 1701, 1812, 1813, 2049, 2082, 2083, 2086, 2087, 2095, 
                    2096, 2181, 2222, 2375, 2376, 3000, 3128, 3268, 3269, 3690, 4000, 
                    4443, 4444, 5000, 5001, 5060, 5061, 5222, 5269, 5672, 5901, 5984, 
                    6000, 6001, 6443, 6667, 7001, 7002, 7077, 7474, 8001, 8008, 8009, 
                    8081, 8082, 8083, 8084, 8085, 8086, 8087, 8088)
        }
        '4' {
            Write-Host "[+] Using well-known ports (1-1024)" -ForegroundColor Green
            return (1..1024)
        }
        '5' {
            Write-Host ""
            Write-Host "[!] WARNING: Scanning all 65535 ports will take a VERY long time!" -ForegroundColor Yellow
            $Confirm = Read-Host "Are you sure? (yes/no)"
            if ($Confirm -eq 'yes') {
                Write-Host "[+] Scanning ALL ports (1-65535)" -ForegroundColor Green
                return (1..65535)
            }
            else {
                Write-Host "Cancelled." -ForegroundColor Yellow
                return $null
            }
        }
        default {
            Write-Host "[!] Invalid option, using common ports" -ForegroundColor Yellow
            return @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 
                    1433, 3306, 3389, 5432, 5900, 8080)
        }
    }
}

function Get-UserProtocol {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host " PROTOCOL SELECTION" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [1] TCP only" -ForegroundColor White
    Write-Host "  [2] UDP only" -ForegroundColor White
    Write-Host "  [3] Both TCP and UDP" -ForegroundColor White
    Write-Host ""
    
    $Choice = Read-Host "Select option [1-3]"
    
    switch ($Choice) {
        '1' { return 'TCP' }
        '2' { return 'UDP' }
        '3' { return 'Both' }
        default {
            Write-Host "[!] Invalid option, using TCP" -ForegroundColor Yellow
            return 'TCP'
        }
    }
}

function Get-ScanConfiguration {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host " SCAN CONFIGURATION" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    
    $Config = @{
        MaxThreads = 100
        Timeout    = 1000
        OutputPath = ""
    }
    
    Write-Host "Current defaults: Threads=$($Config.MaxThreads), Timeout=$($Config.Timeout)ms" -ForegroundColor DarkGray
    Write-Host ""
    
    $CustomConfig = Read-Host "Use custom configuration? (y/n)"
    
    if ($CustomConfig -eq 'y') {
        $ThreadInput = Read-Host "Max threads (default: 100)"
        if ($ThreadInput -match '^\d+$') {
            $Config.MaxThreads = [int]$ThreadInput
            if ($Config.MaxThreads -lt 1) { $Config.MaxThreads = 1 }
            if ($Config.MaxThreads -gt 500) { $Config.MaxThreads = 500 }
        }
        
        $TimeoutInput = Read-Host "Connection timeout in ms (default: 1000)"
        if ($TimeoutInput -match '^\d+$') {
            $Config.Timeout = [int]$TimeoutInput
            if ($Config.Timeout -lt 100) { $Config.Timeout = 100 }
            if ($Config.Timeout -gt 30000) { $Config.Timeout = 30000 }
        }
    }
    
    # Output path
    $DefaultPath = Join-Path -Path $PWD -ChildPath "PortScan_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    Write-Host ""
    Write-Host "Output HTML path (default: $DefaultPath)" -ForegroundColor Cyan
    $OutputInput = Read-Host "Path"
    
    if ([string]::IsNullOrWhiteSpace($OutputInput)) {
        $Config.OutputPath = $DefaultPath
    }
    else {
        $Config.OutputPath = $OutputInput
    }
    
    return $Config
}

#endregion

#region Main Execution

function Start-InteractivePortScanner {
    <#
    .SYNOPSIS
        Main entry point for interactive port scanner
    #>
    
    Show-Banner
    
    # Get targets
    $Targets = Get-UserTargets
    if ($null -eq $Targets -or $Targets.Count -eq 0) {
        Write-Host "[!] No valid targets specified. Exiting." -ForegroundColor Red
        return
    }
    
    Write-Host ""
    Write-Host "[+] Loaded $($Targets.Count) target IP(s)" -ForegroundColor Green
    
    # Get ports
    $Ports = Get-UserPorts
    if ($null -eq $Ports -or $Ports.Count -eq 0) {
        Write-Host "[!] No valid ports specified. Exiting." -ForegroundColor Red
        return
    }
    
    Write-Host "[+] Loaded $($Ports.Count) port(s)" -ForegroundColor Green
    
    # Get protocol
    $Protocol = Get-UserProtocol
    Write-Host "[+] Protocol: $Protocol" -ForegroundColor Green
    
    # Get configuration
    $Config = Get-ScanConfiguration
    
    # Summary
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host " SCAN SUMMARY" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Targets:    $($Targets.Count) IP(s)" -ForegroundColor White
    Write-Host "  Ports:      $($Ports.Count) port(s)" -ForegroundColor White
    Write-Host "  Protocol:   $Protocol" -ForegroundColor White
    Write-Host "  Threads:    $($Config.MaxThreads)" -ForegroundColor White
    Write-Host "  Timeout:    $($Config.Timeout)ms" -ForegroundColor White
    Write-Host "  Output:     $($Config.OutputPath)" -ForegroundColor White
    
    $TaskCount = $Targets.Count * $Ports.Count
    if ($Protocol -eq 'Both') { $TaskCount *= 2 }
    Write-Host "  Total tasks: $TaskCount" -ForegroundColor White
    Write-Host ""
    
    $Confirm = Read-Host "Start scan? (y/n)"
    if ($Confirm -ne 'y') {
        Write-Host "Scan cancelled." -ForegroundColor Yellow
        return
    }
    
    # Run scan
    $Results = Start-PortScan -Targets $Targets -Ports $Ports -Protocol $Protocol `
        -MaxThreads $Config.MaxThreads -Timeout $Config.Timeout
    
    # Generate report
    if ($Results.Count -gt 0) {
        $TargetSummary = if ($Targets.Count -le 5) { $Targets -join ', ' } else { "$($Targets.Count) hosts" }
        $PortSummary = if ($Ports.Count -le 10) { $Ports -join ', ' } else { "$($Ports.Count) ports" }
        
        New-HTMLReport -Results $Results -OutputPath $Config.OutputPath `
            -ScanTargets $TargetSummary -ScanPorts $PortSummary -ScanProtocol $Protocol
        
        # Open report
        Write-Host ""
        $OpenReport = Read-Host "Open report in browser? (y/n)"
        if ($OpenReport -eq 'y') {
            Start-Process $Config.OutputPath
        }
        
        # Display quick summary
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host " QUICK RESULTS" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
        Write-Host ""
        
        $OpenPorts = $Results | Where-Object { $_.Status -eq 'Open' -or $_.Status -eq 'Open|Filtered' }
        if ($OpenPorts.Count -gt 0) {
            Write-Host "  Open ports found:" -ForegroundColor Green
            $OpenPorts | Group-Object IP | ForEach-Object {
                $HostPorts = ($_.Group | Sort-Object Port | ForEach-Object { "$($_.Port)/$($_.Protocol)" }) -join ', '
                Write-Host "    $($_.Name): $HostPorts" -ForegroundColor White
            }
        }
        else {
            Write-Host "  No open ports found." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "[!] No results collected." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "[+] Scan complete!" -ForegroundColor Green
}

# Entry point - run interactive scanner
Start-InteractivePortScanner
