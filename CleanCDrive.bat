@echo off
title Advanced Windows Cleanup Tool
color 0A

:: ============================================================
::   Developed by: Nishan Dhakal
:: ============================================================

:: ============================================================
::   ADMIN CHECK - Auto re-launch as Administrator if needed
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ============================================================
::   WELCOME SCREEN
:: ============================================================
cls
echo ================================================================
echo         ADVANCED WINDOWS CLEANUP TOOL
echo         Developed by: Nishan Dhakal
echo ================================================================
echo.
echo  This tool will clean the following:
echo    [1]  User Temp Files
echo    [2]  Windows Temp Files
echo    [3]  Windows Update Cache
echo    [4]  DNS Cache
echo    [5]  Thumbnail Cache
echo    [6]  Windows Error Reports
echo    [7]  Browser Cache (Chrome + Edge)
echo    [8]  Windows.old Folder
echo    [9]  Disk Cleanup (built-in)
echo.
echo ================================================================
echo  OPTIONS:
echo    A = Run ALL steps automatically without asking
echo    M = Run in MANUAL mode (confirm each step)
echo ================================================================
echo.
set /p RUNMODE="  Enter your choice (A or M): "
echo.

:: Normalize input to uppercase
if /i "%RUNMODE%"=="A" set RUNMODE=A
if /i "%RUNMODE%"=="M" set RUNMODE=M

if not "%RUNMODE%"=="A" if not "%RUNMODE%"=="M" (
    echo  Invalid choice. Please restart and enter A or M.
    pause
    exit /b
)

:: ============================================================
::   DISK SPACE BEFORE CLEANUP
:: ============================================================
for /f "tokens=3" %%a in ('dir C:\ /-c ^| findstr /i "bytes free"') do set BEFORE=%%a
echo  [INFO] Free disk space BEFORE cleanup: %BEFORE% bytes
echo.

:: ============================================================
::   HELPER: Ask user in Manual mode
::   Usage: call :AskUser "Question text"
::   Sets SKIP=1 if user wants to skip, SKIP=0 to proceed
:: ============================================================
goto :StartCleanup

:AskUser
if "%RUNMODE%"=="A" (
    set SKIP=0
    exit /b
)
echo.
echo  -----------------------------------------
echo  STEP: %~1
echo  -----------------------------------------
set /p ANSWER="  Proceed with this step? (Y/N): "
if /i "%ANSWER%"=="Y" (set SKIP=0) else (set SKIP=1)
exit /b

:: ============================================================
::   CLEANUP STEPS
:: ============================================================
:StartCleanup

:: ---- STEP 1: USER TEMP FILES ----
call :AskUser "Clean User Temp Files (%TEMP%)"
if "%SKIP%"=="1" (
    echo  [1/9] Skipped - User Temp Files.
) else (
    echo  [1/9] Cleaning User Temp Files...
    del /s /f /q "%temp%\*" >nul 2>&1
    rd /s /q "%temp%" >nul 2>&1
    mkdir "%temp%" >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 2: WINDOWS TEMP ----
call :AskUser "Clean Windows Temp Files (C:\Windows\Temp)"
if "%SKIP%"=="1" (
    echo  [2/9] Skipped - Windows Temp Files.
) else (
    echo  [2/9] Cleaning Windows Temp Files...
    del /s /f /q "C:\Windows\Temp\*" >nul 2>&1
    rd /s /q "C:\Windows\Temp" >nul 2>&1
    mkdir "C:\Windows\Temp" >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 3: WINDOWS UPDATE CACHE ----
call :AskUser "Clean Windows Update Cache (SoftwareDistribution\Download)"
if "%SKIP%"=="1" (
    echo  [3/9] Skipped - Windows Update Cache.
) else (
    echo  [3/9] Cleaning Windows Update Cache...
    net stop wuauserv >nul 2>&1
    net stop bits >nul 2>&1
    del /s /f /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
    net start wuauserv >nul 2>&1
    net start bits >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 4: DNS CACHE ----
call :AskUser "Flush DNS Cache"
if "%SKIP%"=="1" (
    echo  [4/9] Skipped - DNS Cache.
) else (
    echo  [4/9] Flushing DNS Cache...
    ipconfig /flushdns >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 5: THUMBNAIL CACHE ----
call :AskUser "Clean Thumbnail Cache (File Explorer thumbnails)"
if "%SKIP%"=="1" (
    echo  [5/9] Skipped - Thumbnail Cache.
) else (
    echo  [5/9] Cleaning Thumbnail Cache...
    del /s /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*" >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 6: WINDOWS ERROR REPORTS ----
call :AskUser "Clean Windows Error Reports (crash logs)"
if "%SKIP%"=="1" (
    echo  [6/9] Skipped - Windows Error Reports.
) else (
    echo  [6/9] Cleaning Windows Error Reports...
    del /s /f /q "%LocalAppData%\Microsoft\Windows\WER\*" >nul 2>&1
    del /s /f /q "C:\ProgramData\Microsoft\Windows\WER\*" >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 7: BROWSER CACHE ----
call :AskUser "Clean Browser Caches (Chrome + Edge)"
if "%SKIP%"=="1" (
    echo  [7/9] Skipped - Browser Cache.
) else (
    echo  [7/9] Cleaning Browser Caches...
    del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
    del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
    echo         Done.
)
echo.

:: ---- STEP 8: WINDOWS.OLD ----
call :AskUser "Remove Windows.old folder (old Windows upgrade files - up to 20GB)"
if "%SKIP%"=="1" (
    echo  [8/9] Skipped - Windows.old folder.
) else (
    echo  [8/9] Checking for Windows.old folder...
    if exist "C:\Windows.old" (
        rd /s /q "C:\Windows.old" >nul 2>&1
        echo         Windows.old removed successfully.
    ) else (
        echo         Windows.old not found. Nothing to remove.
    )
)
echo.

:: ---- STEP 9: DISK CLEANUP ----
call :AskUser "Run Windows Disk Cleanup (built-in cleanmgr tool)"
if "%SKIP%"=="1" (
    echo  [9/9] Skipped - Disk Cleanup.
) else (
    echo  [9/9] Running Windows Disk Cleanup...
    cleanmgr /sagerun:1 >nul 2>&1
    echo         Done.
)
echo.

:: ============================================================
::   DISK SPACE AFTER CLEANUP
:: ============================================================
for /f "tokens=3" %%a in ('dir C:\ /-c ^| findstr /i "bytes free"') do set AFTER=%%a
echo ================================================================
echo  [INFO] Free disk space BEFORE cleanup: %BEFORE% bytes
echo  [INFO] Free disk space AFTER  cleanup: %AFTER% bytes
echo ================================================================

:: ============================================================
::   SAVE LOG TO DESKTOP
:: ============================================================
set LOGFILE="%USERPROFILE%\Desktop\CleanupLog_%date:~-4,4%%date:~-7,2%%date:~0,2%_%time:~0,2%%time:~3,2%.txt"
(
    echo ================================
    echo  WINDOWS CLEANUP LOG
    echo ================================
    echo  Date/Time  : %date% %time%
    echo  Mode Used  : %RUNMODE%
    echo  Before     : %BEFORE% bytes free
    echo  After      : %AFTER% bytes free
    echo ================================
) > %LOGFILE%

echo.
echo  Log saved to Desktop: CleanupLog_[timestamp].txt
echo.
echo ================================================================
echo              CLEANUP COMPLETED SUCCESSFULLY!
echo ================================================================
pause
