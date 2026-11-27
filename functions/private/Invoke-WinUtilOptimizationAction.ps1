function Invoke-WinUtilOptimizationAction {
    <#
    .SYNOPSIS
        Executes one Optimization-tab action from a WinUtil worker job.
    .DESCRIPTION
        UI controls are read on the interface thread and passed in as values. This function
        never reads or writes WPF controls directly from the worker runspace.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Button,
        [string]$Setting,
        [string]$State,
        [string]$BackupPath,
        [switch]$PreviewOnly
    )

    $operationName = $Button -replace "^WPFOpt", ""
    $status = "Running $operationName..."
    $result = $null
    $backupResult = $null

    Invoke-WPFUIThread -Async -Parameters @{ Status = $status } -ScriptBlock {
        param($Status)
        if ($sync.WPFOptStatus) { $sync.WPFOptStatus.Text = $Status }
        if ($sync.WPFOptProgress) {
            $sync.WPFOptProgress.Visibility = [Windows.Visibility]::Visible
            $sync.WPFOptProgress.IsIndeterminate = $true
            $sync.WPFOptProgress.Value = 0
        }
    }
    Step-WinUtilJob -Status $status -State "Indeterminate"

    try {
        switch ($Button) {
            "WPFOptStartupRefresh" {
                $status = "Reading startup entries..."
                Step-WinUtilJob -Status $status -Percent 15
                $result = @(Get-WinUtilStartupEntries)
            }
            "WPFOptResourcesRefresh" {
                $status = "Collecting CPU, memory, disk and process data..."
                Step-WinUtilJob -Status $status -Percent 15
                $result = Get-WinUtilResourceSnapshot
            }
            "WPFOptNetworkRefresh" {
                $status = "Checking adapters, DNS and connectivity..."
                Step-WinUtilJob -Status $status -Percent 15
                $result = Get-WinUtilNetworkDiagnostics
            }
            { $_ -in "WPFOptRepairDISMCheckHealth", "WPFOptRepairDISMScanHealth", "WPFOptRepairDISMRestoreHealth", "WPFOptRepairSFCScan" } {
                $operation = switch ($Button) {
                    "WPFOptRepairDISMCheckHealth" { "DISMCheckHealth" }
                    "WPFOptRepairDISMScanHealth" { "DISMScanHealth" }
                    "WPFOptRepairDISMRestoreHealth" { "DISMRestoreHealth" }
                    "WPFOptRepairSFCScan" { "SFCScan" }
                }
                $status = "Running $operation. This may take several minutes..."
                Step-WinUtilJob -Status $status -State "Indeterminate"
                $result = Invoke-WinUtilSystemRepair -Operation $operation -Confirm:$false
            }
            "WPFOptExperienceApply" {
                if ([string]::IsNullOrWhiteSpace($Setting) -or [string]::IsNullOrWhiteSpace($State)) {
                    throw "Choose a Windows experience setting and state first."
                }
                $status = if ($PreviewOnly) { "Previewing $Setting..." } else { "Applying $Setting..." }
                Step-WinUtilJob -Status $status -State "Indeterminate"
                $result = Set-WinUtilExperience -Setting $Setting -State $State -BackupPath $BackupPath -Confirm:$false -WhatIf:$PreviewOnly
                if ($PreviewOnly) {
                    $result = [pscustomobject]@{
                        Setting = $Setting
                        RequestedState = $State
                        PreviewOnly = $true
                        ChangesApplied = $false
                        BackupCreated = $false
                        Message = "Preview only: no registry values were changed and no backup was written."
                    }
                } elseif ($result) {
                    $backupResult = $result.BackupPath
                }
            }
            "WPFOptExperienceRestore" {
                if ([string]::IsNullOrWhiteSpace($BackupPath)) {
                    throw "Select a JSON backup file before restoring."
                }
                $status = "Restoring Windows experience settings..."
                Step-WinUtilJob -Status $status -State "Indeterminate"
                Restore-WinUtilExperienceBackup -Path $BackupPath -Confirm:$false
                $result = [pscustomobject]@{
                    Restored = $true
                    BackupPath = $BackupPath
                    CompletedAt = Get-Date
                    Message = "Saved registry values were restored from the selected backup."
                }
            }
            "WPFOptNetworkFlushDNS" {
                $status = "Flushing the DNS resolver cache..."
                Step-WinUtilJob -Status $status -State "Indeterminate"
                $result = Invoke-WinUtilNetworkRepair -Operation "FlushDNS" -Confirm:$false
            }
            "WPFOptNetworkResetWinsock" {
                $status = "Resetting Winsock. A restart may be required..."
                Step-WinUtilJob -Status $status -State "Indeterminate"
                $result = Invoke-WinUtilNetworkRepair -Operation "ResetWinsock" -Confirm:$false
            }
            "WPFOptNetworkResetTCPIP" {
                $status = "Resetting TCP/IP. A restart may be required..."
                Step-WinUtilJob -Status $status -State "Indeterminate"
                $result = Invoke-WinUtilNetworkRepair -Operation "ResetTCPIP" -Confirm:$false
            }
            default {
                throw "Unknown Optimization action: $Button"
            }
        }

        $output = if ($null -eq $result) { "No output was returned." } else {
            ConvertTo-Json -InputObject $result -Depth 8
        }
        $status = if ($PreviewOnly -and $Button -eq "WPFOptExperienceApply") {
            "Preview completed. No changes were made."
        } else {
            "Completed: $operationName"
        }

        Step-WinUtilJob -Status $status -Percent 100 -State "Normal" -Overlay "checkmark"
        Invoke-WPFUIThread -Async -Parameters @{
            Text = $output
            Status = $status
            BackupPath = $backupResult
        } -ScriptBlock {
            param($Text, $Status, $BackupPath)
            if ($sync.WPFOptOutput) { $sync.WPFOptOutput.Text = $Text }
            if ($sync.WPFOptStatus) { $sync.WPFOptStatus.Text = $Status }
            if (-not [string]::IsNullOrWhiteSpace($BackupPath) -and $sync.WPFOptBackupPath) {
                $sync.WPFOptBackupPath.Text = $BackupPath
            }
            if ($sync.WPFOptProgress) {
                $sync.WPFOptProgress.IsIndeterminate = $false
                $sync.WPFOptProgress.Value = 100
            }
        }
    } catch {
        $errorText = $_.Exception.Message
        $status = "Failed: $errorText"
        Step-WinUtilJob -Status $status -State "Error" -Overlay "warning"
        Invoke-WPFUIThread -Async -Parameters @{
            Text = $errorText
            Status = $status
        } -ScriptBlock {
            param($Text, $Status)
            if ($sync.WPFOptOutput) { $sync.WPFOptOutput.Text = $Text }
            if ($sync.WPFOptStatus) { $sync.WPFOptStatus.Text = $Status }
            if ($sync.WPFOptProgress) {
                $sync.WPFOptProgress.IsIndeterminate = $false
                $sync.WPFOptProgress.Value = 0
            }
        }
        throw
    }
}
