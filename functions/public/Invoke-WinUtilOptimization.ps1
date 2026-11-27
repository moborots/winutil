#requires -Version 5.1
<#
.SYNOPSIS
    Safe diagnostic and maintenance commands for the MOBOROTS optimization suite.
.DESCRIPTION
    Read-only reports are the default. Changes and repair operations are explicit,
    support ShouldProcess/WhatIf where applicable, and never disable security or
    Windows Update services.
#>

function Get-WinUtilStartupEntries {
    [CmdletBinding()]
    param()

    $items = New-Object System.Collections.Generic.List[object]
    $runKeys = @(
        @{ Scope = "CurrentUser"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" },
        @{ Scope = "CurrentUser"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" },
        @{ Scope = "LocalMachine"; Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" },
        @{ Scope = "LocalMachine"; Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" },
        @{ Scope = "LocalMachine"; Path = "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" }
    )

    foreach ($key in $runKeys) {
        if (Test-Path -LiteralPath $key.Path) {
            $properties = Get-ItemProperty -LiteralPath $key.Path -ErrorAction SilentlyContinue
            if ($properties) {
                foreach ($property in $properties.PSObject.Properties) {
                    if ($property.Name -notlike "PS*") {
                        $items.Add([pscustomobject]@{
                            Name = $property.Name; Command = [string]$property.Value
                            Scope = $key.Scope; Source = $key.Path; Kind = "Registry"
                        })
                    }
                }
            }
        }
    }

    $startupFolders = @(
        @{ Scope = "CurrentUser"; Path = [Environment]::GetFolderPath("Startup") },
        @{ Scope = "AllUsers"; Path = [Environment]::GetFolderPath("CommonStartup") }
    )
    foreach ($folder in $startupFolders) {
        if ($folder.Path -and (Test-Path -LiteralPath $folder.Path)) {
            Get-ChildItem -LiteralPath $folder.Path -File -ErrorAction SilentlyContinue | ForEach-Object {
                $items.Add([pscustomobject]@{
                    Name = $_.BaseName; Command = $_.FullName; Scope = $folder.Scope
                    Source = $folder.Path; Kind = "StartupFolder"
                })
            }
        }
    }
    $items | Sort-Object Scope, Name
}

function Get-WinUtilResourceSnapshot {
    [CmdletBinding()]
    param([ValidateRange(1, 30)][int]$Top = 10)

    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue |
        Measure-Object -Property LoadPercentage -Average
    $totalMemoryGB = [math]::Round(([double]$os.TotalVisibleMemorySize / 1MB), 2)
    $freeMemoryGB = [math]::Round(([double]$os.FreePhysicalMemory / 1MB), 2)
    $usedMemoryGB = [math]::Round(($totalMemoryGB - $freeMemoryGB), 2)
    $memoryPercent = 0
    if ($totalMemoryGB -gt 0) { $memoryPercent = [math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 1) }

    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue |
        Select-Object DeviceID,
            @{Name="SizeGB";Expression={[math]::Round($_.Size / 1GB, 2)}},
            @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
            @{Name="FreePercent";Expression={if ($_.Size) {[math]::Round(($_.FreeSpace / $_.Size) * 100, 1)} else {0}}}
    $processes = Get-Process -ErrorAction SilentlyContinue |
        Sort-Object WorkingSet64 -Descending | Select-Object -First $Top Name, Id,
            @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet64 / 1MB, 1)}},
            @{Name="CpuTimeSeconds";Expression={if ($_.CPU -ne $null) {[math]::Round($_.CPU, 1)} else {$null}}}

    [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME; CapturedAt = Get-Date
        CpuLoadPercent = [math]::Round([double]$cpu.Average, 0)
        Memory = [pscustomobject]@{
            TotalGB = $totalMemoryGB; UsedGB = $usedMemoryGB
            FreeGB = $freeMemoryGB; UsedPercent = $memoryPercent
        }
        Disks = @($disks); TopProcesses = @($processes)
    }
}

function Get-WinUtilNetworkDiagnostics {
    [CmdletBinding()]
    param()

    $adapters = Get-NetAdapter -ErrorAction SilentlyContinue |
        Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress
    $ipConfig = Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
    $dns = @()
    foreach ($name in @("www.microsoft.com", "www.github.com")) {
        try {
            $answer = Resolve-DnsName -Name $name -Type A -ErrorAction Stop |
                Select-Object -First 2 Name, IPAddress
            $dns += [pscustomobject]@{ Host = $name; Success = $true; Answers = @($answer); Error = $null }
        } catch {
            $dns += [pscustomobject]@{ Host = $name; Success = $false; Answers = @(); Error = $_.Exception.Message }
        }
    }
    $connectivity = @()
    foreach ($target in @("1.1.1.1", "8.8.8.8")) {
        $connectivity += [pscustomobject]@{
            Target = $target
            Reachable = [bool](Test-Connection -ComputerName $target -Count 1 -Quiet -ErrorAction SilentlyContinue)
        }
    }
    [pscustomobject]@{
        CapturedAt = Get-Date; Adapters = @($adapters); IPConfiguration = @($ipConfig)
        DNSChecks = @($dns); ConnectivityChecks = @($connectivity)
    }
}

function Test-WinUtilAdministrator {
    [CmdletBinding()]
    param()
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-WinUtilSystemRepair {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("DISMCheckHealth", "DISMScanHealth", "DISMRestoreHealth", "SFCScan")]
        [string]$Operation
    )
    if (-not (Test-WinUtilAdministrator)) { throw "Run this repair operation from an elevated PowerShell session." }

    $exe = Join-Path $env:SystemRoot "System32\dism.exe"
    $arguments = switch ($Operation) {
        "DISMCheckHealth" { @("/Online", "/Cleanup-Image", "/CheckHealth") }
        "DISMScanHealth" { @("/Online", "/Cleanup-Image", "/ScanHealth") }
        "DISMRestoreHealth" { @("/Online", "/Cleanup-Image", "/RestoreHealth") }
        "SFCScan" { $exe = Join-Path $env:SystemRoot "System32\sfc.exe"; @("/scannow") }
    }
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Run $Operation")) {
        Write-Host "Running $Operation. This may take several minutes..." -ForegroundColor Cyan
        & $exe @arguments
        $exitCode = $LASTEXITCODE
        $result = [pscustomobject]@{
            Operation = $Operation; Executable = $exe; ExitCode = $exitCode
            Success = ($exitCode -eq 0); CompletedAt = Get-Date
        }
        if ($exitCode -ne 0) { Write-Warning "$Operation returned exit code $exitCode. Review Windows servicing logs." }
        $result
    }
}

function Set-WinUtilExperience {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("ExplorerThisPC", "ExplorerRecent", "AdvertisingId", "ConsumerSuggestions")]
        [string]$Setting,
        [Parameter(Mandatory)]
        [ValidateSet("Enable", "Disable")]
        [string]$State,
        [string]$BackupPath
    )

    $definitions = @{
        ExplorerThisPC = @(
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "LaunchTo"; EnableValue = 1; DisableValue = 2 }
        )
        ExplorerRecent = @(
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"; Name = "ShowRecent"; EnableValue = 1; DisableValue = 0 },
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"; Name = "ShowFrequent"; EnableValue = 1; DisableValue = 0 }
        )
        AdvertisingId = @(
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Name = "Enabled"; EnableValue = 1; DisableValue = 0 }
        )
        ConsumerSuggestions = @(
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name = "SubscribedContent-338393Enabled"; EnableValue = 1; DisableValue = 0 },
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name = "SubscribedContent-353694Enabled"; EnableValue = 1; DisableValue = 0 },
            @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Name = "SubscribedContent-353696Enabled"; EnableValue = 1; DisableValue = 0 }
        )
    }
    if ([string]::IsNullOrWhiteSpace($BackupPath)) {
        $folder = Join-Path $env:LOCALAPPDATA "winutil\backups"
        if (-not (Test-Path $folder)) { New-Item -Path $folder -ItemType Directory -Force | Out-Null }
        $BackupPath = Join-Path $folder ("experience-{0}.json" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
    }

    $changes = @()
    foreach ($entry in $definitions[$Setting]) {
        $exists = $false; $oldValue = $null
        if (Test-Path -LiteralPath $entry.Path) {
            $current = Get-ItemProperty -LiteralPath $entry.Path -Name $entry.Name -ErrorAction SilentlyContinue
            if ($null -ne $current) { $oldValue = $current.($entry.Name); $exists = $true }
        }
        $newValue = $entry.DisableValue
        if ($State -eq "Enable") { $newValue = $entry.EnableValue }
        $changes += [pscustomobject]@{
            Path = $entry.Path; Name = $entry.Name; Existed = $exists
            OldValue = $oldValue; NewValue = $newValue; Type = "DWord"
        }
    }
    [pscustomobject]@{ Setting = $Setting; StateBeforeChange = $changes; CreatedAt = Get-Date } |
        ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $BackupPath -Encoding UTF8

    if ($PSCmdlet.ShouldProcess($Setting, "Set Windows experience preference to $State; backup: $BackupPath")) {
        foreach ($change in $changes) {
            if (-not (Test-Path -LiteralPath $change.Path)) { New-Item -Path $change.Path -Force | Out-Null }
            New-ItemProperty -LiteralPath $change.Path -Name $change.Name -Value $change.NewValue -PropertyType DWord -Force | Out-Null
        }
        [pscustomobject]@{
            Setting = $Setting; State = $State; BackupPath = $BackupPath
            RestartExplorerRecommended = $true; Applied = $true
        }
    }
}

function Restore-WinUtilExperienceBackup {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$Path
    )
    $backup = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    foreach ($item in $backup.StateBeforeChange) {
        if ($PSCmdlet.ShouldProcess("$($item.Path)\$($item.Name)", "Restore previous registry value")) {
            if ($item.Existed) {
                if (-not (Test-Path -LiteralPath $item.Path)) { New-Item -Path $item.Path -Force | Out-Null }
                New-ItemProperty -LiteralPath $item.Path -Name $item.Name -Value $item.OldValue -PropertyType DWord -Force | Out-Null
            } else {
                Remove-ItemProperty -LiteralPath $item.Path -Name $item.Name -ErrorAction SilentlyContinue
            }
        }
    }
}

function Invoke-WinUtilNetworkRepair {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("FlushDNS", "ResetWinsock", "ResetTCPIP")]
        [string]$Operation
    )
    if (-not (Test-WinUtilAdministrator)) { throw "Run this network repair operation from an elevated PowerShell session." }

    $command = switch ($Operation) {
        "FlushDNS" { @{ File = (Join-Path $env:SystemRoot "System32\ipconfig.exe"); Args = @("/flushdns"); Reboot = $false } }
        "ResetWinsock" { @{ File = (Join-Path $env:SystemRoot "System32\netsh.exe"); Args = @("winsock", "reset"); Reboot = $true } }
        "ResetTCPIP" { @{ File = (Join-Path $env:SystemRoot "System32\netsh.exe"); Args = @("int", "ip", "reset"); Reboot = $true } }
    }
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, $Operation)) {
        & $command.File @($command.Args)
        $exitCode = $LASTEXITCODE
        [pscustomobject]@{
            Operation = $Operation; ExitCode = $exitCode; Success = ($exitCode -eq 0)
            RebootRecommended = $command.Reboot; CompletedAt = Get-Date
        }
    }
}
