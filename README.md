# Xbox One HDD tools
Source: https://gbatemp.net/download/xbox-one-windows-and-linux-internal-hard-drive-partitioning-script.34239/

## Why this mirror?
Easier to diff changes ;)

## Original script
https://github.com/Juvenal1/xboxonehdd

## Windows script 9.0

`win/create_xbox_drive.bat` version 9.0 (2026-10-21) runs on Windows 10 and Windows 11.

Windows 11 does not include `wmic.exe`. Logical disks are read with Windows PowerShell (`Get-CimInstance Win32_LogicalDisk`). The script still assigns `U:`–`Y:` to the Xbox drive and `H:`–`L:` to the copy. It removes the current letters first, then assigns the new ones and checks that each volume label is on the expected letter.
