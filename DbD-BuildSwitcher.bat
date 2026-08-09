@echo off
setlocal EnableExtensions
set "DBDBSVer=3.2"
title DbD-BuildSwitcher v%DBDBSVer%

set "APPDATA_DIR=%LOCALAPPDATA%\elNino0916\DbD-BuildSwitcher"
set "DISCLAIMER_FILE=%APPDATA_DIR%\.disclaimershown"

echo.
echo  ====================================================================
echo                            DbD-BuildSwitcher v%DBDBSVer%
echo                         Copyright (c) 2026 elNino0916
echo  ====================================================================
echo.

if not exist "%DISCLAIMER_FILE%" (
echo  DISCLAIMER
echo  --------------------------------------------------------------------
echo  DbD-BuildSwitcher is an independent, fan-made project.
echo.
echo  This project is not affiliated with, endorsed by, sponsored by,
echo  or approved by Behaviour Interactive Inc.
echo.
echo  "Dead by Daylight" is a trademark of Behaviour Interactive Inc.
echo  The use of the name "Dead by Daylight" is solely for identification
echo  of the game this fan-made tool is intended to work with.
echo  --------------------------------------------------------------------
echo.
echo Press any key to acknowledge this disclaimer.
echo Subsequent launches will not present this disclaimer again.
echo.

pause > NUL

if not exist "%APPDATA_DIR%" (
    mkdir "%APPDATA_DIR%" >nul 2>&1
)

type NUL > "%DISCLAIMER_FILE%"

)
if exist "%DISCLAIMER_FILE%" (
echo  --------------------------------------------------------------------
echo  This project is not affiliated with, endorsed by, sponsored by,
echo  or approved by Behaviour Interactive Inc.
echo  "Dead by Daylight" is a trademark of Behaviour Interactive Inc.
echo  The use of the name "Dead by Daylight" is solely for identification
echo  of the game this fan-made tool is intended to work with.
echo  --------------------------------------------------------------------
echo.
echo.
)

set "SCRIPT=%~dp0DbD-BuildSwitcher.ps1"
echo [INFO] Checking dependencies...
if not exist "%SCRIPT%" (
color 0C
echo.
echo  [ERROR] PowerShell script not found.
echo.
echo  Expected:
echo  "%SCRIPT%"
echo.
pause
exit /b 1
)

echo [INFO; OK] Dependencies verified
echo [INFO] Starting PowerShell...

powershell.exe ^
-NoProfile ^
-ExecutionPolicy Bypass ^
-WindowStyle Hidden ^
-File "%SCRIPT%"

if errorlevel 1 (
color 0C
echo.
echo  [ERROR] DbDBS exited with an error.
echo.
echo  Exit code: %ERRORLEVEL%
echo.
pause
exit /b %ERRORLEVEL%
)

echo Cleaning up...
endlocal
exit /b 0
