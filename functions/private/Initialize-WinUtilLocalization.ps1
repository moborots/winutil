function Get-WinUtilLocalizedText {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }

    if ($null -eq $script:WinUtilPersianText) {
        $script:WinUtilPersianText = @{
            "WinUtil" = "وین‌یوتیل"
            "Offline Mode - No Internet Connection" = "حالت آفلاین - اتصال اینترنت وجود ندارد"
            "Press Ctrl-F and type app name to filter application list below. Press Esc to reset the filter" = "برای جست‌وجوی برنامه Ctrl+F را بزنید و نام آن را وارد کنید. برای پاک کردن جست‌وجو Esc را بزنید."
            "Running and queued operations" = "عملیات در حال اجرا و در صف"
            "N/A" = "نامشخص"
            "Change the WinUtil UI Theme" = "تغییر پوسته برنامه"
            "Auto" = "خودکار"
            "Follow the Windows Theme" = "هماهنگ با پوسته ویندوز"
            "Dark" = "تیره"
            "Use Dark Theme" = "استفاده از پوسته تیره"
            "Light" = "روشن"
            "Use Light Theme" = "استفاده از پوسته روشن"
            "Adjust Font Scaling for Accessibility" = "تنظیم اندازه نوشته‌ها برای خوانایی بهتر"
            "Font Scaling" = "اندازه نوشته‌ها"
            "Small" = "کوچک"
            "Large" = "بزرگ"
            "Reset" = "بازنشانی"
            "Apply" = "اعمال"
            "Settings" = "تنظیمات"
            "Import" = "درون‌ریزی"
            "Import Configuration from exported file." = "درون‌ریزی پیکربندی از فایل خروجی"
            "Export" = "برون‌ریزی"
            "Export Selected Elements and copy execution command to clipboard." = "برون‌ریزی موارد انتخاب‌شده و کپی دستور اجرا"
            "Export Environment Report" = "خروجی گزارش سیستم"
            "Export a read-only diagnostics report for troubleshooting." = "تهیه گزارش تشخیصی فقط‌خواندنی برای عیب‌یابی"
            "About" = "درباره برنامه"
            "Documentation" = "مستندات"
            "Sponsors" = "حامیان"
            "Minimize" = "کمینه"
            "Close" = "بستن"
            "Install" = "نصب برنامه‌ها"
            "Filter by category. Ctrl click to select more than one." = "فیلتر بر اساس دسته‌بندی؛ برای انتخاب چند مورد Ctrl را نگه دارید."
            "All" = "همه"
            "Browsers" = "مرورگرها"
            "Communications" = "ارتباطات"
            "Development" = "توسعه"
            "Document" = "اسناد"
            "Games" = "بازی‌ها"
            "Microsoft Tools" = "ابزارهای مایکروسافت"
            "Multimedia Tools" = "ابزارهای چندرسانه‌ای"
            "Pro Tools" = "ابزارهای حرفه‌ای"
            "Selfhosted Tools" = "ابزارهای میزبانی‌شده شخصی"
            "Utilities" = "ابزارهای کاربردی"
            "Installing..." = "در حال نصب..."
            "This can take several minutes. Progress is shown below." = "این عملیات ممکن است چند دقیقه طول بکشد. پیشرفت آن در پایین نمایش داده می‌شود."
            "Tweaks" = "بهینه‌سازی‌ها"
            "Recommended Selections:" = "انتخاب‌های پیشنهادی:"
            " Standard " = " استاندارد "
            " Minimal " = " حداقلی "
            " Advanced " = " پیشرفته "
            " Clear " = " پاک‌کردن "
            " Select Installed Tweaks " = "انتخاب بهینه‌سازی‌های اعمال‌شده"
            " AppX Removal " = " حذف برنامه‌های AppX "
            "Run Tweaks" = "اجرای بهینه‌سازی‌ها"
            "Undo Selected Tweaks" = "بازگردانی موارد انتخاب‌شده"
            "Applying tweaks..." = "در حال اعمال بهینه‌سازی‌ها..."
            "Config" = "تنظیمات ویندوز"
            "Updates" = "به‌روزرسانی‌ها"
            "Windows Update Profiles" = "پروفایل‌های به‌روزرسانی ویندوز"
            "Choose how Windows receives updates. Each profile replaces the Windows Update settings managed by WinUtil." = "روش دریافت به‌روزرسانی‌های ویندوز را انتخاب کنید. هر پروفایل تنظیمات مدیریت‌شده توسط WinUtil را جایگزین می‌کند."
            "Recommended" = "پیشنهادی"
            "Balanced security and stability" = "تعادل میان امنیت و پایداری"
            "- Defers feature updates for 365 days" = "- تأخیر ۳۶۵ روزه در به‌روزرسانی‌های قابلیت"
            "- Defers quality updates for 4 days" = "- تأخیر ۴ روزه در به‌روزرسانی‌های کیفی"
            "- Excludes drivers from quality updates" = "- حذف درایورها از به‌روزرسانی‌های کیفی"
            "- Notifies when downloaded updates are ready to install" = "- اطلاع‌رسانی هنگام آماده‌شدن به‌روزرسانی‌های دانلودشده"
            "Available on Windows Pro, Enterprise, and Education editions." = "در نسخه‌های Pro، Enterprise و Education ویندوز در دسترس است."
            "Apply Recommended" = "اعمال تنظیمات پیشنهادی"
            "Windows Default" = "تنظیمات پیش‌فرض ویندوز"
            "Return control to Windows" = "واگذاری مدیریت به ویندوز"
            "- Removes Windows Update policies applied by WinUtil" = "- حذف سیاست‌های Windows Update اعمال‌شده توسط WinUtil"
            "- Restores update service startup settings" = "- بازگردانی تنظیمات راه‌اندازی سرویس‌های به‌روزرسانی"
            "- Re-enables update scheduled tasks" = "- فعال‌سازی دوباره وظایف زمان‌بندی‌شده به‌روزرسانی"
            "Use this to undo the Recommended or Disable profile." = "برای لغو پروفایل پیشنهادی یا غیرفعال‌سازی از این گزینه استفاده کنید."
            "Restore Defaults" = "بازگردانی پیش‌فرض‌ها"
            "Disable Updates" = "غیرفعال‌سازی به‌روزرسانی‌ها"
            "Advanced use only" = "فقط برای کاربران حرفه‌ای"
            "- Disables automatic update policy" = "- غیرفعال‌سازی سیاست به‌روزرسانی خودکار"
            "- Stops update services and scheduled tasks" = "- توقف سرویس‌ها و وظایف زمان‌بندی‌شده به‌روزرسانی"
            "- Clears downloaded update files" = "- پاک‌کردن فایل‌های دانلودشده به‌روزرسانی"
            "Security updates will not be installed while this profile is active." = "تا زمان فعال بودن این پروفایل، به‌روزرسانی‌های امنیتی نصب نخواهند شد."
            "Changes apply system-wide. Restart Windows after switching profiles. Use Restore Defaults to undo WinUtil update policies." = "تغییرات در کل سیستم اعمال می‌شوند. پس از تغییر پروفایل، ویندوز را راه‌اندازی مجدد کنید. برای لغو سیاست‌های WinUtil از «بازگردانی پیش‌فرض‌ها» استفاده کنید."
            "Win11ISO" = "ساخت ISO ویندوز ۱۱"
            "Back to the previous step" = "بازگشت به مرحله قبل"
            "Forward to the next step" = "رفتن به مرحله بعد"
            "1   Select ISO" = "۱ ـ انتخاب فایل ISO"
            "Select your Windows 11 ISO" = "فایل ISO ویندوز ۱۱ را انتخاب کنید"
            "ISO file" = "فایل ISO"
            "No ISO selected..." = "هیچ فایل ISO انتخاب نشده است..."
            "Browse" = "مرور..."
            "File size:" = "حجم فایل:"
            "Mount &amp; Verify ISO" = "اتصال و بررسی ISO"
            " You must use an official Microsoft ISO" = " باید از فایل ISO رسمی مایکروسافت استفاده کنید"
            "Open Microsoft Download Page" = "بازکردن صفحه دانلود مایکروسافت"
            "2   Modify Image" = "۲ ـ ویرایش تصویر"
            "Modify the image" = "ویرایش تصویر"
            "Mounted at" = "متصل‌شده در"
            "Image file" = "فایل تصویر"
            "Windows edition" = "نسخه ویندوز"
            "Inject current system drivers" = "افزودن درایورهای سیستم فعلی"
            "Injects boot-storage drivers for Setup and adds exported drivers to the selected install.wim edition individually, skipping incompatible packages." = "درایورهای ذخیره‌سازی موردنیاز راه‌اندازی را اضافه می‌کند و درایورهای خروجی را جداگانه به نسخه انتخاب‌شده install.wim می‌افزاید؛ بسته‌های ناسازگار نادیده گرفته می‌شوند."
            "Run Windows ISO Modification and Creator" = "شروع ویرایش و ساخت ISO ویندوز"
            "What this does to the image" = "تغییرات اعمال‌شده روی تصویر"
            "Removes the preinstalled apps and the OneDrive setup" = "حذف برنامه‌های ازپیش‌نصب‌شده و راه‌اندازی OneDrive"
            "Bypasses the TPM, Secure Boot, CPU, RAM and storage checks" = "عبور از بررسی‌های TPM، Secure Boot، پردازنده، RAM و فضای ذخیره‌سازی"
            "Skips the Microsoft account screen so you can use a local account" = "ردکردن صفحه حساب مایکروسافت برای استفاده از حساب محلی"
            "Turns off telemetry, Copilot, the chat icon and search box suggestions" = "غیرفعال‌کردن تله‌متری، Copilot، نماد گفتگو و پیشنهادهای جست‌وجو"
            "Pins the edition you picked above so Setup does not choose another one" = "ثابت‌کردن نسخه انتخاب‌شده تا Setup نسخه دیگری را انتخاب نکند"
            "3   Output" = "۳ ـ خروجی"
            "Your image is ready" = "تصویر شما آماده است"
            "Save as an ISO File" = "ذخیره به‌صورت فایل ISO"
            "Write Directly to a USB Drive (ERASES DRIVE)" = "نوشتن مستقیم روی حافظه USB (تمام اطلاعات پاک می‌شود)"
            "USB drive" = "حافظه USB"
            "Refresh" = "تازه‌سازی"
            "Erase &amp; Write to USB" = "پاک‌کردن و نوشتن روی USB"
            "Done with this image? Clear the temporary files and start again from step 1." = "کار با این تصویر تمام شد؟ فایل‌های موقت را پاک کنید و از مرحله اول شروع کنید."
            "Start Over" = "شروع دوباره"
            "Delete the temporary working directory and go back to the first step" = "حذف پوشه موقت کاری و بازگشت به مرحله اول"
            "Working..." = "در حال انجام..."
            "This can take several minutes. Progress is written to the status log." = "این عملیات ممکن است چند دقیقه طول بکشد. روند اجرا در گزارش وضعیت ثبت می‌شود."
            "Status Log" = "گزارش وضعیت"
            "Ready. Please select a Windows 11 ISO to begin." = "آماده. برای شروع، یک فایل ISO ویندوز ۱۱ انتخاب کنید."
            "AppX" = "برنامه‌های سیستمی"
            "Selections:" = "انتخاب‌ها:"
            " Default " = " پیش‌فرض "
            " Select Installed " = " انتخاب موارد نصب‌شده "
            " Select All " = " انتخاب همه "
            " Clear Selection " = "پاک‌کردن انتخاب‌ها"
            "Back to Tweaks" = "بازگشت به بهینه‌سازی‌ها"
            "Install Selected" = "نصب موارد انتخاب‌شده"
            "Remove Selected" = "حذف موارد انتخاب‌شده"
            "Optimization" = "بهینه‌سازی سیستم"
            "Windows Optimization Center" = "مرکز بهینه‌سازی ویندوز"
            "Read-only diagnostics are separated from repair and settings changes. Every system-changing action requires confirmation." = "گزارش‌های فقط‌خواندنی از تعمیرات و تغییر تنظیمات جدا هستند. هر عملیاتی که سیستم را تغییر دهد به تأیید شما نیاز دارد."
            "Startup Manager" = "مدیریت برنامه‌های شروع به کار"
            "Inspect Run/RunOnce registry entries and Startup folders. This report does not disable entries." = "بررسی ورودی‌های Run و RunOnce رجیستری و پوشه‌های Startup. این گزارش هیچ موردی را غیرفعال نمی‌کند."
            "Refresh startup list" = "تازه‌سازی فهرست شروع به کار"
            "Resource Snapshot" = "نمای کلی منابع سیستم"
            "Read current CPU load, RAM use, local disk capacity and the top memory-consuming processes." = "بار پردازنده، میزان استفاده از RAM، ظرفیت دیسک محلی و پردازش‌های پرمصرف حافظه را بررسی می‌کند."
            "Collect system snapshot" = "جمع‌آوری وضعیت سیستم"
            "Network Diagnostics" = "عیب‌یابی شبکه"
            "Inspect adapters, IP configuration, DNS resolution and basic connectivity checks." = "بررسی کارت‌های شبکه، پیکربندی IP، تبدیل نام DNS و اتصال پایه شبکه."
            "Run network checks" = "اجرای بررسی‌های شبکه"
            "Windows Repair" = "تعمیر ویندوز"
            "DISM and SFC can take several minutes. Run only the repair you intend to use." = "اجرای DISM و SFC ممکن است چند دقیقه طول بکشد. فقط ابزار تعمیر موردنظر خود را اجرا کنید."
            "DISM CheckHealth" = "بررسی سلامت با DISM"
            "DISM ScanHealth" = "اسکن سلامت با DISM"
            "DISM RestoreHealth" = "ترمیم سلامت با DISM"
            "SFC /scannow" = "بررسی و ترمیم فایل‌های سیستم (SFC)"
            "Requires Administrator privileges. RestoreHealth and SFC may modify Windows system files." = "به دسترسی مدیر نیاز دارد. RestoreHealth و SFC ممکن است فایل‌های سیستمی ویندوز را تغییر دهند."
            "Windows Experience" = "تنظیمات تجربه کاربری ویندوز"
            "Adjust a small set of Explorer and recommendation preferences. A JSON backup is saved before applying changes." = "تعدادی از تنظیمات Explorer و پیشنهادها را تغییر می‌دهد. پیش از اعمال تغییرات، نسخه پشتیبان JSON ذخیره می‌شود."
            "Setting" = "تنظیم"
            "Explorer: Recent and frequent items" = "Explorer: موارد اخیر و پرتکرار"
            "Explorer: Open This PC" = "Explorer: بازکردن This PC"
            "Privacy: Advertising ID" = "حریم خصوصی: شناسه تبلیغاتی"
            "Start: Consumer suggestions" = "منوی شروع: پیشنهادهای مصرف‌کننده"
            "State" = "وضعیت"
            "Disable / turn off" = "غیرفعال / خاموش"
            "Enable / turn on" = "فعال / روشن"
            "Preview only (do not change registry)" = "فقط پیش‌نمایش (بدون تغییر رجیستری)"
            "Backup file (filled automatically after applying)" = "فایل پشتیبان (پس از اعمال به‌صورت خودکار تکمیل می‌شود)"
            "Apply setting" = "اعمال تنظیم"
            "Browse backup..." = "انتخاب فایل پشتیبان..."
            "Restore backup" = "بازیابی پشتیبان"
            "Network Repair" = "تعمیر شبکه"
            "These actions change local network state. Winsock and TCP/IP resets may require a restart and can affect custom network settings." = "این عملیات وضعیت شبکه محلی را تغییر می‌دهند. بازنشانی Winsock و TCP/IP ممکن است به راه‌اندازی مجدد نیاز داشته باشد و بر تنظیمات سفارشی شبکه اثر بگذارد."
            "Flush DNS cache" = "پاک‌کردن حافظه موقت DNS"
            "Reset Winsock" = "بازنشانی Winsock"
            "Reset TCP/IP" = "بازنشانی TCP/IP"
            "Requires Administrator privileges. No network adapter or DNS server settings are changed by these reset commands." = "به دسترسی مدیر نیاز دارد. این دستورات تنظیمات کارت شبکه یا سرور DNS را تغییر نمی‌دهند."
            "Operation Status" = "وضعیت عملیات"
            "Ready. Choose a diagnostic or maintenance action." = "آماده. یک عملیات عیب‌یابی یا نگهداری انتخاب کنید."
            "Report / result" = "گزارش / نتیجه"
            "Reports and operation results will appear here." = "گزارش‌ها و نتایج عملیات در این قسمت نمایش داده می‌شوند."
            "Essential Tweaks" = "بهینه‌سازی‌های ضروری"
            "Miscellaneous Tweaks" = "بهینه‌سازی‌های متفرقه"
            "Advanced Tweaks - CAUTION" = "بهینه‌سازی‌های پیشرفته - با احتیاط"
            "Features" = "قابلیت‌ها"
            "Fixes" = "رفع مشکلات"
            "Legacy Windows Panels" = "ابزارهای قدیمی ویندوز"
            "Browsers & Internet" = "مرورگرها و اینترنت"
            "Utilities & Productivity" = "ابزارهای کاربردی و بهره‌وری"
            "Xbox & Gaming" = "Xbox و بازی"
            "Mount & Verify ISO" = "اتصال و بررسی ISO"
            "Erase & Write to USB" = "پاک‌کردن و نوشتن روی USB"
            "Windows repair tools will inspect or repair system files. This can take several minutes. Continue?" = "ابزارهای تعمیر ویندوز فایل‌های سیستمی را بررسی یا تعمیر می‌کنند. این کار ممکن است چند دقیقه طول بکشد. ادامه می‌دهید؟"
            "Restore Windows experience registry values from the selected backup file?" = "مقادیر رجیستری تنظیمات تجربه ویندوز از فایل پشتیبان انتخاب‌شده بازیابی شوند؟"
            "Clear the local DNS resolver cache?" = "حافظه موقت محلی DNS پاک شود؟"
            "Reset the Winsock catalog? Some network applications may need restarting." = "فهرست Winsock بازنشانی شود؟ ممکن است لازم باشد برخی برنامه‌های شبکه را دوباره اجرا کنید."
            "Reset TCP/IP settings? A restart may be required and custom network settings may be affected." = "تنظیمات TCP/IP بازنشانی شوند؟ ممکن است راه‌اندازی مجدد لازم باشد و تنظیمات سفارشی شبکه تحت تأثیر قرار بگیرند."
            "MOBOROTS Optimization - Confirm" = "بهینه‌سازی MOBOROTS - تأیید"
            "Bing & Web Services" = "Bing و سرویس‌های وب"
        }
    }

    if ($script:WinUtilPersianText.ContainsKey($Text)) {
        return $script:WinUtilPersianText[$Text]
    }
    return $Text
}

function Initialize-WinUtilLocalization {
    [CmdletBinding()]
    param([switch]$Force)

    if (-not $sync.Form) { return }

    # Persian is the default UI language. Keep command names, app/product names and identifiers intact.
    $sync.Form.FlowDirection = [System.Windows.FlowDirection]::RightToLeft
    $sync.Form.Language = [System.Windows.Markup.XmlLanguage]::GetLanguage("fa-IR")
    $sync.Form.FontFamily = New-Object System.Windows.Media.FontFamily("Tahoma")

    $visit = [System.Collections.Generic.Stack[object]]::new()
    $visit.Push($sync.Form)
    while ($visit.Count -gt 0) {
        $node = $visit.Pop()
        if ($null -eq $node) { continue }

        if ($node -is [System.Windows.Controls.TextBlock]) {
            $localized = Get-WinUtilLocalizedText -Text $node.Text
            if ($localized -ne $node.Text) { $node.Text = $localized }
            $node.FlowDirection = [System.Windows.FlowDirection]::RightToLeft
            $node.TextAlignment = [System.Windows.TextAlignment]::Right
            $node.FontFamily = $sync.Form.FontFamily
        } elseif ($node -is [System.Windows.Controls.ContentControl] -and $node.Content -is [string]) {
            $localized = Get-WinUtilLocalizedText -Text $node.Content
            if ($localized -ne $node.Content) { $node.Content = $localized }
            $node.FlowDirection = [System.Windows.FlowDirection]::RightToLeft
            $node.FontFamily = $sync.Form.FontFamily
        } elseif ($node -is [System.Windows.Controls.Control]) {
            $node.FlowDirection = [System.Windows.FlowDirection]::RightToLeft
            $node.FontFamily = $sync.Form.FontFamily
        }

        foreach ($child in [System.Windows.LogicalTreeHelper]::GetChildren($node)) {
            if ($null -ne $child -and $child -isnot [string]) { $visit.Push($child) }
        }
    }

    # Localize dynamic category names that are used as group headers.
    foreach ($configName in @("tweaks", "feature", "appx")) {
        $config = $sync.configs[$configName]
        if ($null -eq $config) { continue }
        foreach ($item in $config.PSObject.Properties) {
            if ($item.Value.category) {
                $item.Value.category = Get-WinUtilLocalizedText -Text ([string]$item.Value.category)
            }
            if ($item.Value.Category) {
                $item.Value.Category = Get-WinUtilLocalizedText -Text ([string]$item.Value.Category)
            }
        }
    }
}
