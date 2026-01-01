@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
COLOR 0A
TITLE INSTALL ALL MICROSOFT VISUAL C^+^+ PACKAGES

:----------------------------------------------------------------------------------

PUSHD "%~dp0"
IF NOT "%1"=="MAX" START /MAX CMD /D /C %0 MAX & GOTO :EOF

:----------------------------------------------------------------------------------

REM KILL ANY RUNNING INSTANCES OF DISM OR TIWORKER TO AVOID ERRORS
TASKLIST | FINDSTR "Dism.exe TiWorker.exe" >NUL && TASKKILL /F /IM "Dism.exe" /IM "TiWorker.exe" /T >NUL 2>&1

:----------------------------------------------------------------------------------

SETLOCAL ENABLEEXTENSIONS
CALL "DotNet-SDK\dotnet.bat"
ENDLOCAL

SETLOCAL ENABLEEXTENSIONS
CALL "Microsoft-Visual-C-Runtimes-ALL-Installers\msft.bat"
ENDLOCAL

SETLOCAL ENABLEEXTENSIONS
CALL "DirectX-June-2010-Redist\directx.bat"
ENDLOCAL

:----------------------------------------------------------------------------------

CLS
ECHO Successfully installed all Microsoft's Visual C Runtimes, DotNet SDK LTS Runtimes, and DirectX!
ECHO=
ECHO Your computer must be happier!
ECHO=
ECHO Press Enter to exit.
PAUSE >NUL
