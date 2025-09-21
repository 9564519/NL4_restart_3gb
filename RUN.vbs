Set objShell = WScript.CreateObject("WScript.Shell")
strCommand = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""D:\PS1\NL4_restart_3gb\NL4_restart_3gb.ps1"""
objShell.Run strCommand, 0, True