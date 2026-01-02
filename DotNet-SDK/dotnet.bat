@echo off
setlocal
cd /d "%~dp0"

for %%F in (*.exe) do (
  echo Installing %%~nxF ...
  start /wait "" "%%~fF" /install /quiet /norestart
)

echo Done.
exit /b 0
