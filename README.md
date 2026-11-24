# ADVANCED WINDOWS CLEANUP TOOL

Developed by: Nishan Dhakal

---

## Overview

A portable, native Windows CMD cleanup tool that scans and removes common Windows and browser junk files to free disk space and reduce clutter—with a clean color dashboard, Preview mode, and optional one-time Administrator elevation.

- **Website:** https://clean.dhakalnishan.com.np/
- **Repository:** https://github.com/nishan023/pc-cleaner-bat

## Quick Run (PowerShell)

Open **PowerShell as Administrator** and run:

```powershell
irm https://get.dhakalnishan.com.np/clean | iex
```

*(Both `/clean` and `/cleanup` work.)*

## Download

### Latest Version (v2.0.0)
- [![Download Advanced_Windows_Cleanup_v2.0.0.bat](https://img.shields.io/badge/Download-v2.0.0%20(.bat)-00C853?style=for-the-badge&logo=windows)](https://github.com/nishan023/pc-cleaner-bat/releases/download/v2.0.0/Advanced_Windows_Cleanup_v2.0.0.bat)
- Direct download: https://github.com/nishan023/pc-cleaner-bat/releases/download/v2.0.0/Advanced_Windows_Cleanup_v2.0.0.bat

### Previous Version (v1.0.0)
- [![Download CleanCDrive.bat](https://img.shields.io/badge/Download-v1.0.0%20(CleanCDrive.bat)-52524E?style=for-the-badge&logo=windows)](https://github.com/nishan023/pc-cleaner-bat/releases/download/v1.0.0/CleanCDrive.bat)
- Direct download: https://github.com/nishan023/pc-cleaner-bat/releases/download/v1.0.0/CleanCDrive.bat

- **All releases:** https://github.com/nishan023/pc-cleaner-bat/releases

## What It Cleans

1. User Temp Files
2. Windows Temp Files *(admin)*
3. Windows Update Cache *(admin)*
4. DNS Cache
5. Thumbnail Cache
6. Windows Error Reports
7. Browser Cache (Chrome + Edge)
8. Windows.old Folder *(protected)*
9. Disk Cleanup *(built-in, manual review)*

## Run Modes & Options

- `A` = **Automatic** — clean eligible files; request optional admin access once
- `M` = **Manual** — confirm individual cleanup tasks in CMD
- `P` = **Preview** — scan without deleting target files
- `Q` = **Quit** — close this tool

Optional command-line flags for `Advanced_Windows_Cleanup_v2.0.0.bat`:
- `--plain` — disable ANSI colors
- `--static` — keep colors, disable animations
- `--color` — force Virtual Terminal colors

## Usage

Double-click `Advanced_Windows_Cleanup_v2.0.0.bat` (or run it from Windows Terminal / Command Prompt) and choose a mode:

```text
Enter your choice (A/M/P/Q):
```

## Notes

- **Native CMD only:** No PowerShell, external downloads, policy changes, or permission bypasses.
- **Optional elevation:** Standard user mode works out of the box; one-time UAC elevation can be requested for system temp, Windows Update cache, and system error reports.
- **Preview first:** Use `P` to inspect what will be cleaned before deleting anything. Locked or protected files are retained.
- **Logs:** Saved under `%LOCALAPPDATA%\AdvancedWindowsCleanup\Logs`.

## Releases

- **v2.0.0** — Redesigned Windows Terminal color dashboard, Preview mode (`P`), optional one-time UAC elevation, CLI display flags (`--plain`, `--static`, `--color`), and local logging.
- **v1.0.0** — Initial release (`CleanCDrive.bat`).
