
@echo off

SET mypath=%~dp0
if NOT "%mypath%"=="C:\master-server\" goto noway

set dkey=Desktop
set dump=powershell.exe -NoLogo -NonInteractive "Write-Host $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::%dkey%))"
for /F %%i in ('%dump%') do set dir=%%i

echo cd C:\master-server >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\ServerStartupper.bat"
echo start /MIN C:\master-server\NodeServer\node.exe C:\master-server\NodeServer\server.js >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\ServerStartupper.bat"
echo exit >> "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\ServerStartupper.bat"
copy /y "C:\master-server\Master (admin panel).link" "%dir%\Master (admin panel).lnk"

start %APPDATA%\Microsoft\Windows\"Start Menu"\Programs\Startup\"ServerStartupper".bat



echo =============================================================
echo successfully added to startup, created shortcut and launched!
echo =============================================================
pause
exit

:noway
echo ==================================================
echo please install folder as "C:\master-server\" only.
echo you cant use it at %mypath%!!!
echo ==================================================
pause
exit
