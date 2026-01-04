@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Windows Runtime Installer

echo =========================================
echo   Windows Runtime Installer
echo =========================================
echo.

REM Ensure script runs from its own directory
cd /d "%~dp0"

echo Installing Microsoft Visual C++ Runtimes...
echo -----------------------------------------
call "Microsoft-Visual-C-Runtimes-ALL-Install\install_all.bat"

echo.
echo Installing .NET SDKs...
echo -----------------------------------------
for %%F in ("DotNet-SDK\*.exe") do (
    echo Installing %%~nxF
    start /wait "" "%%F" /quiet /norestart
)

echo.
echo =========================================
echo   All runtime installations complete
echo =========================================
echo.

echo If no errors appeared above, installation was successful.
echo Press any key to close this window.
pause >nul
