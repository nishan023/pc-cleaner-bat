@echo off
setlocal EnableExtensions DisableDelayedExpansion
if /i "%~1"=="--worker" goto :Worker
if /i "%~1"=="--plain" goto :LaunchPlain
if /i "%~1"=="--color" goto :LaunchColor
if /i "%~1"=="--static" goto :LaunchStatic
"%ComSpec%" /d /c ""%~f0" --worker"
goto :WorkerResult
:LaunchPlain
"%ComSpec%" /d /c ""%~f0" --worker --plain"
goto :WorkerResult
:LaunchColor
"%ComSpec%" /d /c ""%~f0" --worker --color"
goto :WorkerResult
:LaunchStatic
"%ComSpec%" /d /c ""%~f0" --worker --static"
:WorkerResult
set "WORKERR=%errorlevel%"
if defined WT_SESSION <nul set /p "=[?25h"
if "%WORKERR%"=="0" exit /b 0
echo(
echo(  [ERROR] Cleanup tool exited with code %WORKERR%.
echo(  The console is kept open so you can read the error above.
pause
exit /b %WORKERR%
rem ============================================================================
rem  Advanced Windows Cleanup Tool v2.1.0 - clean color dashboard
rem  Options:  --plain (no colors)   --static (colors, no animation)   --color
rem  Native CMD only. Optional one-time UAC request via built-in cscript.
rem  No PowerShell, downloads, policy changes or permission bypass.
rem ============================================================================
:Worker
title Advanced Windows Cleanup Tool v2.1.0
color 07
set "VERSION=v2.0.0"
set "VT=0"
set "ANIM=1"
set "FR=0"
if defined WT_SESSION set "VT=1"
if defined ANSICON set "VT=1"
if /i "%ConEmuANSI%"=="ON" set "VT=1"
if "%VT%"=="0" for /f "tokens=3" %%V in ('reg query HKCU\Console /v VirtualTerminalLevel 2^>nul ^| findstr /i "VirtualTerminalLevel"') do if /i "%%V"=="0x1" set "VT=1"
if "%VT%"=="0" for /f "tokens=6 delims=. " %%B in ('ver') do set "WINBUILD=%%B"
if defined WINBUILD set /a "WINBUILD=WINBUILD" 2>nul
if defined WINBUILD if %WINBUILD% geq 22000 set "VT=1"
if /i "%~2"=="--color" set "VT=1"
if /i "%~2"=="--plain" set "VT=0"
if /i "%~2"=="--static" set "ANIM=0"
rem Use UTF-8 for console display (box characters) on modern Windows.
for /f "tokens=2 delims=:" %%G in ('chcp') do set "OLDCP=%%G"
chcp 65001 >nul 2>&1
if errorlevel 1 (
    set "VT=0"
)
if "%VT%"=="0" set "ANIM=0"
set "RS="
set "CY="
set "GR="
set "YL="
set "MG="
set "RD="
set "GY="
set "WH="
set "BL="
set "OR="
set "VI="
set "PK="
set "LM="
set "SK="
set "GD="
set "DM="
set "TL="
set "TRK="
set "FULL30="
set "SHD30="
set "SPN="
set "STC="
if "%VT%"=="0" color 0B
if "%VT%"=="0" goto :ColorsDone
set "ESC="
set "RS=[0m"
set "CY=[38;5;80m"
set "GR=[38;5;40m"
set "YL=[38;5;229m"
set "MG=[38;5;127m"
set "RD=[38;5;203m"
set "GY=[38;5;243m"
set "WH=[38;5;255m"
set "BL=[38;5;69m"
set "OR=[38;5;229m"
set "VI=[38;5;127m"
set "PK=[38;5;255m"
set "LM=[38;5;40m"
set "SK=[38;5;80m"
set "GD=[38;5;229m"
set "DM=[38;5;243m"
set "TL=[38;5;80m"
set "STC=[38;5;80m"
set "FULL30=██████████████████████████████"
set "SHD30=░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
set "SPN=⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
:ColorsDone
set "SYS=%SystemDrive%"
set "WIN=%SystemRoot%"
set "LOCAL=%LOCALAPPDATA%"
if not defined SYS goto :BadEnvironment
if not defined WIN goto :BadEnvironment
if not defined LOCAL goto :BadEnvironment
if not "%SYS:~1%"==":" goto :BadEnvironment
set "BIN=%WIN%\System32"
set "ADMIN=0"
set "ASKED=0"
set "ACCESS=Standard user"
set "ACCESSCOLOR=%YL%"
"%BIN%\fltmc.exe" >nul 2>&1
if errorlevel 1 goto :AccessChecked
set "ADMIN=1"
set "ASKED=1"
set "ACCESS=Administrator"
set "ACCESSCOLOR=%GR%"
:AccessChecked
set "ACCESSWORD=NO "
if "%ADMIN%"=="1" set "ACCESSWORD=YES"
set "RESUME="
if /i "%~2"=="--elevated-A" set "RESUME=A"
if /i "%~2"=="--elevated-M" set "RESUME=M"
if not defined RESUME goto :IdentityReady
set "ASKED=1"
if "%ADMIN%"=="0" goto :ElevationNotGranted
set "EXPECTEDSID=%~4"
call :ReadSid
if not defined ACCOUNTSID goto :ElevationNotGranted
if /i not "%ACCOUNTSID%"=="%EXPECTEDSID%" goto :OtherAccount
set "TOKEN=%~3"
if not defined TOKEN goto :ElevationNotGranted
for /f "delims=0123456789_" %%T in ("%TOKEN%") do goto :ElevationNotGranted
:IdentityReady
set "NAME1=User Temp Files"
set "NAME2=Windows Temp Files"
set "NAME3=Windows Update Cache"
set "NAME4=DNS Cache"
set "NAME5=Thumbnail Cache"
set "NAME6=Windows Error Reports"
set "NAME7=Browser Cache (Chrome + Edge)"
set "NAME8=Windows.old Folder"
set "NAME9=Disk Cleanup (built-in)"
set "STATUSTXT=READY"
set "STATUSCLR=%GR%"
if not exist "%BIN%\robocopy.exe" goto :MissingTool
if not exist "%BIN%\choice.exe" goto :MissingTool
set "CHECKPATH=%LOCAL%"
call :SafePath
if errorlevel 1 goto :BadEnvironment
set "WORKROOT=%LOCAL%\AdvancedWindowsCleanup"
if not exist "%WORKROOT%\" md "%WORKROOT%" 2>nul
set "CHECKPATH=%WORKROOT%"
call :SafePath
if errorlevel 1 goto :BadEnvironment
if not exist "%WORKROOT%\" goto :BadEnvironment
set "LOGROOT=%WORKROOT%\Logs"
if not exist "%LOGROOT%\" md "%LOGROOT%" 2>nul
set "CHECKPATH=%LOGROOT%"
call :SafePath
if errorlevel 1 goto :BadEnvironment
if not exist "%LOGROOT%\" goto :BadEnvironment
if not defined RESUME goto :BootReady
rem Acknowledge handoff only after checks, under the same local account.
set "ACK=%WORKROOT%\Elev_%TOKEN%.ok"
set "CHECKPATH=%ACK%"
call :SafePath
if errorlevel 1 goto :ElevationNotGranted
if exist "%ACK%" goto :ElevationNotGranted
>"%ACK%" echo READY
if errorlevel 1 goto :ElevationNotGranted
:BootReady
if not defined RESUME goto :Menu
set "RUNMODE=%RESUME%"
set "RESUME="
goto :Run

:Header
if "%VT%"=="0" goto :HeaderPlain
call :AnimHead
exit /b 0
:HeaderPlain
echo(%CY%+--------------------------------------------------------------------------------------------------+%RS%
echo(%CY%^|%RS%                             %CY%ADVANCED WINDOWS CLEANUP TOOL%RS%  /  %YL%v2.0.0%RS%                             %CY%^|%RS%
echo(%CY%^|%RS%                                   Developed by: Nishan Dhakal                                    %CY%^|%RS%
echo(%CY%+--------------------------------------------------------------------------------------------------+%RS%
exit /b 0
:AnimHead
rem Rows 1-6: header box, live status line, divider.
echo(%CY%┌──────────────────────────────────────────────────────────────────────────────────────────────────┐%RS%
echo(%CY%│%RS%                                  %CY%ADVANCED WINDOWS CLEANUP TOOL%RS%                         %CY%[v2.1.0]%RS%  %RS%%CY%│%RS%
echo(%CY%│%RS%                                   %WH%Developed by: Nishan Dhakal%RS%                                    %CY%│%RS%
echo(%CY%└──────────────────────────────────────────────────────────────────────────────────────────────────┘%RS%
call :BuildStatus
echo(%STLINE%
echo(%CY%────────────────────────────────────────────────────────────────────────────────────────────────────%RS%
exit /b 0
:BuildStatus
rem Builds STLINE (status row). FR selects the spinner frame.
setlocal EnableDelayedExpansion
set "SP=!SPN:~%FR%,1!"
set "STX=%WH%Admin: %ACCESSCOLOR%%ACCESSWORD%%RS%  %CY%│%RS%  %WH%Engine: %CY%CMD%RS%  %CY%│%RS%  %WH%Status: !STATUSCLR!%STATUSTXT% !SP!%RS%  %CY%│%RS%  %WH%Log: %GR%Enabled%RS%"
endlocal & set "STLINE=%STX%"
exit /b 0

:PromptDraw
set /a "BLK=FR%%2"
set "CUR=█"
if "%BLK%"=="1" set "CUR= "
<nul set /p "=%ESC%[2K%ESC%[1G%GR%>%RS% %CY%Enter your choice%RS% %GY%(%RS%%GR%A%RS%%GY%/%RS%%GR%M%RS%%GY%/%RS%%GR%P%RS%%GY%/%RS%%RD%Q%RS%%GY%)%RS%%WH%:%RS% %WH%%CUR%%RS%"
exit /b 0

:Tick
rem One animation frame: refresh only the status row (spinner) and the prompt cursor.
set /a "FR=(FR+1)%%10"
call :BuildStatus
<nul set /p "=%ESC%[21A%ESC%[2K%ESC%[1G%STLINE%%ESC%[21B"
call :PromptDraw
exit /b 0

:DrawMenu
call :AnimHead
echo(%CY%┌─ %CY%CLEANUP TARGETS%CY% ─────────────────────────────────────┐%RS% %CY%┌─ %CY%TOOL SUMMARY%CY% ─────────────────────────┐%RS%
echo(%CY%│%RS% %GR%[1]%RS% %WH%User Temp Files                    %GY%USER%RS%           %CY%│%RS% %CY%│%RS% %WH%Cleanup tasks  : %YL%9%RS%                     %CY%│%RS%
echo(%CY%│%RS% %GR%[2]%RS% %WH%Windows Temp Files                 %YL%ADMIN%RS%          %CY%│%RS% %CY%│%RS% %WH%Engine         : %GR%Native CMD%RS%            %CY%│%RS%
echo(%CY%│%RS% %GR%[3]%RS% %WH%Windows Update Cache               %YL%ADMIN%RS%          %CY%│%RS% %CY%│%RS% %WH%PowerShell     : %GR%Not required%RS%          %CY%│%RS%
echo(%CY%│%RS% %GR%[4]%RS% %WH%DNS Cache                          %GY%SYSTEM%RS%         %CY%│%RS% %CY%│%RS% %WH%Activity log   : %GR%Enabled%RS%               %CY%│%RS%
echo(%CY%│%RS% %GR%[5]%RS% %WH%Thumbnail Cache                    %GY%USER%RS%           %CY%│%RS% %CY%│%RS% %WH%Access         : %ACCESSCOLOR%%ACCESSLABEL%%RS%         %CY%│%RS%
echo(%CY%│%RS% %GR%[6]%RS% %WH%Windows Error Reports              %GY%MIXED%RS%          %CY%│%RS% %CY%└────────────────────────────────────────┘%RS%
echo(%CY%│%RS% %GR%[7]%RS% %WH%Browser Cache (Chrome + Edge)      %GY%USER%RS%           %CY%│%RS% %CY%┌─ %YL%RECOMMENDATION%CY% ───────────────────────┐%RS%
echo(%CY%│%RS% %RD%[8]%RS% %WH%Windows.old Folder                 %RD%PROTECTED%RS%      %CY%│%RS% %CY%│%WH% Close browsers before cleanup.%RS%         %CY%│%RS%
echo(%CY%│%RS% %GR%[9]%RS% %WH%Disk Cleanup (built-in)            %GY%MANUAL%RS%         %CY%│%RS% %CY%│%GY% Rollback files stay protected.%RS%         %CY%│%RS%
echo(%CY%└───────────────────────────────────────────────────────┘%RS% %CY%└────────────────────────────────────────┘%RS%
echo(
echo(%CY%┌─ %MG%RUN MODES%CY% ──────────────────────────────────────────────────────────────────────────────────────┐%RS%
echo(%CY%│%RS% %GR%[A]%RS% %WH%Automatic   %GY%Clean eligible files; optional admin access requested once.%RS%                      %CY%│%RS%
echo(%CY%│%RS% %GR%[M]%RS% %WH%Manual      %GY%Confirm every cleanup task one by one inside CMD.%RS%                                %CY%│%RS%
echo(%CY%│%RS% %GR%[P]%RS% %WH%Preview     %GY%Inspect candidate files safely; nothing is deleted.%RS%                              %CY%│%RS%
echo(%CY%│%RS% %RD%[Q]%RS% %WH%Exit        %GY%Close the application.%RS%                                                           %CY%│%RS%
echo(%CY%└──────────────────────────────────────────────────────────────────────────────────────────────────┘%RS%
echo(%YL%Tip: %GY%Preview first. Locked or protected files are always retained.%RS%
call :PromptDraw
exit /b 0

:Menu
set "ACCESSLABEL=Standard user"
if "%ADMIN%"=="1" set "ACCESSLABEL=Administrator"
set "STATUSTXT=READY"
set "STATUSCLR=%GR%"
set "FR=0"
cls
if "%VT%"=="0" goto :MenuPlain
call :DrawMenu
if "%ANIM%"=="0" goto :MenuStatic
<nul set /p "=%ESC%[?25l"
:MenuLoop
"%BIN%\choice.exe" /c AMPQT /n /t 1 /d T >nul
set "PICK=%errorlevel%"
if "%PICK%"=="5" call :Tick
if "%PICK%"=="5" goto :MenuLoop
<nul set /p "=%ESC%[?25h"
echo(
goto :MenuPicked
:MenuStatic
"%BIN%\choice.exe" /c AMPQ /n >nul
set "PICK=%errorlevel%"
echo(
goto :MenuPicked
:MenuPlain
call :Header
echo(  %ACCESSCOLOR%%ACCESS%%RS%  ^|  %CY%Native CMD%RS%  ^|  %GR%READY%RS%  ^|  %YL%Optional one-time elevation%RS%
echo(%CY%----------------------------------------------------------------------------------------------------%RS%
echo(  %CY%[i]%RS% Admin access is optional. Protected files require Windows permission.
echo(
echo(%GR%+-------------------------------------------------------+%RS%   %CY%+--------------------------------------+%RS%
echo(%GR%^|%RS% %GR%CLEANUP TARGETS%RS%                                       %GR%^|%RS%   %CY%^|%RS% %CY%TOOL SUMMARY%RS%                         %CY%^|%RS%
echo(%GR%+-------------------------------------------------------+%RS%   %CY%+--------------------------------------+%RS%
echo(%GR%^|%RS%  %GR%[1]%RS% User Temp Files                                  %GR%^|%RS%   %CY%^|%RS% Cleanup tasks : %YL%9%RS%                    %CY%^|%RS%
echo(%GR%^|%RS%  %YL%[2]%RS% Windows Temp Files [admin]                       %GR%^|%RS%   %CY%^|%RS% Engine        : Native CMD           %CY%^|%RS%
echo(%GR%^|%RS%  %YL%[3]%RS% Windows Update Cache [admin]                     %GR%^|%RS%   %CY%^|%RS% Access        : %ACCESSLABEL%        %CY%^|%RS%
echo(%GR%^|%RS%  %GR%[4]%RS% DNS Cache                                        %GR%^|%RS%   %CY%+--------------------------------------+%RS%
echo(%GR%^|%RS%  %GR%[5]%RS% Thumbnail Cache                                  %GR%^|%RS%   %YL%+--------------------------------------+%RS%
echo(%GR%^|%RS%  %GR%[6]%RS% Windows Error Reports                            %GR%^|%RS%   %YL%^|%RS% %YL%RECOMMENDATION%RS%                       %YL%^|%RS%
echo(%GR%^|%RS%  %GR%[7]%RS% Browser Cache (Chrome + Edge)                    %GR%^|%RS%   %YL%^|%RS% Close Chrome and Edge first.         %YL%^|%RS%
echo(%GR%^|%RS%  %YL%[8]%RS% Windows.old Folder [protected]                   %GR%^|%RS%   %YL%^|%RS% Rollback files are preserved.        %YL%^|%RS%
echo(%GR%^|%RS%  %YL%[9]%RS% Disk Cleanup [manual review]                     %GR%^|%RS%   %YL%^|%RS% Only older cache files removed.      %YL%^|%RS%
echo(%GR%+-------------------------------------------------------+%RS%   %YL%+--------------------------------------+%RS%
echo(
echo(%MG%+--------------------------------------------------------------------------------------------------+%RS%
echo(%MG%^|%RS% %MG%RUN MODES / OPTIONS%RS%                                                                              %MG%^|%RS%
echo(%MG%+--------------------------------------------------------------------------------------------------+%RS%
echo(%MG%^|%RS%  %GR%[A]%RS%  Automatic - clean eligible files; request optional admin access once                       %MG%^|%RS%
echo(%MG%^|%RS%  %YL%[M]%RS%  Manual    - confirm individual cleanup tasks in CMD                                        %MG%^|%RS%
echo(%MG%^|%RS%  %CY%[P]%RS%  Preview   - scan without deleting target files                                             %MG%^|%RS%
echo(%MG%^|%RS%  %RD%[Q]%RS%  Quit      - close this tool                                                                %MG%^|%RS%
echo(%MG%+--------------------------------------------------------------------------------------------------+%RS%
echo(
echo(%CY%----------------------------------------------------------------------------------------------------%RS%
echo(  %YL%TIP:%RS% Preview first. Locked or protected files are retained.
echo(
echo(  For full colors, open this batch file in Windows Terminal ^(Command Prompt^).
"%BIN%\choice.exe" /c AMPQ /n /m "  Enter your choice (A/M/P/Q): "
set "PICK=%errorlevel%"
:MenuPicked
if "%PICK%"=="4" goto :Quit
if "%PICK%"=="3" goto :PickPreview
if "%PICK%"=="2" goto :PickManual
if "%PICK%"=="1" goto :PickAuto
echo(  Invalid or interrupted input.
pause
goto :Menu
:PickAuto
set "RUNMODE=A"
goto :MaybeElevate
:PickManual
set "RUNMODE=M"
goto :MaybeElevate
:PickPreview
set "RUNMODE=P"
goto :Run

:MaybeElevate
if "%ADMIN%"=="1" goto :Run
if "%ASKED%"=="1" goto :Run
set "ASKED=1"
echo(
if "%VT%"=="0" goto :PermissionPlain
echo(%CY%┌─ %YL%PERMISSION / OPTIONAL ADMINISTRATOR ACCESS%CY% ─────────────────────────────────────────────────────┐%RS%
echo(%CY%│%WH% System temp, update cache and system error reports may need elevated access.%RS%                     %CY%│%RS%
echo(%CY%│%RS% %GR%[Y]%WH% Request access once via Windows UAC.%RS%                                                         %CY%│%RS%
echo(%CY%│%RS% %YL%[N]%WH% Continue with normal user permissions.%RS%                                                       %CY%│%RS%
echo(%CY%└──────────────────────────────────────────────────────────────────────────────────────────────────┘%RS%
goto :PermissionPrompt
:PermissionPlain
echo(  %YL%ADMINISTRATOR ACCESS - OPTIONAL%RS%
echo(  Windows Temp, Update Cache and system error reports may need elevation.
echo(  One Windows UAC approval covers the elevated app session.
echo(  Decline to continue with ordinary user cleanup.
:PermissionPrompt
"%BIN%\choice.exe" /c YN /n /m "  Request administrator access now [Y/N]? "
if not "%errorlevel%"=="1" goto :Run
call :ReadSid
if not defined ACCOUNTSID goto :ElevationFallback
if not exist "%BIN%\cscript.exe" goto :ElevationFallback
set "TOKEN=%RANDOM%_%RANDOM%_%RANDOM%"
set "ACK=%WORKROOT%\Elev_%TOKEN%.ok"
set "HELPER=%WORKROOT%\Elev_%TOKEN%.vbs"
if exist "%ACK%" goto :ElevationFallback
if exist "%HELPER%" goto :ElevationFallback
set "CHECKPATH=%HELPER%"
call :SafePath
if errorlevel 1 goto :ElevationFallback
rem Run the helper without elevation. Only ShellExecute invokes the normal UAC prompt.
rem No command strings from user input; A/M and random numeric token are fixed internally.
>"%HELPER%" echo Option Explicit
>>"%HELPER%" echo Dim sh, q, script, args, mode
>>"%HELPER%" echo q = Chr^(34^)
>>"%HELPER%" echo script = WScript.Arguments^(0^)
>>"%HELPER%" echo mode = WScript.Arguments^(1^)
>>"%HELPER%" echo If InStr^(script, Chr^(37^)^) ^> 0 Then WScript.Quit 2
>>"%HELPER%" echo If mode ^<^> "A" And mode ^<^> "M" Then WScript.Quit 2
>>"%HELPER%" echo args = "/d /v:off /c " ^& q ^& q ^& script ^& q ^& " --worker --elevated-" ^& mode ^& " " ^& WScript.Arguments^(2^) ^& " " ^& WScript.Arguments^(3^) ^& q
>>"%HELPER%" echo Set sh = CreateObject^("Shell.Application"^)
>>"%HELPER%" echo sh.ShellExecute WScript.Arguments^(4^), args, "", "runas", 1
>>"%HELPER%" echo WScript.Quit 0
"%BIN%\cscript.exe" //nologo "%HELPER%" "%~f0" "%RUNMODE%" "%TOKEN%" "%ACCOUNTSID%" "%BIN%\cmd.exe"
set "ELEVRC=%errorlevel%"
del /q "%HELPER%" >nul 2>&1
if not "%ELEVRC%"=="0" goto :ElevationFallback
rem ShellExecute COM does not return the process result. Wait for child acknowledgment.
echo(  %CY%Waiting for the elevated CMD session...%RS%
set /a WAITCOUNT=0
:WaitForAdmin
if exist "%ACK%" goto :AdminHandoff
if %WAITCOUNT% geq 15 goto :ElevationUnconfirmed
"%BIN%\timeout.exe" /t 1 /nobreak >nul 2>&1
set /a WAITCOUNT+=1
goto :WaitForAdmin
:AdminHandoff
del /q "%ACK%" >nul 2>&1
echo(  %GR%Administrator session started. Continuing in the new CMD window.%RS%
goto :Quit
:ElevationUnconfirmed
echo(  %YL%No elevated session confirmed. If another window opened, use that window only.%RS%
echo(  Otherwise select your cleanup mode again; no further admin prompt will appear.
pause
goto :Menu
:ElevationFallback
echo(  %YL%Elevation declined or unavailable. Continuing with standard access.%RS%
goto :Run
:ReadSid
set "ACCOUNTSID="
for /f "tokens=2 delims=," %%S in ('%SystemRoot%\System32\whoami.exe /user /fo csv /nh 2^>nul') do set "ACCOUNTSID=%%~S"
exit /b 0
:ElevationNotGranted
echo(  [WARN] Elevated session could not be verified. No cleanup started.
pause
goto :Quit
:OtherAccount
echo(  [WARN] Different administrator account detected. No cleanup started.
echo(  Return to the original window to clean your own user profile.
pause
goto :Quit

:Run
rem Unique run directory holds only our own manifests; never use it as a target.
set "RUNID=%RANDOM%_%RANDOM%_%RANDOM%"
set "RUNDIR=%WORKROOT%\Run_%RUNID%"
if exist "%RUNDIR%" goto :Run
md "%RUNDIR%" 2>nul
if errorlevel 1 goto :BadEnvironment
set "CHECKPATH=%RUNDIR%"
call :SafePath
if errorlevel 1 goto :BadEnvironment
set "LOGFILE=%LOGROOT%\CleanupLog_%RUNID%.txt"
if exist "%LOGFILE%" goto :BadEnvironment
>"%LOGFILE%" (echo ADVANCED WINDOWS CLEANUP TOOL %VERSION%) || goto :BadEnvironment
>>"%LOGFILE%" echo Developed by: Nishan Dhakal
>>"%LOGFILE%" echo Mode: %RUNMODE%  Access: %ACCESS%  Date: %date% %time%
>>"%LOGFILE%" echo File age filter: Robocopy MINAGE 2 calendar days at scan time.
set "MANIFEST=%RUNDIR%\candidates.txt"
set "SCANFILE=%RUNDIR%\scan.txt"
set "BEFOREFILE=%RUNDIR%\before.txt"
set "AFTERFILE=%RUNDIR%\after.txt"
set /a "DONE=0,PARTIAL=0,FAILED=0,SKIPPED=0,REVIEWS=0,PREVIEWS=0,NOCHANGE=0"
set /a "ALLREMOVED=0,ALLCANDIDATES=0"
set "MODENAME=Automatic"
if /i "%RUNMODE%"=="M" set "MODENAME=Manual"
if /i "%RUNMODE%"=="P" set "MODENAME=Preview"
set "STATUSTXT=RUNNING"
set "STATUSCLR=%YL%"
cls
call :Header
echo(%WH%Mode: %YL%%MODENAME%%RS%  %CY%│%RS%  %WH%Access: %ACCESSCOLOR%%ACCESS%%RS%
dir /a /-c "%SYS%\" >"%BEFOREFILE%" 2>&1
call :ReadFree BEFORE "%BEFOREFILE%"
echo   Free space before: %BEFORE% bytes (when available)
>>"%LOGFILE%" echo Free space before: %BEFORE% bytes
for /l %%S in (1,1,9) do call :Step %%S
dir /a /-c "%SYS%\" >"%AFTERFILE%" 2>&1
call :ReadFree AFTER "%AFTERFILE%"
call :Summary
rem Delete only the exact temporary files created by this run. Preserve log.
del /q "%MANIFEST%" "%SCANFILE%" "%BEFOREFILE%" "%AFTERFILE%" >nul 2>&1
rd "%RUNDIR%" >nul 2>&1
echo(
pause
goto :Menu

:Step
set "STEP=%~1"
setlocal EnableDelayedExpansion
for %%I in (!STEP!) do set "TASK=!NAME%%I!"
endlocal & set "TASK=%TASK%"
set /a "TOTAL=0,PROCESSED=0,REMOVED=0,ERRORS=0,SCANERRORS=0,LASTPCT=-1"
set "STATE="
set "DETAIL="
set "AGE=2"
set "MASK=*"
set "DEPTH=/S"
set "ROOT="
type nul >"%MANIFEST%" || goto :ManifestError
echo(
if "%VT%"=="0" goto :StagePlain
echo(%YL%[TASK %STEP%/9]%RS% %WH%%TASK%%RS%
echo(%CY%────────────────────────────────────────────────────────────────────────────────────────────────────%RS%
goto :StageReady
:StagePlain
echo %CY%----------------------------------------------------------------------------------------------------%RS%
echo   %CY%[%STEP%/9] %TASK%%RS%
:StageReady
if "%ADMIN%"=="0" if "%STEP%"=="2" goto :ProtectedSkip
if "%ADMIN%"=="0" if "%STEP%"=="3" goto :ProtectedSkip
if "%STEP%"=="8" goto :Task8
if /i "%RUNMODE%"=="A" if "%STEP%"=="9" goto :AutoSkip
if /i "%RUNMODE%"=="M" (
    "%BIN%\choice.exe" /c YN /n /m "  Proceed with this task [Y/N]? "
    if errorlevel 2 goto :UserSkip
    if not errorlevel 1 goto :UserSkip
    if errorlevel 255 goto :UserSkip
)
call :Progress 0 "Preparing"
goto :Task%STEP%

:Task1
rem Only clean the standard local profile Temp directory, not custom TEMP paths.
set "ROOT=%LOCAL%\Temp"
if /i "%TEMP%"=="%ROOT%" goto :UserTempScan
if "%VT%"=="1" echo(
echo(  %YL%Custom TEMP ignored; standard local Temp used.%RS%
:UserTempScan
call :Collect
goto :ProcessManifest
:Task2
set "ROOT=%WIN%\Temp"
call :Collect
goto :ProcessManifest
:Task3
rem Do not interrupt an active update or alter service configuration.
rem Check state 1 (STOPPED); unknown/localized output fails closed.
if /i "%RUNMODE%"=="P" goto :UpdateScan
call :UpdateIdle
if errorlevel 1 goto :UpdateBusy
:UpdateScan
set "ROOT=%WIN%\SoftwareDistribution\Download"
call :Collect
if /i "%RUNMODE%"=="P" goto :ProcessManifest
call :UpdateIdle
if errorlevel 1 goto :UpdateBusy
goto :ProcessManifest
:UpdateIdle
"%BIN%\sc.exe" query wuauserv | "%BIN%\findstr.exe" /r /i /c:"STATE *: *1  *STOPPED" >nul
if errorlevel 1 exit /b 1
"%BIN%\sc.exe" query bits | "%BIN%\findstr.exe" /r /i /c:"STATE *: *1  *STOPPED" >nul
if errorlevel 1 exit /b 1
exit /b 0
:UpdateBusy
set "STATE=SKIPPED"
set "DETAIL=Update services are active or state unknown; no services stopped."
goto :FinishStep
:ProtectedSkip
set "STATE=SKIPPED"
set "DETAIL=Administrator access not granted; protected directory preserved."
goto :FinishStep
:Task4
if /i "%RUNMODE%"=="P" (
    set "STATE=PREVIEW"
    set "DETAIL=Would flush DNS cache; no disk files involved."
    goto :FinishStep
)
call :Progress 0 "Flushing DNS (waiting for Windows)"
"%BIN%\ipconfig.exe" /flushdns >>"%LOGFILE%" 2>&1
if errorlevel 1 (
    set "STATE=SKIPPED"
    set "DETAIL=DNS flush unavailable or denied by Windows; see log."
) else (
    set "STATE=DONE"
    set "DETAIL=DNS cache flushed."
)
goto :FinishStep
:Task5
set "ROOT=%LOCAL%\Microsoft\Windows\Explorer"
set "MASK=thumbcache_*.db"
set "DEPTH="
call :Collect
goto :ProcessManifest
:Task6
for %%R in (ReportArchive ReportQueue) do (
    set "ROOT=%LOCAL%\Microsoft\Windows\WER\%%R"
    call :Collect
)
if "%ADMIN%"=="0" goto :ProcessManifest
if not defined ProgramData goto :ProcessManifest
for %%R in (ReportArchive ReportQueue) do (
    set "ROOT=%ProgramData%\Microsoft\Windows\WER\%%R"
    call :Collect
)
goto :ProcessManifest
:Task7
if /i "%RUNMODE%"=="P" goto :BrowserScan
"%BIN%\tasklist.exe" /nh /fi "IMAGENAME eq chrome.exe" 2>nul | "%BIN%\findstr.exe" /i /b /c:"chrome.exe " >nul
if not errorlevel 1 goto :BrowserBusy
"%BIN%\tasklist.exe" /nh /fi "IMAGENAME eq msedge.exe" 2>nul | "%BIN%\findstr.exe" /i /b /c:"msedge.exe " >nul
if not errorlevel 1 goto :BrowserBusy
:BrowserScan
set "BASE=%LOCAL%\Google\Chrome\User Data"
call :Browser
set "BASE=%LOCAL%\Microsoft\Edge\User Data"
call :Browser
goto :ProcessManifest
:Task8
set "STATE=SKIPPED"
set "DETAIL=Windows.old is protected; rollback and old personal files preserved."
goto :FinishStep
:Task9
if /i "%RUNMODE%"=="P" (
    set "STATE=PREVIEW"
    set "DETAIL=Would open interactive Windows Disk Cleanup."
    goto :FinishStep
)
if not exist "%BIN%\cleanmgr.exe" goto :ReviewError
echo(
echo   %YL%Review selected categories in the Windows Disk Cleanup window.%RS%
echo   This is optional and uses Windows normal permissions.
echo   Windows may offer its own separate system-cleanup elevation option.
call :Progress 0 "Waiting for Windows Disk Cleanup"
start "" /wait "%BIN%\cleanmgr.exe" /d %SYS:~0,1%
if errorlevel 1 goto :ReviewError
set "STATE=REVIEW"
set "DETAIL=Disk Cleanup closed; categories and freed bytes not verified."
goto :FinishStep

:AutoSkip
set "STATE=SKIPPED"
set "DETAIL=Manual review only; automatic mode never opens a separate window."
goto :FinishStep
:UserSkip
set "STATE=SKIPPED"
set "DETAIL=User declined."
goto :FinishStep
:BrowserBusy
set "STATE=SKIPPED"
set "DETAIL=Close Chrome and Edge completely, including background processes, then retry."
goto :FinishStep
:ReviewError
set "STATE=FAILED"
set "DETAIL=Windows review utility unavailable or returned an error."
goto :FinishStep
:ManifestError
set "STATE=FAILED"
set "DETAIL=Cannot initialize the scan manifest."
goto :FinishStep

:Browser
set "CHECKPATH=%BASE%"
call :SafePath
if errorlevel 1 (
    set /a SCANERRORS+=1
    exit /b
)
if not exist "%BASE%\" exit /b
set "PROFILE=%BASE%\Default"
call :ProfileCaches
for /d %%D in ("%BASE%\Profile *") do (
    set "PROFILE=%%~fD"
    call :ProfileCaches
)
exit /b
:ProfileCaches
for %%C in (Cache "Code Cache" GPUCache) do (
    set "ROOT=%PROFILE%\%%~C"
    call :Collect
)
exit /b

:Collect
rem Robocopy is ONLY a read-only enumerator. /L never copies or deletes.
rem /MINAGE:2 = conservative calendar-day age cutoff (not exactly 48 hours).
rem Do not enumerate reparse points. Verify each path again before deletion.
set "CHECKPATH=%ROOT%"
call :SafePath
if errorlevel 1 goto :CollectUnsafe
if not exist "%ROOT%\" exit /b
if exist "%RUNDIR%\NeverCreated" goto :CollectUnsafe
call :Progress 0 "Scanning eligible files..."
"%BIN%\robocopy.exe" "%ROOT%" "%RUNDIR%\NeverCreated" "%MASK%" /L %DEPTH% /MINAGE:%AGE% /XJ /XJD /XJF /R:0 /W:0 /NJH /NJS /NDL /NC /NS /NP /FP >"%SCANFILE%" 2>&1
set "SCANRC=%errorlevel%"
if %SCANRC% geq 8 (
    set /a SCANERRORS+=1
    >>"%LOGFILE%" echo Robocopy scan error %SCANRC% for "%ROOT%"
    >>"%LOGFILE%" type "%SCANFILE%"
    exit /b
)
call :PreparePrefix
rem /FP emits full paths. Only accept lines under this specific root.
rem FOR variable assignment runs with delayed expansion OFF to preserve !.
for /f "usebackq tokens=*" %%F in ("%SCANFILE%") do (
    set "CANDIDATE=%%F"
    call :AddCandidate
)
exit /b
:CollectUnsafe
set /a SCANERRORS+=1
>>"%LOGFILE%" echo Unsafe or inaccessible scan root skipped: "%ROOT%"
exit /b

:PreparePrefix
setlocal EnableDelayedExpansion
set "PREFIX=!ROOT!\"
set "REST=!PREFIX!"
set /a L=0
:PrefixLength
if defined REST (
    set "REST=!REST:~1!"
    set /a L+=1
    goto :PrefixLength
)
endlocal & set "PREFIXLEN=%L%" & exit /b

:AddCandidate
setlocal EnableDelayedExpansion
set "PREFIX=!ROOT!\"
for %%L in (!PREFIXLEN!) do if /i not "!CANDIDATE:~0,%%L!"=="!PREFIX!" goto :RejectCandidate
if not "!CANDIDATE:?=!"=="!CANDIDATE!" goto :RejectCandidate

rem Robocopy returns raw paths; reject ambiguous / wildcard or ADS paths.
set "TAIL=!CANDIDATE:~2!"
if not "!TAIL::=!"=="!TAIL!" goto :RejectCandidate
>>"!MANIFEST!" echo(!CANDIDATE!||goto :CandidateWriteFailed
endlocal
exit /b
:CandidateWriteFailed
endlocal & set /a SCANERRORS+=1
exit /b 0
:RejectCandidate
endlocal
exit /b 0

:ProcessManifest
for /f "usebackq eol=| delims=" %%F in ("%MANIFEST%") do set /a TOTAL+=1
set /a ALLCANDIDATES+=TOTAL
if %TOTAL% equ 0 (
    if %SCANERRORS% gtr 0 (
        set "STATE=FAILED"
        set "DETAIL=No candidates processed; one or more scans failed."
    ) else (
        set "STATE=NO CHANGE"
        set "DETAIL=No eligible files found."
    )
    goto :FinishStep
)
if /i "%RUNMODE%"=="P" (
    set "STATE=PREVIEW"
    set "DETAIL=%TOTAL% candidate files; no target files deleted. Scan errors: %SCANERRORS%."
    if %SCANERRORS% gtr 0 set "STATE=PARTIAL"
    goto :FinishStep
)
call :Progress 0 "Processing %TOTAL% candidate files"
for /f "usebackq eol=| delims=" %%F in ("%MANIFEST%") do (
    set "CANDIDATE=%%F"
    call :ProcessOne
)
set /a ALLREMOVED+=REMOVED
set "DETAIL=Removed %REMOVED%/%TOTAL% files; retained/errors: %ERRORS%; scan errors: %SCANERRORS%."
set "STATE=DONE"
if %ERRORS% gtr 0 set "STATE=PARTIAL"
if %SCANERRORS% gtr 0 set "STATE=PARTIAL"
if %REMOVED% equ 0 if /i "%STATE%"=="PARTIAL" set "STATE=FAILED"
goto :FinishStep

:ProcessOne
set "CHECKPATH=%CANDIDATE%"
call :SafePath
if errorlevel 1 goto :RetainOne
setlocal EnableDelayedExpansion
set "ATTR="
for %%I in ("!CANDIDATE!") do set "ATTR=%%~aI"
if not defined ATTR goto :FileFailed
if /i "!ATTR:~0,1!"=="d" goto :FileFailed
if not "!ATTR:l=!"=="!ATTR!" goto :FileFailed
rem Avoid wildcard expansion and alternate data streams even on malformed list.
if not "!CANDIDATE:?=!"=="!CANDIDATE!" goto :FileFailed

set "TAIL=!CANDIDATE:~2!"
if not "!TAIL::=!"=="!TAIL!" goto :FileFailed
rem No /S, no directory removal, no force on read-only files.
del /q "!CANDIDATE!" >nul 2>&1
if exist "!CANDIDATE!" goto :FileFailed
endlocal & set /a REMOVED+=1
goto :AdvanceOne
:FileFailed
endlocal
:RetainOne
set /a ERRORS+=1
rem Limit per-file diagnostics to 100 per stage; exact counters remain.
if %ERRORS% leq 100 (
    setlocal EnableDelayedExpansion
    >>"!LOGFILE!" echo Retained: !CANDIDATE!
    endlocal
)
:AdvanceOne
set /a PROCESSED+=1
rem Avoid 32-bit overflow for unusually huge manifests.
if %TOTAL% gtr 20000000 (
    set /a "DIVISOR=TOTAL/100,PC=PROCESSED/DIVISOR"
) else set /a "PC=PROCESSED*100/TOTAL"
if %PC% gtr 100 set "PC=100"
if "%VT%"=="1" goto :RenderFileProgress
set /a "PC=PC/10*10"
:RenderFileProgress
if not "%PC%"=="%LASTPCT%" call :Progress %PC% "%PROCESSED%/%TOTAL% processed; %REMOVED% removed"
exit /b

:SafePath
rem Validate local absolute path and every existing ancestor. No reparse points.
rem Inputs in environment variable, not CALL arguments (no double expansion).
setlocal DisableDelayedExpansion
if not defined CHECKPATH goto :Unsafe
rem Fail closed for wildcard characters and ! (CMD FOR expansion ambiguity).
set "TOKEN="
for /f "tokens=1 delims=*!?" %%T in ("%CHECKPATH%") do set "TOKEN=%%T"
if not "%TOKEN%"=="%CHECKPATH%" goto :Unsafe
setlocal EnableDelayedExpansion
if not "!CHECKPATH:~1,2!"==":\" goto :UnsafeNested
set "TAIL=!CHECKPATH:~2!"
if not "!TAIL::=!"=="!TAIL!" goto :UnsafeNested
for %%I in ("!CHECKPATH!") do set "P=%%~fI"
if not defined P goto :UnsafeNested
if "!P:~3!"=="" goto :UnsafeNested
:Ancestor
if "!P:~3!"=="" goto :Safe
set "A="
for %%I in ("!P!") do set "A=%%~aI"
if defined A (
    if not "!A:l=!"=="!A!" goto :UnsafeNested
) else if exist "!P!" goto :UnsafeNested
for %%I in ("!P!") do set "UP=%%~dpI"
if not "!UP:~3!"=="" if "!UP:~-1!"=="\" set "UP=!UP:~0,-1!"
if not defined UP goto :UnsafeNested
if /i "!UP!"=="!P!" goto :UnsafeNested
set "P=!UP!"
goto :Ancestor
:Safe
endlocal & endlocal & exit /b 0
:UnsafeNested
endlocal & endlocal & exit /b 1
:Unsafe
endlocal & exit /b 1

:Progress
set "LASTPCT=%~1"
if "%VT%"=="0" goto :ProgressPlain
call :ColorBar %~1
setlocal EnableDelayedExpansion
set "MESSAGE=%~2"
<nul set /p "=!ESC![2K!ESC![1G  !CBAR! !CY!%~1%%!RS!  !WH!!MESSAGE!!RS!"
endlocal & exit /b 0
:ProgressPlain
call :DrawBar %~1
setlocal EnableDelayedExpansion
set "MESSAGE=%~2"
echo(  [!BAR!] %~1%%  !MESSAGE!
endlocal & exit /b 0

:ColorBar
rem Loop-free progress bar (30 cells): green blocks over a gray track.
setlocal EnableDelayedExpansion
set /a "CELLS=%~1*30/100"
set /a "REST=30-CELLS"
set "FP="
set "EP="
if !CELLS! gtr 0 set "FP=!FULL30:~0,%CELLS%!"
if !REST! gtr 0 set "EP=!SHD30:~0,%REST%!"
set "CB=!GR!!FP!!GY!!EP!!RS!"
endlocal & set "CBAR=%CB%"
exit /b 0

:DrawBar
setlocal EnableDelayedExpansion
set /a "FILL=%~1/5"
set "B="
for /l %%B in (1,1,20) do if %%B leq !FILL! (set "B=!B!#") else set "B=!B!."
endlocal & set "BAR=%B%"
exit /b

:FinishStep
rem 100%% means this stage is finished/assessed, not all files were removed.
call :Progress 100 "Stage finished"
if "%VT%"=="1" echo(
set "SCOLOR=%GR%"
if /i "%STATE%"=="FAILED" set "SCOLOR=%RD%"
if /i "%STATE%"=="PARTIAL" set "SCOLOR=%YL%"
if /i "%STATE%"=="SKIPPED" set "SCOLOR=%YL%"
if /i "%STATE%"=="REVIEW" set "SCOLOR=%YL%"
if /i "%STATE%"=="PREVIEW" set "SCOLOR=%CY%"
if /i "%STATE%"=="NO CHANGE" set "SCOLOR=%GY%"
echo   %SCOLOR%[%STATE%]%RS% %DETAIL%
>>"%LOGFILE%" echo [%STEP%/9] %TASK% - %STATE% - %DETAIL%
if /i "%STATE%"=="DONE" set /a DONE+=1
if /i "%STATE%"=="PARTIAL" set /a PARTIAL+=1
if /i "%STATE%"=="FAILED" set /a FAILED+=1
if /i "%STATE%"=="SKIPPED" set /a SKIPPED+=1
if /i "%STATE%"=="REVIEW" set /a REVIEWS+=1
if /i "%STATE%"=="PREVIEW" set /a PREVIEWS+=1
if /i "%STATE%"=="NO CHANGE" set /a NOCHANGE+=1
set /a "OVERALL=STEP*100/9"
if "%VT%"=="0" goto :OverallPlain
call :ColorBar %OVERALL%
echo(  %CY%OVERALL%RS%  %CBAR%  %YL%%OVERALL%%%RS%  %GY%(%STEP% of 9 stages assessed)%RS%
exit /b 0
:OverallPlain
call :DrawBar %OVERALL%
echo   %GY%Overall: [%BAR%] %OVERALL%%%  (%STEP% of 9 stages assessed)%RS%
exit /b

:ReadFree
rem English DIR footer only; unavailable on other display languages.
setlocal DisableDelayedExpansion
set "VALUE="
for /f "tokens=3" %%N in ('findstr /i /c:"bytes free" "%~2"') do set "VALUE=%%N"
set "VALUE=%VALUE:,=%"
if not defined VALUE goto :FreeUnknown
for /f "delims=0123456789" %%X in ("%VALUE%") do goto :FreeUnknown
endlocal & set "%~1=%VALUE%" & exit /b
:FreeUnknown
endlocal & set "%~1=Unavailable" & exit /b

:Summary
echo(
echo %CY%+--------------------------------------------------------------------------------------------------+%RS%
if /i "%RUNMODE%"=="P" goto :PreviewHeading
echo(  %GR%RUN FINISHED%RS%
goto :SummaryBody
:PreviewHeading
echo(  %CY%PREVIEW FINISHED - NO TARGET FILES DELETED%RS%
:SummaryBody
echo %CY%+--------------------------------------------------------------------------------------------------+%RS%
echo   %GR%Completed: %DONE%%RS%   %WH%No change: %NOCHANGE%%RS%   %YL%Skipped: %SKIPPED%%RS%   %WH%Reviewed: %REVIEWS%%RS%
echo   %YL%Partial: %PARTIAL%%RS%     %RD%Failed: %FAILED%%RS%      %CY%Previewed: %PREVIEWS%%RS%
echo   %WH%Candidate files :%RS% %GR%%ALLCANDIDATES%%RS%
echo   %WH%Files removed   :%RS% %GR%%ALLREMOVED%%RS%
echo   %WH%Free before     :%RS% %GR%%BEFORE%%RS% bytes
echo   %WH%Free after      :%RS% %GR%%AFTER%%RS% bytes
echo   %GY%Free-space changes also reflect other running applications.%RS%
>>"%LOGFILE%" echo Completed=%DONE% NoChange=%NOCHANGE% Skipped=%SKIPPED% Reviewed=%REVIEWS% Partial=%PARTIAL% Failed=%FAILED% Previewed=%PREVIEWS%
>>"%LOGFILE%" echo Candidates=%ALLCANDIDATES% Removed=%ALLREMOVED%
>>"%LOGFILE%" echo Free after: %AFTER% bytes
setlocal EnableDelayedExpansion
echo   %GR%Log: !LOGFILE!%RS%
endlocal
echo %CY%+--------------------------------------------------------------------------------------------------+%RS%
exit /b

:MissingTool
echo(
echo   %RD%[ERROR] A required built-in Windows utility is missing.%RS%
goto :FatalExit
:BadEnvironment
echo(
echo   %RD%[ERROR] Required Windows paths or log directory unavailable.%RS%
:FatalExit
if "%VT%"=="1" <nul set /p "=%ESC%[?25h"
if defined OLDCP chcp %OLDCP% >nul 2>&1
endlocal & exit /b 1
:Quit
if "%VT%"=="1" <nul set /p "=%ESC%[?25h"
echo(  %CY%Goodbye.%RS%
if defined OLDCP chcp %OLDCP% >nul 2>&1
endlocal & exit /b 0
