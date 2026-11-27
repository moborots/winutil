#requires -Version 5.1
<#
.SYNOPSIS
    Downloads and launches the MOBOROTS WinUtil source from the main branch.
#>
[CmdletBinding()]
param(
    [ValidateSet("Standard", "Minimal", "Advanced", "")]
    [string]$Preset = "",
    [string]$Config = ""
)

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "MOBOROTS WinUtil must be launched from an elevated PowerShell/Terminal. Reopen the terminal as Administrator and run the command again."
}

$ErrorActionPreference = "Stop"
$workRoot = Join-Path $env:TEMP ("MOBOROTS-WinUtil-" + [guid]::NewGuid().ToString("N"))
$archive = Join-Path $workRoot "main.zip"
$sourceRoot = Join-Path $workRoot "winutil-main"

New-Item -ItemType Directory -Path $workRoot -Force | Out-Null
try {
    Write-Host "Downloading MOBOROTS WinUtil (main)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://github.com/moborots/winutil/archive/refs/heads/main.zip" -OutFile $archive -UseBasicParsing
    Expand-Archive -LiteralPath $archive -DestinationPath $workRoot -Force

    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot "Compile.ps1"))) {
        throw "The downloaded repository does not contain Compile.ps1."
    }

    Push-Location $sourceRoot
    try {
        Write-Host "Building MOBOROTS WinUtil..." -ForegroundColor Cyan
        & (Join-Path $sourceRoot "Compile.ps1")
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            throw "Compile.ps1 failed with exit code $LASTEXITCODE."
        }

        $compiledScript = Join-Path $sourceRoot "winutil.ps1"
        if (-not (Test-Path -LiteralPath $compiledScript)) {
            throw "The build did not produce winutil.ps1."
        }

        $launchParameters = @{}
        if ($Preset) { $launchParameters.Preset = $Preset }
        if ($Config) { $launchParameters.Config = $Config }

        Write-Host "Launching MOBOROTS WinUtil..." -ForegroundColor Green
        & $compiledScript @launchParameters
    }
    finally {
        Pop-Location
    }
}
catch {
    Write-Error ("MOBOROTS WinUtil could not be launched: " + $_.Exception.Message)
    throw
}

Write-Host "Source and build files were kept at: $workRoot" -ForegroundColor DarkGray
