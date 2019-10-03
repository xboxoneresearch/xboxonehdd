' Subscript of Cmd Dict by wanderSick
' See main script -- fy.cmd -- for more details.

' Used to run desired programs as administrator (for Vista or later with UAC)
' Based on http://www.winhelponline.com/articles/185/1/VBScripts-and-UAC-elevation.html

Dim objShell, FSO
Dim strFolder, strFile
On Error Resume Next
Set objShell = CreateObject("Shell.Application")
Set FSO = CreateObject("Scripting.FileSystemObject")
strWorkDir = WScript.Arguments(0)
strFile = WScript.Arguments(1)
strArg = "/c start " & chr(34) & chr(34) & " /d " & chr(34) & strWorkDir & chr(34) & " " & chr(34) & strFile & chr(34)
'Debug line
'Msgbox strWorkDir & strFile & vbcrlf & strArg
If FSO.FileExists(strFolder & strFile) Then
     objShell.ShellExecute "cmd.exe", strArg, "", "runas", 1
Else
     MsgBox "File " & strFile & " not found."
End If