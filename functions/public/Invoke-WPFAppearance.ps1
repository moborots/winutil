function Test-WinUtilWindows11 {
    $currentVersion = Get-ItemProperty -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop
    return [int]$currentVersion.CurrentBuildNumber -ge 22000
}

function Initialize-WPFAppearance {
    if (-not (Test-WinUtilWindows11)) {
        $sync.WPFAppearanceStatus.Text = "This panel is designed for Windows 11 (build 22000 or later)."
        $sync.WPFAppearanceApplyButton.IsEnabled = $false
        return
    }

    $personalize = Get-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction SilentlyContinue
    $dwm = Get-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\DWM" -ErrorAction SilentlyContinue
    $advanced = Get-ItemProperty -LiteralPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ErrorAction SilentlyContinue
    $desktop = Get-ItemProperty -LiteralPath "HKCU:\Control Panel\Desktop" -ErrorAction SilentlyContinue
    $windowMetrics = Get-ItemProperty -LiteralPath "HKCU:\Control Panel\Desktop\WindowMetrics" -ErrorAction SilentlyContinue

    $sync.WPFAppearanceThemeCombo.SelectedIndex = if ($personalize.SystemUsesLightTheme -eq 0) { 1 } else { 0 }
    $sync.WPFAppearanceAccentCombo.SelectedIndex = 0
    $sync.WPFAppearanceTaskbarCombo.SelectedIndex = if ($advanced.TaskbarAl -eq 0) { 0 } else { 1 }
    $sync.WPFAppearanceTransparencyCheck.IsChecked = ($personalize.EnableTransparency -ne 0)
    $sync.WPFAppearanceAnimationsCheck.IsChecked = ($advanced.TaskbarAnimations -ne 0 -and $windowMetrics.MinAnimate -ne "0")
    $sync.WPFAppearanceWallpaperTextBox.Text = [string]$desktop.Wallpaper
    $sync.WPFAppearanceStatus.Text = "Settings loaded. Changes are applied only after you select Apply."
}

function Set-WinUtilAppearanceRegistryValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet("DWord", "String")][string]$Type = "DWord"
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    if ($Type -eq "DWord") {
        New-ItemProperty -LiteralPath $Path -Name $Name -Value ([int]$Value) -PropertyType DWord -Force | Out-Null
    } else {
        New-ItemProperty -LiteralPath $Path -Name $Name -Value ([string]$Value) -PropertyType String -Force | Out-Null
    }
}

function Save-WinUtilAppearanceBackup {
    $backupPath = Join-Path $env:LOCALAPPDATA "winutil\appearance-backup.json"
    if (Test-Path -LiteralPath $backupPath) {
        return $backupPath
    }

    $registryValues = @(
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "SystemUsesLightTheme" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "AppsUseLightTheme" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"; Name = "EnableTransparency" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "AccentColor" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\DWM"; Name = "ColorPrevalence" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAl" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAnimations" }
        @{ Path = "HKCU:\Control Panel\Desktop\WindowMetrics"; Name = "MinAnimate" }
        @{ Path = "HKCU:\Control Panel\Desktop"; Name = "Wallpaper" }
    )

    $snapshot = foreach ($entry in $registryValues) {
        $key = Get-ItemProperty -LiteralPath $entry.Path -Name $entry.Name -ErrorAction SilentlyContinue
        $property = if ($null -ne $key) { $key.PSObject.Properties[$entry.Name] } else { $null }
        $valueKind = $null
        if ($null -ne $property) {
            try {
                $subKey = Get-Item -LiteralPath $entry.Path -ErrorAction Stop
                $valueKind = $subKey.GetValueKind($entry.Name).ToString()
            } catch {
                $valueKind = "String"
            }
        }

        [PSCustomObject]@{
            Path = $entry.Path
            Name = $entry.Name
            Exists = ($null -ne $property)
            Value = if ($null -ne $property) { $property.Value } else { $null }
            Kind = $valueKind
        }
    }

    $directory = Split-Path -Parent $backupPath
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $snapshot | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $backupPath -Encoding UTF8
    return $backupPath
}

function Set-WinUtilWallpaper {
    param([Parameter(Mandatory)][string]$Path)

    if (-not ([System.Management.Automation.PSTypeName]"WinUtilWallpaperNative").Type) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class WinUtilWallpaperNative {
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool SystemParametersInfo(int action, int parameter, string value, int winIni);
}
"@
    }

    $desktopPath = "HKCU:\Control Panel\Desktop"
    Set-WinUtilAppearanceRegistryValue -Path $desktopPath -Name "Wallpaper" -Value $Path -Type String
    $result = [WinUtilWallpaperNative]::SystemParametersInfo(20, 0, $Path, 3)
    if (-not $result) {
        throw "Windows could not apply the selected wallpaper."
    }
}

function Invoke-WPFAppearanceApply {
    if (-not (Test-WinUtilWindows11)) {
        throw "Windows 11 (build 22000 or later) is required."
    }

    $null = Save-WinUtilAppearanceBackup
    $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
    $advancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $windowMetricsPath = "HKCU:\Control Panel\Desktop\WindowMetrics"

    switch ($sync.WPFAppearanceThemeCombo.SelectedIndex) {
        0 {
            # Auto means keep the current Windows theme; Windows does not provide a native
            # scheduled light/dark switch, so this option deliberately does not claim to schedule one.
        }
        1 {
            Set-WinUtilAppearanceRegistryValue -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0
            Set-WinUtilAppearanceRegistryValue -Path $personalizePath -Name "AppsUseLightTheme" -Value 0
        }
        2 {
            Set-WinUtilAppearanceRegistryValue -Path $personalizePath -Name "SystemUsesLightTheme" -Value 1
            Set-WinUtilAppearanceRegistryValue -Path $personalizePath -Name "AppsUseLightTheme" -Value 1
        }
    }

    Set-WinUtilAppearanceRegistryValue -Path $personalizePath -Name "EnableTransparency" -Value ([int][bool]$sync.WPFAppearanceTransparencyCheck.IsChecked)

    $accentColors = @{
        "Default" = "#0078D4"
        "Blue" = "#0078D4"
        "Purple" = "#8764B8"
        "Pink" = "#E74856"
        "Red" = "#C42B1C"
        "Orange" = "#F7630C"
        "Green" = "#107C10"
        "Teal" = "#038387"
    }
    $accentName = [string]$sync.WPFAppearanceAccentCombo.SelectedItem.Tag
    $hex = $accentColors[$accentName]
    if ($hex) {
        $r = [Convert]::ToInt32($hex.Substring(1, 2), 16)
        $g = [Convert]::ToInt32($hex.Substring(3, 2), 16)
        $b = [Convert]::ToInt32($hex.Substring(5, 2), 16)
        $accentDword = [long]0xFF000000 -bor ([long]$b -shl 16) -bor ([long]$g -shl 8) -bor [long]$r
        Set-WinUtilAppearanceRegistryValue -Path $dwmPath -Name "AccentColor" -Value ([int]($accentDword -band 0xFFFFFFFF))
        Set-WinUtilAppearanceRegistryValue -Path $dwmPath -Name "ColorPrevalence" -Value 1
    }

    $taskbarAlignment = if ($sync.WPFAppearanceTaskbarCombo.SelectedIndex -eq 0) { 0 } else { 1 }
    Set-WinUtilAppearanceRegistryValue -Path $advancedPath -Name "TaskbarAl" -Value $taskbarAlignment

    $animationsEnabled = [bool]$sync.WPFAppearanceAnimationsCheck.IsChecked
    Set-WinUtilAppearanceRegistryValue -Path $advancedPath -Name "TaskbarAnimations" -Value ([int]$animationsEnabled)
    Set-WinUtilAppearanceRegistryValue -Path $windowMetricsPath -Name "MinAnimate" -Value $(if ($animationsEnabled) { "1" } else { "0" }) -Type String

    $wallpaper = [string]$sync.WPFAppearanceWallpaperTextBox.Text
    if (-not [string]::IsNullOrWhiteSpace($wallpaper)) {
        if (-not (Test-Path -LiteralPath $wallpaper -PathType Leaf)) {
            throw "Wallpaper file not found: $wallpaper"
        }
        Set-WinUtilWallpaper -Path $wallpaper
    }

    Invoke-WinUtilExplorerUpdate -action "refresh"
    $sync.WPFAppearanceStatus.Text = "Appearance settings applied. Taskbar alignment may require restarting Windows Explorer or signing out."
}

function Invoke-WPFAppearanceRestore {
    $backupPath = Join-Path $env:LOCALAPPDATA "winutil\appearance-backup.json"
    if (-not (Test-Path -LiteralPath $backupPath)) {
        $sync.WPFAppearanceStatus.Text = "No appearance backup exists yet. Apply a change first."
        return
    }

    $snapshot = @(Get-Content -LiteralPath $backupPath -Raw | ConvertFrom-Json)
    foreach ($entry in $snapshot) {
        if ($entry.Exists) {
            $type = if ($entry.Kind -eq "DWord") { "DWord" } else { "String" }
            Set-WinUtilAppearanceRegistryValue -Path $entry.Path -Name $entry.Name -Value $entry.Value -Type $type
        } elseif (Test-Path -LiteralPath $entry.Path) {
            Remove-ItemProperty -LiteralPath $entry.Path -Name $entry.Name -ErrorAction SilentlyContinue
        }
    }

    $desktop = Get-ItemProperty -LiteralPath "HKCU:\Control Panel\Desktop" -ErrorAction SilentlyContinue
    if ($desktop.Wallpaper -and (Test-Path -LiteralPath $desktop.Wallpaper -PathType Leaf)) {
        Set-WinUtilWallpaper -Path $desktop.Wallpaper
    }

    Remove-Item -LiteralPath $backupPath -Force
    Invoke-WinUtilExplorerUpdate -action "refresh"
    Initialize-WPFAppearance
    $sync.WPFAppearanceStatus.Text = "Your original appearance settings have been restored from the backup."
}

function Invoke-WPFAppearance {
    param([Parameter(Mandatory)][string]$Action)

    try {
        switch ($Action) {
            "WPFAppearanceApplyButton" { Invoke-WPFAppearanceApply }
            "WPFAppearanceRestoreButton" { Invoke-WPFAppearanceRestore }
            "WPFAppearanceBrowseButton" {
                $dialog = New-Object Microsoft.Win32.OpenFileDialog
                $dialog.Title = "Select a Windows wallpaper"
                $dialog.Filter = "Image files|*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff|All files|*.*"
                $dialog.Multiselect = $false
                if ($dialog.ShowDialog()) {
                    $sync.WPFAppearanceWallpaperTextBox.Text = $dialog.FileName
                }
            }
        }
    } catch {
        $sync.WPFAppearanceStatus.Text = "Error: $($_.Exception.Message)"
        Write-WinUtilErrorRecord -ErrorRecord $_ -Component "Appearance" -Context $Action
    }
}
