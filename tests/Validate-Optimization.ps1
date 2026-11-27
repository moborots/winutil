#requires -Version 5.1
<#
.SYNOPSIS
    Static validation for the MOBOROTS Optimization tab integration.
.DESCRIPTION
    Run from the repository root in Windows PowerShell 5.1 or PowerShell 7.
    This validates syntax, XAML well-formedness, control names and action routing.
    It does not execute DISM, SFC, registry writes or network resets.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$powerShellFiles = @(
    "functions/public/Invoke-WinUtilOptimization.ps1",
    "functions/private/Invoke-WinUtilOptimizationAction.ps1",
    "functions/public/Invoke-WPFButton.ps1",
    "functions/private/Initialize-WinUtilTabContent.ps1",
    "functions/private/Start-WinUtilUserInterface.ps1"
)

foreach ($relativePath in $powerShellFiles) {
    $path = Join-Path $root $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing required PowerShell file: $relativePath"
    }

    $tokens = $null
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $path,
        [ref]$tokens,
        [ref]$parseErrors
    )
    if ($parseErrors.Count -gt 0) {
        $details = $parseErrors | ForEach-Object {
            "{0}: {1}" -f $_.Extent.StartLineNumber, $_.Message
        }
        throw ("PowerShell parse errors in " + $relativePath + [Environment]::NewLine + ($details -join [Environment]::NewLine))
    }
    Write-Host "PASS PowerShell syntax: $relativePath" -ForegroundColor Green
}

$xamlPath = Join-Path $root "xaml/inputXML.xaml"
[xml]$document = Get-Content -LiteralPath $xamlPath -Raw
$tabControl = $document.SelectSingleNode("//*[local-name()='TabControl' and @Name='WPFTabNav']")
if ($null -eq $tabControl) {
    throw "WPFTabNav was not found in inputXML.xaml."
}
$tabItems = @($tabControl.SelectNodes("./*[local-name()='TabItem']"))
if ($tabItems.Count -lt 7 -or $tabItems[6].GetAttribute("Name") -ne "WPFTab7") {
    throw "Optimization must be the seventh tab item so WPFTab7BT routes to the correct index."
}
Write-Host "PASS XAML parse and Optimization tab index" -ForegroundColor Green

$namedControls = @($document.SelectNodes("//*[@Name]") | ForEach-Object { $_.GetAttribute("Name") })
$requiredControls = @(
    "WPFTab7BT", "WPFTab7",
    "WPFOptStartupRefresh", "WPFOptResourcesRefresh", "WPFOptNetworkRefresh",
    "WPFOptRepairDISMCheckHealth", "WPFOptRepairDISMScanHealth",
    "WPFOptRepairDISMRestoreHealth", "WPFOptRepairSFCScan",
    "WPFOptExperienceSetting", "WPFOptExperienceState", "OptimizationPreviewOnly",
    "WPFOptBackupPath", "WPFOptExperienceApply", "WPFOptBrowseBackup",
    "WPFOptExperienceRestore", "WPFOptNetworkFlushDNS",
    "WPFOptNetworkResetWinsock", "WPFOptNetworkResetTCPIP",
    "WPFOptStatus", "WPFOptProgress", "WPFOptOutput"
)
$missing = @($requiredControls | Where-Object { $_ -notin $namedControls })
if ($missing.Count -gt 0) {
    throw "Missing Optimization XAML controls: $($missing -join ', ')"
}
Write-Host "PASS Optimization controls exist" -ForegroundColor Green

$routerPath = Join-Path $root "functions/public/Invoke-WPFButton.ps1"
$routerText = Get-Content -LiteralPath $routerPath -Raw
foreach ($button in @(
    "WPFOptStartupRefresh", "WPFOptResourcesRefresh", "WPFOptNetworkRefresh",
    "WPFOptRepairDISMCheckHealth", "WPFOptRepairDISMScanHealth",
    "WPFOptRepairDISMRestoreHealth", "WPFOptRepairSFCScan",
    "WPFOptExperienceApply", "WPFOptExperienceRestore",
    "WPFOptNetworkFlushDNS", "WPFOptNetworkResetWinsock", "WPFOptNetworkResetTCPIP"
)) {
    if ($routerText -notmatch [regex]::Escape('"' + $button + '"')) {
        throw "Optimization button is not registered as a worker action: $button"
    }
}
if ($routerText -notmatch '"WPFOpt\*"') {
    throw "Optimization action wildcard is missing from Invoke-WPFButtonAction."
}
Write-Host "PASS Optimization action routing" -ForegroundColor Green

$compileText = Get-Content -LiteralPath (Join-Path $root "Compile.ps1") -Raw
if ($compileText -notmatch 'Get-ChildItem\s+-Path\s+functions\s+-Recurse') {
    throw "Compile.ps1 no longer recursively bundles functions."
}
Write-Host "PASS Compile.ps1 recursively bundles new functions" -ForegroundColor Green

Write-Host "All static Optimization integration checks passed." -ForegroundColor Cyan
