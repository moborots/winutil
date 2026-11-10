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

function Initialize-WPFSystemTools {
    try {
        $edition = Get-WPFSystemToolsWindowsEdition
        $newline = [Environment]::NewLine
        $sync.WPFSystemEditionInfo.Text = "Product name: $($edition.Product)$newline" +
            "Edition ID: $($edition.Edition)$newline" +
            "Display version: $($edition.DisplayVersion)$newline" +
            "OS build: $($edition.Build)"
    } catch {
        $sync.WPFSystemEditionInfo.Text = "Unable to read Windows edition information. / خواندن اطلاعات نسخه ویندوز ممکن نشد. $($_.Exception.Message)"
    }

    Invoke-WPFSystemTools -Action "WPFSystemConfigRefreshButton"
}

function Invoke-WPFSystemTools {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Action
    )

    if ($Action -ne "WPFSystemConfigRefreshButton") {
        return
    }

    try {
        $files = @(Get-WPFSystemConfigFileInventory)
        $sync.WPFSystemConfigFiles.ItemsSource = $null
        $sync.WPFSystemConfigFiles.ItemsSource = $files
        $sync.WPFSystemConfigStatus.Text = "Found $($files.Count) files. Metadata only; file contents were not accessed. / تعداد $($files.Count) فایل پیدا شد. فقط مشخصات فایل‌ها نمایش داده شده و محتوای آن‌ها خوانده نشده است."
    } catch {
        $sync.WPFSystemConfigFiles.ItemsSource = $null
        $sync.WPFSystemConfigStatus.Text = "Could not list the folder. Run WinUtil as Administrator if access is denied. / نمایش پوشه ممکن نشد؛ در صورت رد شدن دسترسی، برنامه را با Administrator اجرا کنید. $($_.Exception.Message)"
        Write-WinUtilErrorRecord -ErrorRecord $_ -Component "SystemTools" -Context "List Windows config directory"
    }
}
