# MOBOROTS Optimization Suite (initial backend)

This change adds a PowerShell 5.1-compatible backend for five optimization areas.
Read-only reports are the default. Repairs require an explicit operation, and
registry changes create a backup before they are applied.

## Included commands

| Area | Command | Behavior |
|---|---|---|
| Startup Manager | Get-WinUtilStartupEntries | Read-only inventory of Run/RunOnce keys and Startup folders |
| Resource Monitor | Get-WinUtilResourceSnapshot | CPU load, memory, logical disks and top processes |
| Network Optimizer | Get-WinUtilNetworkDiagnostics | Adapters, IP/DNS configuration, DNS and connectivity checks |
| Windows Repair | Invoke-WinUtilSystemRepair -Operation ... | DISM CheckHealth/ScanHealth/RestoreHealth or SFC |
| Windows Experience | Set-WinUtilExperience -Setting ... -State ... | Reversible Explorer, Advertising ID and consumer-suggestion preferences |
| Restore | Restore-WinUtilExperienceBackup -Path ... | Restores previous registry values from a JSON backup |
| Network Repair | Invoke-WinUtilNetworkRepair -Operation ... | Flush DNS, reset Winsock or reset TCP/IP |

## Examples

    Get-WinUtilStartupEntries | Format-Table -AutoSize
    Get-WinUtilResourceSnapshot | Format-List
    Get-WinUtilNetworkDiagnostics | Format-List

    # Preview before changing anything
    Set-WinUtilExperience -Setting AdvertisingId -State Disable -WhatIf

    # Apply an individual preference; note the returned backup path
    Set-WinUtilExperience -Setting AdvertisingId -State Disable

    # Restore from the generated backup
    Restore-WinUtilExperienceBackup -Path <backup-json-path>

    # Repairs require an elevated shell and confirmation
    Invoke-WinUtilSystemRepair -Operation DISMScanHealth
    Invoke-WinUtilSystemRepair -Operation SFCScan

    # Network resets require elevation; Winsock/TCP-IP resets may require reboot
    Invoke-WinUtilNetworkRepair -Operation FlushDNS

## Safety notes

- No command runs automatically when WinUtil starts.
- Get-* commands are read-only.
- Repair and reset commands require an elevated PowerShell session and use ShouldProcess.
- Registry preference changes save exact previous values in a timestamped JSON file.
- -WhatIf previews supported changes without applying them.
- No Windows Defender, Windows Update, Firewall, VBS, Memory Integrity, SysMain,
  Search, or Pagefile settings are disabled by this module.
- The existing Compile.ps1 recursively bundles files under functions.
- This commit adds the backend only. A dedicated WPF tab, controls, progress wiring,
  and automated PowerShell tests are the next integration step; no new UI is claimed here.
