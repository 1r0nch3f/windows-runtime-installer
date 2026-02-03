@echo off
setlocal EnableExtensions

cd /d "%~dp0"

set "foundInstaller=0"

if exist "vc_redist.x64.exe" (
  set "foundInstaller=1"
  echo Installing vc_redist.x64.exe ...
  start /wait "" "vc_redist.x64.exe" /install /quiet /norestart
)

if exist "vc_redist.x86.exe" (
  set "foundInstaller=1"
  echo Installing vc_redist.x86.exe ...
  start /wait "" "vc_redist.x86.exe" /install /quiet /norestart
)

if "%foundInstaller%"=="0" (
  echo No Visual C++ redistributable installers were found in %cd%.
)

echo Done.
exit /b 0
