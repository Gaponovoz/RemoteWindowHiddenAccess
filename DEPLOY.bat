
@echo off
echo ...it is recommended to disable antivirus software that may prevent this script from adding server app to startup/desktop...

SET mypath=%~dp0
if NOT "%mypath%"=="C:\master-server\" goto noway

set dkey=Desktop
set dump=powershell.exe -NoLogo -NonInteractive "Write-Host $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::%dkey%))"
for /F %%i in ('%dump%') do set dir=%%i

copy /y "C:\master-server\ServerStartupper.link" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\ServerStartupper.lnk"
copy /y "C:\master-server\Master (admin panel).link" "%dir%\Master (admin panel).lnk"

start %APPDATA%\Microsoft\Windows\"Start Menu"\Programs\Startup\"ServerStartupper".lnk





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
