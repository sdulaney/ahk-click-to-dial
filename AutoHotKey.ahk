#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance,Force

;******If ini file doesnt exist, run the GUI to create one
IfNotExist, %A_AppData%\Cuda.ini
{
Gui, Add, Text, x22 y19 w120 h20, Extension / Username:
Gui, Add, Text,x22 y59 w120 h20, Password:
Gui, Add, Text,x22 y99 w120 h20, Server IP/Hostname:
Gui, Add, Edit, x162 y19 w140 h20 vFirstName  ;This is the extension
Gui, Add, Edit, vLastName x162 y59 w140 h20 Password, Password
Gui, Add, Edit, x162 y99 w140 h20 vServerIP
Gui, Add, Button, x42 y159 w120 h30 default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
Gui, Add, Button,x192 y159 w110 h30,Cancel
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

GuiClose:
ButtonCancel:
MsgBox No settings have been saved
ExitApp
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.
MsgBox Your settings for %FirstName% have been saved.
IniWrite,%FirstName%,%A_AppData%\Cuda.ini,section1,Ext
IniWrite,%LastName%,%A_AppData%\Cuda.ini,section1,PW
IniWrite,%ServerIP%,%A_AppData%\Cuda.ini,section1,IP
return
}


;### Copy selection to clipboard, clean up selection, pass to API ###
#m::
;Copy Clipboard to prevClipboard variable, clear Clipboard.
  prevClipboard := ClipboardAll
  Clipboard =
;Copy current selection, continue if no errors.
  SendInput, ^c
  ClipWait, 2
  if !(ErrorLevel) {
;Convert Clipboard to text, auto-trim leading and trailing spaces and tabs.
    Clipboard = %Clipboard%
;Clean Clipboard: change carriage returns to spaces, change >=1 consecutive spaces to +
    Clipboard := RegExReplace(RegExReplace(Clipboard, "\r?\n"," "), "\s+","+")
;Open URLs, Google non-URLs. URLs contain . but do not contain + or .. or @
    IniRead, Ext, %A_AppData%\Cuda.ini, section1, Ext
    IniRead, PW, %A_AppData%\Cuda.ini, section1, PW
    IniRead, IP, %A_AppData%\Cuda.ini, section1, IP
;    MsgBox, The value is http://%IP%/gui/freeswitch/originate?__auth_user=%Ext%&__auth_pass=%PW%&destination=%Clipboard%
    UrlDownloadToFile, http://%IP%/gui/freeswitch/originate?__auth_user=%Ext%&__auth_pass=%PW%&destination=%Clipboard%, C:\cuda.html
  }
;Restore Clipboard, clear prevClipboard variable.
  Clipboard := prevClipboard
  prevClipboard =
return
