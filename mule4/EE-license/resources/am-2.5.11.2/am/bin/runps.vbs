Dim objShell, objFSO
Set objShell=CreateObject("WScript.Shell")
Set objFSO=CreateObject("Scripting.FileSystemObject")
strPath=WScript.Arguments(0)
If objFSO.FileExists(strPath) Then
    strCMD="powershell -file " & Chr(34) & strPath & Chr(34)
    objShell.Run strCMD, 0
Else
    WScript.Echo "File does not exist: " & strPath
    WScript.Quit 1
End If
