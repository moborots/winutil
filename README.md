# Moborots WinUtil

**A bilingual Windows utility toolkit based on [Chris Titus Tech's WinUtil](https://github.com/ChrisTitusTech/winutil), customized and extended by Moborots.**

**ابزار دوزبانه مدیریت و بهینه‌سازی ویندوز** بر پایه پروژه Chris Titus Tech که توسط Moborots شخصی‌سازی و توسعه داده می‌شود.

<p align="center">
  <a href="https://github.com/moborots/winutil"><img alt="GitHub repository" src="https://img.shields.io/badge/GitHub-Moborots%2FWinUtil-181717?logo=github"></a>
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D4?logo=windows">
  <img alt="PowerShell" src="https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell">
  <img alt="Status" src="https://img.shields.io/badge/Status-Development-orange">
</p>

---

## Quick Start | شروع سریع

> [!WARNING]
> **Administrator privileges are required.** WinUtil changes Windows settings and may install or remove system components. Review every selection before applying it.
>
> **اجرای برنامه با دسترسی Administrator ضروری است.** این ابزار تنظیمات ویندوز را تغییر می‌دهد و ممکن است اجزای سیستمی را نصب یا حذف کند. پیش از اعمال هر تغییر، گزینه‌ها را بررسی کنید.

### 1. Requirements | پیش‌نیازها

**English**
- Windows 10 or Windows 11.
- PowerShell and an internet connection.
- [Git for Windows](https://git-scm.com/download/win) to clone and update the repository.
- Administrator access.
- Create a restore point or back up important data before applying system tweaks.

**فارسی**
- ویندوز ۱۰ یا ویندوز ۱۱.
- PowerShell و اتصال اینترنت.
- نصب [Git for Windows](https://git-scm.com/download/win) برای دریافت و به‌روزرسانی مخزن.
- دسترسی Administrator.
- قبل از اعمال تغییرات سیستمی، نقطه بازیابی (Restore Point) بسازید و از اطلاعات مهم پشتیبان بگیرید.

### 2. Stable Branch (recommended) | نسخه پایدار (پیشنهادی)

**English:** Open **PowerShell / Windows Terminal as Administrator**, then run:

**فارسی:** ابتدا PowerShell یا Windows Terminal را با گزینه **Run as administrator** باز کنید و دستورات زیر را اجرا کنید:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
Set-Location $HOME
git clone -b main https://github.com/moborots/winutil.git
Set-Location .\winutil
.\Compile.ps1
.\Compile.ps1 -Run
```

### 3. Preview / Development Branch | نسخه آزمایشی و توسعه

> [!CAUTION]
> This branch may contain unfinished features. Use it for testing, not as your primary system-maintenance tool.
>
> این شاخه ممکن است قابلیت‌های تکمیل‌نشده داشته باشد. از آن برای آزمایش استفاده کنید، نه به‌عنوان نسخه اصلی نگهداری سیستم.

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
Set-Location $HOME
git clone -b feature/windows-11-appearance https://github.com/moborots/winutil.git winutil-preview
Set-Location .\winutil-preview
.\Compile.ps1
.\Compile.ps1 -Run
```

### 4. Update an existing copy | به‌روزرسانی نسخه دریافت‌شده

**Stable | پایدار**
```powershell
Set-Location "$HOME\winutil"
git switch main
git pull --ff-only origin main
.\Compile.ps1
.\Compile.ps1 -Run
```

**Preview | آزمایشی**
```powershell
Set-Location "$HOME\winutil-preview"
git switch feature/windows-11-appearance
git pull --ff-only origin feature/windows-11-appearance
.\Compile.ps1
.\Compile.ps1 -Run
```

### 5. Open an Administrator terminal | باز کردن ترمینال با دسترسی ادمین

- **Start menu | منوی استارت:** Right-click Start → **Terminal (Admin)**.
- **Search | جست‌وجو:** Press the Windows key, search for PowerShell or Terminal, then press **Ctrl + Shift + Enter**.
- **فارسی:** روی Start راست‌کلیک کنید و Windows Terminal (Admin) را انتخاب کنید؛ یا در جست‌وجوی ویندوز PowerShell را پیدا کرده و با Ctrl + Shift + Enter اجرا کنید.

---

## Features | امکانات

| Feature | توضیحات فارسی |
|---|---|
| **Application Installer** | نصب و مدیریت نرم‌افزارهای منتخب ویندوز |
| **Windows Tweaks** | تنظیمات و بهینه‌سازی‌های ویندوز |
| **Configuration** | ابزارهای پیکربندی و مدیریت بخش‌های مختلف سیستم |
| **Windows Updates** | مدیریت تنظیمات به‌روزرسانی ویندوز |
| **Windows 11 ISO** | ابزارهای مرتبط با دریافت و آماده‌سازی ISO ویندوز ۱۱ |
| **Appearance (Preview)** | شخصی‌سازی ظاهر ویندوز ۱۱؛ شامل تم، رنگ تأکیدی، شفافیت و نوار وظیفه |
| **System Tools (Preview)** | شناسایی نسخه ویندوز و نمایش نام، حجم، تاریخ تغییر و ویژگی فایل‌های `C:\\Windows\\System32\\config` بدون خواندن محتوای Hiveهای رجیستری |
| **Start Menu Manager (Preview)** | باز کردن تنظیمات رسمی Start برای مدیریت پیشنهادها، برنامه‌های اخیر و چیدمان منو |
| **Taskbar Manager (Preview)** | دسترسی سریع به تنظیمات رسمی نوار وظیفه ویندوز |
| **Mouse & Cursor Manager (Preview)** | باز کردن تنظیمات دسترس‌پذیری نشانگر و پنجره کلاسیک Mouse Properties برای تغییر طرح نشانگر |
| **Windows Edition Manager (Preview)** | نمایش نسخه نصب‌شده، پرس‌وجوی Editionهای مقصد پشتیبانی‌شده با DISM و باز کردن Activation Settings؛ ارتقا فقط با مجوز معتبر و از مسیر رسمی ویندوز |

| **Backup & Restore (Appearance)** | تهیه نسخه پشتیبان و بازگردانی تنظیمات ظاهری پشتیبانی‌شده |
| **Diagnostics Export** | خروجی گرفتن از گزارش تشخیصی سیستم برای عیب‌یابی |
| **Import / Export** | وارد کردن و خروجی گرفتن از تنظیمات پشتیبانی‌شده |

> **Note | توجه:** Appearance and System Tools (including Start, Taskbar, Cursor, and Edition shortcuts) are currently available on the `feature/windows-11-appearance` preview branch. System Tools only lists file metadata in `C:\\Windows\\System32\\config`; it never reads or modifies registry hive contents. These features are not included in `main` until reviewed and merged.
>
> قابلیت‌های Appearance، System Tools، میان‌برهای Start و Taskbar، تنظیمات Cursor و بررسی مسیر ارتقای Edition فعلاً در شاخه آزمایشی `feature/windows-11-appearance` قرار دارند. بخش System Tools فقط مشخصات فایل‌ها را نشان می‌دهد و محتوای Hiveهای رجیستری را نمی‌خواند یا تغییر نمی‌دهد.

---

## Troubleshooting | رفع مشکلات رایج

**The script does not run | اسکریپت اجرا نمی‌شود**
- Make sure PowerShell is running as Administrator.
- Run: `Set-ExecutionPolicy -Scope Process Bypass -Force`
- مطمئن شوید ترمینال را با دسترسی Administrator باز کرده‌اید.

**Git is not recognized | دستور Git شناخته نمی‌شود**
- Install Git for Windows, close the terminal, open it again, and run `git --version`.
- Git for Windows را نصب کنید، ترمینال را ببندید و دوباره باز کنید.

**The folder already exists | پوشه از قبل وجود دارد**
- Do not clone into the same folder again. Open the existing folder and use the update commands above.
- اگر پوشه وجود دارد، دوباره Clone نکنید؛ وارد همان پوشه شوید و دستورات به‌روزرسانی را اجرا کنید.

**The application does not open | برنامه باز نمی‌شود**
- Run `git status` and `git branch --show-current` to check the repository and branch.
- Retry `.\Compile.ps1` and review any error shown in the terminal.
- شاخه فعال و خطاهای نمایش‌داده‌شده در ترمینال را بررسی کنید.

---

## Safety & Recovery | امنیت و بازگردانی

**English**
- Read the description of each tweak before applying it.
- Avoid applying multiple unknown tweaks at once.
- Back up important files and create a Windows restore point first.
- Some changes require signing out or restarting Windows to take effect.
- This project is provided as-is; test preview features carefully.

**فارسی**
- توضیحات هر تغییر را پیش از اجرا بخوانید.
- چند تنظیم ناشناخته را هم‌زمان اعمال نکنید.
- از فایل‌های مهم پشتیبان بگیرید و Restore Point ایجاد کنید.
- بعضی تغییرات برای اعمال شدن به خروج از حساب کاربری یا راه‌اندازی مجدد ویندوز نیاز دارند.
- مسئولیت بررسی و انتخاب تغییرات بر عهده کاربر است؛ قابلیت‌های آزمایشی را با احتیاط تست کنید.

---

## Development | توسعه پروژه

- **Repository:** https://github.com/moborots/winutil
- **Preview branch:** https://github.com/moborots/winutil/tree/feature/windows-11-appearance
- **Appearance guide:** [Windows 11 Appearance](https://github.com/moborots/winutil/blob/feature/windows-11-appearance/docs/src/content/docs/guides/windows-11-appearance.mdx)
- **Report a bug / گزارش خطا:** [GitHub Issues](https://github.com/moborots/winutil/issues)

Contributions, bug reports, and suggestions are welcome.  
از پیشنهادها، گزارش خطا و مشارکت در توسعه پروژه استقبال می‌کنیم.

---

## Credits | سپاس‌گزاری

Moborots WinUtil is based on the open-source work of [Chris Titus Tech WinUtil](https://github.com/ChrisTitusTech/winutil). Original project authors and contributors retain credit for their work. Moborots-specific changes are maintained in this repository.

این پروژه بر پایه کار متن‌باز [Chris Titus Tech WinUtil](https://github.com/ChrisTitusTech/winutil) توسعه یافته است. اعتبار سازندگان و مشارکت‌کنندگان پروژه اصلی محفوظ است و تغییرات اختصاصی Moborots در این مخزن نگهداری می‌شود.
