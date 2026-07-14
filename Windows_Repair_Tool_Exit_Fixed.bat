@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Repair Tool - All Problems Fixer
color 0A

:: ================================================================
:: Windows Repair Tool - All Problems Fixer
:: Language: Windows Batch / CMD script (.bat)
:: Run as Administrator.
:: This tool focuses on general Windows repair only.
:: It logs all results to your Desktop and avoids deleting personal files.
:: Extra recommended tools added: restore point, Defender scan, search index, battery report, memory diagnostic.
:: Verified safer version: improved admin check, safer cleanup, stronger tool path fallbacks, fixed X exit behavior.
:: ================================================================

:: Robust automatic path setup.
:: Detects the real Desktop/Documents/Downloads paths, even with OneDrive or redirected folders.
:: Detects the correct Windows system folder, including Sysnative when a 32-bit CMD runs on 64-bit Windows.
set "SCRIPT_DIR=%~dp0"
if not defined SystemRoot set "SystemRoot=C:\Windows"

if exist "%SystemRoot%\Sysnative\cmd.exe" (
    set "SYS_DIR=%SystemRoot%\Sysnative"
) else (
    set "SYS_DIR=%SystemRoot%\System32"
)

set "PS=%SYS_DIR%\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS%" set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS%" set "PS=powershell.exe"

:: PowerShell prints known folders as KEY=VALUE, then batch reads them.
for /f "usebackq tokens=1,* delims==" %%A in (`"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $shell=New-Object -ComObject Shell.Application; $desktop=[Environment]::GetFolderPath('Desktop'); $docs=[Environment]::GetFolderPath('MyDocuments'); $downloads=($shell.Namespace('shell:Downloads').Self.Path); if([string]::IsNullOrWhiteSpace($desktop)){ $desktop=[Environment]::GetFolderPath('UserProfile') + '\Desktop' }; if([string]::IsNullOrWhiteSpace($docs)){ $docs=[Environment]::GetFolderPath('UserProfile') + '\Documents' }; if([string]::IsNullOrWhiteSpace($downloads)){ $downloads=[Environment]::GetFolderPath('UserProfile') + '\Downloads' }; 'DESKTOP_DIR=' + $desktop; 'DOCUMENTS_DIR=' + $docs; 'DOWNLOADS_DIR=' + $downloads" 2^>nul`) do set "%%A=%%B"

if not defined DESKTOP_DIR set "DESKTOP_DIR=%USERPROFILE%\Desktop"
if not exist "%DESKTOP_DIR%" set "DESKTOP_DIR=%SCRIPT_DIR%"
if not exist "%DESKTOP_DIR%" mkdir "%DESKTOP_DIR%" >nul 2>&1
if not defined DOCUMENTS_DIR set "DOCUMENTS_DIR=%USERPROFILE%\Documents"
if not defined DOWNLOADS_DIR set "DOWNLOADS_DIR=%USERPROFILE%\Downloads"

set "LOG=%DESKTOP_DIR%\Windows_Repair_Tool_Log.txt"
set "INFO_NFO=%DESKTOP_DIR%\Windows_System_Info.nfo"
set "INFO_TXT=%DESKTOP_DIR%\Windows_System_Info.txt"
set "REPORT=%DESKTOP_DIR%\Windows_Repair_Quick_Report.txt"
set "ENERGY_REPORT=%DESKTOP_DIR%\Windows_Energy_Report.html"
set "BATTERY_REPORT=%DESKTOP_DIR%\Windows_Battery_Report.html"

:: Use automatically detected full system paths so repairs still work if PATH is broken.
set "DISM_EXE=%SYS_DIR%\Dism.exe"
set "SFC_EXE=%SYS_DIR%\sfc.exe"
set "IPCONFIG_EXE=%SYS_DIR%\ipconfig.exe"
set "NETSH_EXE=%SYS_DIR%\netsh.exe"
set "CHKDSK_EXE=%SYS_DIR%\chkdsk.exe"
set "DEFRAG_EXE=%SYS_DIR%\defrag.exe"
set "POWERCFG_EXE=%SYS_DIR%\powercfg.exe"
set "SYSTEMINFO_EXE=%SYS_DIR%\systeminfo.exe"
set "MSINFO32_EXE=%SYS_DIR%\msinfo32.exe"
set "WMIC_EXE=%SYS_DIR%\wbem\wmic.exe"
set "CLEANMGR_EXE=%SYS_DIR%\cleanmgr.exe"
set "WSRESET_EXE=%SYS_DIR%\wsreset.exe"
set "W32TM_EXE=%SYS_DIR%\w32tm.exe"
set "CONTROL_EXE=%SYS_DIR%\control.exe"
set "MDSCHED_EXE=%SYS_DIR%\MdSched.exe"
set "TASKKILL_EXE=%SYS_DIR%\taskkill.exe"
set "EXPLORER_EXE=%SystemRoot%\explorer.exe"
set "USOCLIENT_EXE=%SYS_DIR%\UsoClient.exe"
set "FLTRMC_EXE=%SYS_DIR%\fltmc.exe"

:: Fallbacks for tools that are missing or if the system folder is unusual.
if not exist "%DISM_EXE%" set "DISM_EXE=dism.exe"
if not exist "%SFC_EXE%" set "SFC_EXE=sfc.exe"
if not exist "%IPCONFIG_EXE%" set "IPCONFIG_EXE=ipconfig.exe"
if not exist "%NETSH_EXE%" set "NETSH_EXE=netsh.exe"
if not exist "%CHKDSK_EXE%" set "CHKDSK_EXE=chkdsk.exe"
if not exist "%DEFRAG_EXE%" set "DEFRAG_EXE=defrag.exe"
if not exist "%POWERCFG_EXE%" set "POWERCFG_EXE=powercfg.exe"
if not exist "%SYSTEMINFO_EXE%" set "SYSTEMINFO_EXE=systeminfo.exe"
if not exist "%MSINFO32_EXE%" set "MSINFO32_EXE=msinfo32.exe"
if not exist "%WMIC_EXE%" set "WMIC_EXE=wmic.exe"
if not exist "%CLEANMGR_EXE%" set "CLEANMGR_EXE="
if not exist "%WSRESET_EXE%" set "WSRESET_EXE=wsreset.exe"
if not exist "%W32TM_EXE%" set "W32TM_EXE=w32tm.exe"
if not exist "%CONTROL_EXE%" set "CONTROL_EXE=control.exe"
if not exist "%MDSCHED_EXE%" set "MDSCHED_EXE=mdsched.exe"
if not exist "%TASKKILL_EXE%" set "TASKKILL_EXE=taskkill.exe"
if not exist "%EXPLORER_EXE%" set "EXPLORER_EXE=explorer.exe"
if not exist "%USOCLIENT_EXE%" set "USOCLIENT_EXE=UsoClient.exe"
if not exist "%FLTRMC_EXE%" set "FLTRMC_EXE=fltmc.exe"

cls
echo ================================================================
echo              Windows Repair Tool - All Problems Fixer
echo ================================================================
echo.
echo IMPORTANT:
echo - Right-click this file and choose: Run as administrator.
echo - Save your work before continuing.
echo - A restart is recommended after repairs finish.
echo - This tool does not delete your personal files.
echo - The menu uses an infinite loop and returns after each repair.
echo.
echo Detected output folder:
echo %DESKTOP_DIR%
echo.
echo Detected Windows system folder:
echo %SYS_DIR%
echo.
echo Detected Documents folder:
echo %DOCUMENTS_DIR%
echo.
echo Log file:
echo %LOG%
echo ================================================================
echo.

"%FLTRMC_EXE%" >nul 2>&1
if not "%errorlevel%"=="0" (
    net session >nul 2>&1
)
if not "%errorlevel%"=="0" (
    echo ERROR: This script must be run as Administrator.
    echo Right-click the file and choose "Run as administrator".
    pause
    exit /b 1
)

(
    echo ================================================================
    echo Windows Repair Tool Log
    echo Started: %date% %time%
    echo Computer: %COMPUTERNAME%
    echo User: %USERNAME%
    echo Desktop Path: %DESKTOP_DIR%
    echo Documents Path: %DOCUMENTS_DIR%
    echo Downloads Path: %DOWNLOADS_DIR%
    echo System Folder: %SYS_DIR%
    echo DISM: %DISM_EXE%
    echo SFC: %SFC_EXE%
    echo PowerShell: %PS%
    echo ================================================================
) > "%LOG%"

:: Main menu loop.
:: Fixed: the old infinite FOR loop could restart after choosing X because exit /b returned to the loop.
:: This loop lets X close the script cleanly.
:MAIN_LOOP
call :MENU_LOOP
if errorlevel 22 goto END
call :FINISH
goto MAIN_LOOP

:MENU_LOOP
cls
echo ================================================================
echo              Choose what you want to repair
echo ================================================================
echo.
echo  1 - Recommended full Windows repair
echo  2 - Windows system file repair: DISM + SFC
echo  3 - Windows Update repair
echo  4 - Network repair: DNS/Winsock/IP reset
echo  5 - Disk check and drive health scan
echo  6 - Clean temporary Windows files
echo  7 - Repair Microsoft Store and built-in apps
echo  8 - Create system information files on Desktop
echo  9 - Repair printer spooler
echo  A - Repair Windows Security app
echo  B - Repair icon and thumbnail cache
echo  C - Repair time/date sync service
echo  D - Run component cleanup
echo  E - Reset Windows Firewall rules
echo  F - Repair power and sleep settings
echo  G - Create quick repair report
echo  H - Create system restore point
echo  I - Run Microsoft Defender quick scan
echo  J - Repair Windows Search index
echo  K - Create battery health report
echo  L - Run memory diagnostic tool
echo  X - Exit
echo.
choice /c 123456789ABCDEFGHIJKLX /n /m "Select an option: "
set "MENU_CHOICE=%errorlevel%"

if "%MENU_CHOICE%"=="1" call :FULL_REPAIR
if "%MENU_CHOICE%"=="2" call :WINDOWS
if "%MENU_CHOICE%"=="3" call :UPDATE
if "%MENU_CHOICE%"=="4" call :NETWORK
if "%MENU_CHOICE%"=="5" call :DISK
if "%MENU_CHOICE%"=="6" call :TEMPFILES
if "%MENU_CHOICE%"=="7" call :STOREAPPS
if "%MENU_CHOICE%"=="8" call :SYSTEMINFO
if "%MENU_CHOICE%"=="9" call :PRINTER
if "%MENU_CHOICE%"=="10" call :SECURITYAPP
if "%MENU_CHOICE%"=="11" call :ICONCACHE
if "%MENU_CHOICE%"=="12" call :TIMESYNC
if "%MENU_CHOICE%"=="13" call :COMPONENTCLEANUP
if "%MENU_CHOICE%"=="14" call :FIREWALLRESET
if "%MENU_CHOICE%"=="15" call :POWERFIX
if "%MENU_CHOICE%"=="16" call :QUICKREPORT
if "%MENU_CHOICE%"=="17" call :RESTOREPOINT
if "%MENU_CHOICE%"=="18" call :DEFENDERSCAN
if "%MENU_CHOICE%"=="19" call :SEARCHINDEX
if "%MENU_CHOICE%"=="20" call :BATTERYREPORT
if "%MENU_CHOICE%"=="21" call :MEMORYDIAG
if "%MENU_CHOICE%"=="22" exit /b 22

exit /b 0

:FULL_REPAIR
call :RESTOREPOINT
call :WINDOWS
call :UPDATE
call :NETWORK
call :TEMPFILES
call :STOREAPPS
call :SECURITYAPP
call :ICONCACHE
call :TIMESYNC
call :COMPONENTCLEANUP
call :DEFENDERSCAN
call :BATTERYREPORT
call :QUICKREPORT
exit /b 0

:WINDOWS
echo.
echo [Step] Running Windows system file repair...
echo This can take a long time. Do not close this window.
echo [Step] Windows system file repair started. >> "%LOG%"

echo Running DISM CheckHealth...
echo [Command] "%DISM_EXE%" /Online /Cleanup-Image /CheckHealth >> "%LOG%"
"%DISM_EXE%" /Online /Cleanup-Image /CheckHealth >> "%LOG%" 2>&1

echo Running DISM ScanHealth...
echo [Command] "%DISM_EXE%" /Online /Cleanup-Image /ScanHealth >> "%LOG%"
"%DISM_EXE%" /Online /Cleanup-Image /ScanHealth >> "%LOG%" 2>&1

echo Running DISM RestoreHealth...
echo [Command] "%DISM_EXE%" /Online /Cleanup-Image /RestoreHealth >> "%LOG%"
"%DISM_EXE%" /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1

echo Running SFC ScanNow...
echo [Command] "%SFC_EXE%" /scannow >> "%LOG%"
"%SFC_EXE%" /scannow >> "%LOG%" 2>&1

echo Windows system file repair finished.
echo [Step] Windows system file repair finished. >> "%LOG%"
exit /b 0

:UPDATE
echo.
echo [Step] Repairing Windows Update components...
echo [Step] Windows Update repair started. >> "%LOG%"

net stop wuauserv >> "%LOG%" 2>&1
net stop bits >> "%LOG%" 2>&1
net stop cryptsvc >> "%LOG%" 2>&1
net stop msiserver >> "%LOG%" 2>&1

if exist "%SystemRoot%\SoftwareDistribution.old" rd /s /q "%SystemRoot%\SoftwareDistribution.old" >> "%LOG%" 2>&1
if exist "%SystemRoot%\System32\catroot2.old" rd /s /q "%SystemRoot%\System32\catroot2.old" >> "%LOG%" 2>&1

if exist "%SystemRoot%\SoftwareDistribution" ren "%SystemRoot%\SoftwareDistribution" SoftwareDistribution.old >> "%LOG%" 2>&1
if exist "%SystemRoot%\System32\catroot2" ren "%SystemRoot%\System32\catroot2" catroot2.old >> "%LOG%" 2>&1

net start msiserver >> "%LOG%" 2>&1
net start cryptsvc >> "%LOG%" 2>&1
net start bits >> "%LOG%" 2>&1
net start wuauserv >> "%LOG%" 2>&1

"%USOCLIENT_EXE%" StartScan >> "%LOG%" 2>&1

echo Windows Update repair finished.
echo [Step] Windows Update repair finished. >> "%LOG%"
exit /b 0

:NETWORK
echo.
echo [Step] Repairing network settings...
echo [Step] Network repair started. >> "%LOG%"

"%IPCONFIG_EXE%" /flushdns >> "%LOG%" 2>&1
"%IPCONFIG_EXE%" /release >> "%LOG%" 2>&1
"%IPCONFIG_EXE%" /renew >> "%LOG%" 2>&1
"%NETSH_EXE%" winsock reset >> "%LOG%" 2>&1
"%NETSH_EXE%" int ip reset >> "%LOG%" 2>&1
"%NETSH_EXE%" winhttp reset proxy >> "%LOG%" 2>&1

echo Network repair finished. Internet may need a restart to work perfectly.
echo [Step] Network repair finished. >> "%LOG%"
exit /b 0

:DISK
echo.
echo [Step] Running disk health checks...
echo [Step] Disk checks started. >> "%LOG%"

echo Checking system drive status...
"%WMIC_EXE%" diskdrive get model,status >> "%LOG%" 2>&1

echo Running CHKDSK scan on the system drive...
"%CHKDSK_EXE%" %SystemDrive% /scan >> "%LOG%" 2>&1

echo Optimizing system drive safely...
"%DEFRAG_EXE%" %SystemDrive% /O >> "%LOG%" 2>&1

echo.
echo If Windows reports that deeper repair is needed, run this command later:
echo "%CHKDSK_EXE%" %SystemDrive% /f /r
echo It may ask to schedule the repair after restart.
echo Disk checks finished.
echo [Step] Disk checks finished. >> "%LOG%"
exit /b 0

:TEMPFILES
echo.
echo [Step] Cleaning temporary Windows files...
echo [Step] Temporary file cleanup started. >> "%LOG%"

del /s /f /q "%TEMP%\*" >> "%LOG%" 2>&1
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >> "%LOG%" 2>&1

del /s /f /q "%SystemRoot%\Temp\*" >> "%LOG%" 2>&1
for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >> "%LOG%" 2>&1

if defined CLEANMGR_EXE (
    echo Running Disk Cleanup in safer low-interaction mode...
    "%CLEANMGR_EXE%" /verylowdisk >> "%LOG%" 2>&1
) else (
    echo Cleanmgr.exe was not found. Skipping Disk Cleanup. >> "%LOG%"
)

echo Temporary file cleanup finished.
echo [Step] Temporary file cleanup finished. >> "%LOG%"
exit /b 0

:STOREAPPS
echo.
echo [Step] Repairing Microsoft Store and built-in app registration...
echo This can take a few minutes.
echo [Step] Store and app repair started. >> "%LOG%"

"%WSRESET_EXE%" >> "%LOG%" 2>&1
"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml')}" >> "%LOG%" 2>&1
"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers | Foreach {try {Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml') -ErrorAction Stop} catch {}}" >> "%LOG%" 2>&1

echo Microsoft Store and app repair finished.
echo [Step] Store and app repair finished. >> "%LOG%"
exit /b 0

:SYSTEMINFO
echo.
echo [Step] Creating system information files on Desktop...
echo [Step] System information export started. >> "%LOG%"

"%SYSTEMINFO_EXE%" > "%INFO_TXT%" 2>> "%LOG%"
"%MSINFO32_EXE%" /nfo "%INFO_NFO%" >> "%LOG%" 2>&1

echo System information files created:
echo %INFO_TXT%
echo %INFO_NFO%
echo [Step] System information export finished. >> "%LOG%"
exit /b 0

:PRINTER
echo.
echo [Step] Repairing printer spooler...
echo [Step] Printer spooler repair started. >> "%LOG%"

net stop spooler >> "%LOG%" 2>&1
del /s /f /q "%SystemRoot%\System32\spool\PRINTERS\*" >> "%LOG%" 2>&1
net start spooler >> "%LOG%" 2>&1

echo Printer spooler repair finished.
echo [Step] Printer spooler repair finished. >> "%LOG%"
exit /b 0

:SECURITYAPP
echo.
echo [Step] Repairing Windows Security app...
echo [Step] Windows Security repair started. >> "%LOG%"

"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage Microsoft.SecHealthUI -AllUsers | Reset-AppxPackage" >> "%LOG%" 2>&1
"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Get-AppxPackage -AllUsers Microsoft.SecHealthUI | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml')}" >> "%LOG%" 2>&1

echo Windows Security repair finished.
echo [Step] Windows Security repair finished. >> "%LOG%"
exit /b 0

:ICONCACHE
echo.
echo [Step] Repairing icon and thumbnail cache...
echo Explorer will restart.
echo [Step] Icon and thumbnail cache repair started. >> "%LOG%"

"%TASKKILL_EXE%" /f /im explorer.exe >> "%LOG%" 2>&1
del /a /f /q "%LOCALAPPDATA%\IconCache.db" >> "%LOG%" 2>&1
del /a /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache*" >> "%LOG%" 2>&1
del /a /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache*" >> "%LOG%" 2>&1
start "" "%EXPLORER_EXE%"

echo Icon and thumbnail cache repair finished.
echo [Step] Icon and thumbnail cache repair finished. >> "%LOG%"
exit /b 0

:TIMESYNC
echo.
echo [Step] Repairing Windows time sync...
echo [Step] Time sync repair started. >> "%LOG%"

net stop w32time >> "%LOG%" 2>&1
"%W32TM_EXE%" /unregister >> "%LOG%" 2>&1
"%W32TM_EXE%" /register >> "%LOG%" 2>&1
net start w32time >> "%LOG%" 2>&1
"%W32TM_EXE%" /resync >> "%LOG%" 2>&1

echo Time/date sync repair finished.
echo [Step] Time sync repair finished. >> "%LOG%"
exit /b 0

:COMPONENTCLEANUP
echo.
echo [Step] Running Windows component cleanup...
echo This can take a long time.
echo [Step] Component cleanup started. >> "%LOG%"

"%DISM_EXE%" /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1

echo Component cleanup finished.
echo [Step] Component cleanup finished. >> "%LOG%"
exit /b 0

:FIREWALLRESET
echo.
echo [Step] Resetting Windows Firewall rules...
echo WARNING: This removes custom firewall rules.
choice /c YN /n /m "Continue with firewall reset? Y/N: "
if not "!errorlevel!"=="1" (
    echo Firewall reset cancelled.
    echo [Step] Firewall reset cancelled by user. >> "%LOG%"
    exit /b 0
)
echo [Step] Firewall reset started. >> "%LOG%"

"%NETSH_EXE%" advfirewall reset >> "%LOG%" 2>&1

echo Windows Firewall reset finished.
echo [Step] Firewall reset finished. >> "%LOG%"
exit /b 0

:POWERFIX
echo.
echo [Step] Repairing power and sleep settings...
echo [Step] Power repair started. >> "%LOG%"

"%POWERCFG_EXE%" -restoredefaultschemes >> "%LOG%" 2>&1
"%POWERCFG_EXE%" /hibernate on >> "%LOG%" 2>&1
"%POWERCFG_EXE%" /energy /duration 30 /output "%ENERGY_REPORT%" >> "%LOG%" 2>&1

echo Power settings repaired. Energy report created on Desktop.
echo [Step] Power repair finished. >> "%LOG%"
exit /b 0

:QUICKREPORT
echo.
echo [Step] Creating quick repair report...
echo [Step] Quick report started. >> "%LOG%"

(
    echo ================================================================
    echo Windows Repair Quick Report
    echo Created: %date% %time%
    echo Computer: %COMPUTERNAME%
    echo User: %USERNAME%
    echo Desktop Path: %DESKTOP_DIR%
    echo Documents Path: %DOCUMENTS_DIR%
    echo Downloads Path: %DOWNLOADS_DIR%
    echo System Folder: %SYS_DIR%
    echo DISM: %DISM_EXE%
    echo SFC: %SFC_EXE%
    echo PowerShell: %PS%
    echo ================================================================
    echo.
    echo --- Windows Version ---
    ver
    echo.
    echo --- System Info Short ---
    "%SYSTEMINFO_EXE%" | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory" /C:"Available Physical Memory"
    echo.
    echo --- Disk Status ---
    "%WMIC_EXE%" diskdrive get model,status
    echo.
    echo --- IP Configuration ---
    "%IPCONFIG_EXE%" /all
) > "%REPORT%" 2>> "%LOG%"

echo Quick report created:
echo %REPORT%
echo [Step] Quick report finished. >> "%LOG%"
exit /b 0


:RESTOREPOINT
echo.
echo [Step] Creating system restore point...
echo If System Protection is disabled, Windows may skip this step.
echo [Step] Restore point creation started. >> "%LOG%"

"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "try { Checkpoint-Computer -Description 'Before Windows Repair Tool' -RestorePointType 'MODIFY_SETTINGS'; Write-Output 'Restore point command completed.' } catch { Write-Output $_ }" >> "%LOG%" 2>&1

echo Restore point step finished.
echo [Step] Restore point creation finished. >> "%LOG%"
exit /b 0

:DEFENDERSCAN
echo.
echo [Step] Running Microsoft Defender quick scan...
echo [Step] Defender quick scan started. >> "%LOG%"

"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "try { Start-MpScan -ScanType QuickScan } catch { Write-Output $_ }" >> "%LOG%" 2>&1

echo Defender quick scan finished.
echo [Step] Defender quick scan finished. >> "%LOG%"
exit /b 0

:SEARCHINDEX
echo.
echo [Step] Repairing Windows Search index...
echo This restarts the search service and rebuilds the Windows search index.
echo WARNING: Search may be slow until Windows finishes rebuilding the index.
choice /c YN /n /m "Continue with search index rebuild? Y/N: "
if not "!errorlevel!"=="1" (
    echo Search index rebuild cancelled.
    echo [Step] Windows Search repair cancelled by user. >> "%LOG%"
    exit /b 0
)
echo [Step] Windows Search repair started. >> "%LOG%"

net stop WSearch >> "%LOG%" 2>&1
del /f /q "%ProgramData%\Microsoft\Search\Data\Applications\Windows\Windows.edb" >> "%LOG%" 2>&1
net start WSearch >> "%LOG%" 2>&1
"%CONTROL_EXE%" /name Microsoft.IndexingOptions >> "%LOG%" 2>&1

echo Windows Search index repair finished.
echo [Step] Windows Search repair finished. >> "%LOG%"
exit /b 0

:BATTERYREPORT
echo.
echo [Step] Creating battery health report...
echo [Step] Battery report started. >> "%LOG%"

"%POWERCFG_EXE%" /batteryreport /output "%BATTERY_REPORT%" >> "%LOG%" 2>&1

echo Battery report created on Desktop:
echo %BATTERY_REPORT%
echo [Step] Battery report finished. >> "%LOG%"
exit /b 0

:MEMORYDIAG
echo.
echo [Step] Opening Windows Memory Diagnostic...
echo Choose restart now or check next time from the window that opens.
echo [Step] Memory diagnostic opened. >> "%LOG%"

"%MDSCHED_EXE%" >> "%LOG%" 2>&1

echo Memory diagnostic tool opened.
echo [Step] Memory diagnostic step finished. >> "%LOG%"
exit /b 0

:FINISH
echo.
echo ================================================================
echo Repair finished.
echo Log saved here:
echo %LOG%
echo.
echo Recommended next steps:
echo 1. Restart your PC after major repairs.
echo 2. Open Windows Update and check for updates.
echo 3. If a problem remains, open the log file and check the failed step.
echo 4. Press any key to return to the menu.
echo ================================================================
echo Finished step: %date% %time% >> "%LOG%"
echo ================================================================ >> "%LOG%"
echo.
pause >nul
exit /b 0

:END
(
    echo ================================================================
    echo Tool closed: %date% %time%
    echo ================================================================
) >> "%LOG%"
endlocal
exit
