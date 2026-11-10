function Get-WPFSystemToolsWindowsEdition {
    $key = Get-ItemProperty -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop
    $product = [string]$key.ProductName
    $edition = [string]$key.EditionID
    $displayVersion = [string]$key.DisplayVersion
    $build = [string]$key.CurrentBuild
    $ubr = [string]$key.UBR
    $version = if ($displayVersion) { $displayVersion } else { "N/A" }
    $buildText = if ($build) { "$build.$ubr" } else { "N/A" }

    [pscustomobject]@{
        Product = $product
        Edition = $edition
        DisplayVersion = $version
        Build = $buildText
    }
}

function Get-WPFSystemConfigFileInventory {
    $configPath = Join-Path $env:windir "System32\config"
    if (-not (Test-Path -LiteralPath $configPath -PathType Container)) {
        throw "The Windows config folder was not found: $configPath"
    }

    # Intentionally collect metadata only. Never open/read registry hive contents.
    Get-ChildItem -LiteralPath $configPath -Force -File -ErrorAction Stop |
        Sort-Object -Property Name |
        ForEach-Object {
            [pscustomobject]@{
                Name = $_.Name
                Length = $_.Length
                LastWriteTime = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                Attributes = [string]$_.Attributes
            }
        }
}


function Get-WPFSystemEditionUpgradeTargets {
    $dism = Join-Path $env:windir "System32\dism.exe"
    if (-not (Test-Path -LiteralPath $dism)) {
        throw "DISM.exe was not found."
    }
    $output = & $dism /Online /Get-TargetEditions 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "DISM could not query supported target editions. Exit code: $exitCode. $($output -join ' ')"
    }
    ($output | ForEach-Object { [string]$_ }) -join [Environment]::NewLine
}

function Open-WPFSystemSettings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SettingsUri
    )
    Start-Process -FilePath $SettingsUri -ErrorAction Stop
}

function Initialize-WPFSystemTools {
    try {
        $edition = Get-WPFSystemToolsWindowsEdition
        $newline = [Environment]::NewLine
        $sync.WPFSystemEditionInfo.Text = "Product name: $($edition.Product)$newline" +
            "Edition ID: $($edition.Edition)$newline" +
            "Display version: $($edition.DisplayVersion)$newline" +
            "OS build: $($edition.Build)"
        $sync.WPFSystemEditionTargetsInfo.Text = "Select Check upgrade paths to query DISM."
    } catch {
        $sync.WPFSystemEditionInfo.Text = "Unable to read Windows edition information. $($_.Exception.Message)"
    }

    Invoke-WPFSystemTools -Action "WPFSystemConfigRefreshButton"
}

function Invoke-WPFSystemTools {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Action
    )

    switch ($Action) {
        "WPFSystemStartSettingsButton" {
            Open-WPFSystemSettings -SettingsUri "ms-settings:personalization-start"
            return
        }
        "WPFSystemTaskbarSettingsButton" {
            Open-WPFSystemSettings -SettingsUri "ms-settings:taskbar"
            return
        }
        "WPFSystemCursorSettingsButton" {
            Open-WPFSystemSettings -SettingsUri "ms-settings:accessibility-mouse-pointer"
            return
        }
        "WPFSystemMousePropertiesButton" {
            Start-Process -FilePath "control.exe" -ArgumentList "main.cpl" -ErrorAction Stop
            return
        }
        "WPFSystemEditionActivationButton" {
            Open-WPFSystemSettings -SettingsUri "ms-settings:activation"
            return
        }
        "WPFSystemEditionTargetsButton" {
            try {
                $targets = Get-WPFSystemEditionUpgradeTargets
                $newline = [Environment]::NewLine
                $sync.WPFSystemEditionTargetsInfo.Text = "Supported target editions reported by DISM:$newline$targets"
            } catch {
                $sync.WPFSystemEditionTargetsInfo.Text = "Could not query upgrade targets. $($_.Exception.Message)"
            }
            return
        }
        "WPFSystemConfigRefreshButton" { }
        default { return }
    }

    try {
        $files = @(Get-WPFSystemConfigFileInventory)
        $sync.WPFSystemConfigFiles.ItemsSource = $null
        $sync.WPFSystemConfigFiles.ItemsSource = $files
        $sync.WPFSystemConfigStatus.Text = "Found $($files.Count) files. Metadata only; file contents were not accessed."
    } catch {
        $sync.WPFSystemConfigFiles.ItemsSource = $null
        $sync.WPFSystemConfigStatus.Text = "Could not list the folder. Run WinUtil as Administrator if access is denied. $($_.Exception.Message)"
        Write-WinUtilErrorRecord -ErrorRecord $_ -Component "SystemTools" -Context "List Windows config directory"
    }
}
