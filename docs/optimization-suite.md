# MOBOROTS Optimization Suite

The Optimization tab is integrated into the existing WinUtil WPF window. The feature
uses the repository's existing named-control mapping, Invoke-WPFButton routing,
Start-WinUtilJob worker queue, and Invoke-WPFUIThread dispatcher.

## WPF features

| Section | Controls | Behavior |
|---|---|---|
| Startup Manager | Refresh startup list | Read-only Run/RunOnce registry and Startup-folder inventory. It does not disable entries. |
| Resource Snapshot | Collect system snapshot | CPU load, memory, logical disk capacity and top memory-consuming processes. |
| Network Diagnostics | Run network checks | Network adapters, IP/DNS configuration, DNS resolution and basic connectivity. |
| Windows Repair | DISM CheckHealth, ScanHealth, RestoreHealth, SFC | Each operation requires an explicit confirmation and an elevated PowerShell session. |
| Windows Experience | Setting, State, Preview, Apply, Browse, Restore | Supports Explorer recent/frequent items, open This PC, Advertising ID and selected consumer suggestions. Writes a JSON backup before applying registry values. |
| Network Repair | Flush DNS, Reset Winsock, Reset TCP/IP | Requires confirmation and an elevated PowerShell session. Winsock/TCP/IP resets may require a restart. |

Reports and operation results appear in the tab's status and output areas. Long-running
actions use WinUtil's existing worker-job queue and global progress indicator. The
Optimization tab also has an Alt+O navigation shortcut.

## PowerShell commands

| Command | Behavior |
|---|---|
| Get-WinUtilStartupEntries | Read-only startup inventory |
| Get-WinUtilResourceSnapshot | CPU, memory, disks and top processes |
| Get-WinUtilNetworkDiagnostics | Adapter, IP, DNS and connectivity diagnostics |
| Invoke-WinUtilSystemRepair -Operation ... | DISM CheckHealth/ScanHealth/RestoreHealth or SFC |
| Set-WinUtilExperience -Setting ... -State ... | Reversible per-user Windows experience preference |
| Restore-WinUtilExperienceBackup -Path ... | Restores registry values from a JSON backup |
| Invoke-WinUtilNetworkRepair -Operation ... | Flush DNS, reset Winsock or reset TCP/IP |

## Examples

    Get-WinUtilStartupEntries | Format-Table -AutoSize
    Get-WinUtilResourceSnapshot | Format-List
    Get-WinUtilNetworkDiagnostics | ConvertTo-Json -Depth 8

    # Preview only: no registry changes and no backup file is written
    Set-WinUtilExperience -Setting AdvertisingId -State Disable -WhatIf

    # Apply; the result includes the backup path
    Set-WinUtilExperience -Setting AdvertisingId -State Disable

    # Restore the previous values
    Restore-WinUtilExperienceBackup -Path <backup-json-path>

    # Repairs and network resets require an elevated shell
    Invoke-WinUtilSystemRepair -Operation DISMScanHealth
    Invoke-WinUtilSystemRepair -Operation SFCScan
    Invoke-WinUtilNetworkRepair -Operation FlushDNS

## Safety boundaries

- No operation runs automatically when WinUtil starts.
- Startup, resource and network diagnostics are read-only.
- System repair and network reset actions require explicit UI confirmation and elevation.
- Experience changes save the exact previous registry values before applying them. Each apply creates a fresh restore point; an existing backup file is never overwritten.
- Restore accepts only the registry paths and value names emitted by this feature's backup format.
- The Preview only checkbox invokes PowerShell WhatIf and does not write registry values or a backup.
- No Windows Defender, Windows Update, Firewall, VBS, Memory Integrity, SysMain, Search or Pagefile settings are disabled.
- No startup entry is automatically disabled or removed.
- WPF controls are accessed only on the interface thread; longer operations run through WinUtil's existing job queue.

## Validation

Run from the repository root on Windows:

    .\tests\Validate-Optimization.ps1

The static validation checks PowerShell parser errors, XAML well-formedness, tab ordering,
required named controls, action routing and recursive function bundling. It does not execute
DISM, SFC, registry writes or network resets. The UI and native Windows commands still need
a runtime test on Windows 10/11 before the PR is considered ready to merge.
