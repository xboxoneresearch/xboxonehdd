@Echo Off
SETLOCAL EnableDelayedExpansion
::  Author:  XFiX
::  Date:    2016/06/30
::  Version: 5.0
::
::  Summary:
::  Create a true Xbox One 500GB, 1TB, or 2TB filesystem
::  This process is not a hack anymore
::  Past methods stretched a 500GB's filesystem
::  Now we create a resettable 500GB/1TB/2TB drive on ANY Xbox One OG/S console
::  Use at your own risk
::
::  TODO: Add true multilingual support
::
::  Change History:
::  2016/06/30 - Initial Release - XFiX
::  2016/08/10 - Use devcon to reset USB drives (Redacted) - XFiX
::  2016/10/18 - List Partition Sizes - XFiX
::  2017/05/12 - Added Englishize Cmd v1.7a Support - XFiX
::  2017/05/24 - Official 1TB and 2TB GUID Support - XFiX
::
::  Credit History:
::  2013/11 - Juvenal of Team Xecuter created the first working Python script
::  http://team-xecuter.com/forums/threads/141568-XBOX-ONE-How-To-Install-A-Bigger-Hard-Drive-%21
::
::  2014/07 - Ludvik Jerabek created the first bash script
::  http://www.ludvikjerabek.com/2014/07/14/xbox-one-fun-with-gpt-disk/
::
::  2016/06 - XFiX created a Windows batch script based on the bash script
::  https://www.youtube.com/playlist?list=PLURaLwRqr6g14Pl8qLO0E4ELBBCHfFh1V
::
::  2017/05 - A1DR1K discovered the secret behind what differentiates
::  500GB, 1TB, and 2TB Xbox One system hard drives
::  https://www.reddit.com/user/A1DR1K
::
::  Englishize Cmd v1.7a
::  https://wandersick.blogspot.com/p/change-non-english-command-line.html


:: Changeable drive letters
:: I've used higher letters to avoid conflicts
set TEMP_CONTENT_LETTER=U:
set USER_CONTENT_LETTER=V:
set SYSTEM_SUPPORT_LETTER=W:
set SYSTEM_UPDATE_LETTER=X:
set SYSTEM_UPDATE2_LETTER=Y:


title Create Xbox One Drive
set XBO_LOG=%TEMP%\create_xbox_drive.log
set XBO_VER=2017.05.24

echo Ver: %XBO_VER% > %XBO_LOG% 2>&1
date /T >> %XBO_LOG% 2>&1
time /T >> %XBO_LOG% 2>&1

cls
echo.
echo **********************************************************************
echo * create_xbox_drive.bat:                                             *
echo * This script creates a correctly formated Xbox One HDD against the  *
echo * drive YOU select.                                                  *
echo * USE AT YOUR OWN RISK                                               *
echo *                                                                    *
echo * Created      2016.06.30                                            *
echo * Last Updated %XBO_VER%                                            *
echo **********************************************************************
echo.
echo * This script will temporarily change the command line interface to  *
echo * English and change it back when complete.                          *
echo.

pause

:: Attempt to force English so that diskpart.exe output can be parsed correctly
cd %~dp0\Englishize_Cmd
call englishize_xfix.bat
cd ..


:: How To Check If Computer Is Running A 32 Bit or 64 Bit Operating System. http://support.microsoft.com/kb/556009
:: GPT fdisk is a disk partitioning tool loosely modeled on Linux fdisk, but used for modifying GUID Partition Table (GPT) disks:
:: https://sourceforge.net/projects/gptfdisk/
for /f "tokens=3" %%A in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v Identifier ^| findstr /b /r /c:" *Identifier"') do (set WINBIT=%%A)
if "%WINBIT%" == "x86" (
        echo "This is a 32 Bit Operating System"
        set XBO_DEVCON=devcon32
	set XBO_GDISK=gdisk32
) else (
        echo "This is a 64 Bit Operating System"
        set XBO_DEVCON=devcon64
	set XBO_GDISK=gdisk64
)

:: Specify locations of the tools below
:: Avoid: Invalid number.  Numbers are limited to 32-bits of precision.
:: A super-duper simple command line calculator that is fast and easy to use:
:: https://sourceforge.net/projects/cmdlinecalc/
set XBO_CALC=calc
:: Check for the presence of a drive other than C:
:: diskpart.exe http://support.microsoft.com/kb/300415/
set XBO_DISKPART=%SystemRoot%\system32\diskpart
set XBO_FORMAT=%SystemRoot%\system32\format
set XBO_MOUNTVOL=%SystemRoot%\system32\mountvol

set XBO_DP_SCRIPT=%TEMP%\dps.txt
set XBO_GD_SCRIPT=%TEMP%\gds.txt
set XBO_TIMEOUT=30

:: Common GUIDs used by Xbox One
set DISK_GUID_2TB=5B114955-4A1C-45C4-86DC-D95070008139
set DISK_GUID_1TB=25E8A1B2-0B2A-4474-93FA-35B847D97EE5
set DISK_GUID_500GB=A2344BDB-D6DE-4766-9EB5-4109A12228E5
set TEMP_CONTENT_GUID=B3727DA5-A3AC-4B3D-9FD6-2EA54441011B
set USER_CONTENT_GUID=869BB5E0-3356-4BE6-85F7-29323A675CC7
set SYSTEM_SUPPORT_GUID=C90D7A47-CCB9-4CBA-8C66-0459F6B85724
set SYSTEM_UPDATE_GUID=9A056AD7-32ED-4141-AEB1-AFB9BD5565DC
set SYSTEM_UPDATE2_GUID=24B2197C-9D01-45F9-A8E1-DBBCFA161EB2

:: Common partition sizes used by Xbox One
:: Xbox temp partition size (41G)
set XBOX_TEMP_SIZE_IN_BYTES=44023414784
:: Xbox support partition size (40G)
set XBOX_SUPPORT_SIZE_IN_BYTES=42949672960
:: Xbox update partition size (12G)
set XBOX_UPDATE_SIZE_IN_BYTES=12884901888
:: Xbox update 2 partition size (7G)
set XBOX_UPDATE_SIZE2_IN_BYTES=7516192768


:scan
echo * Scanning for connected USB/SATA drives . . .                       *
:: Rescan for newly added devices
echo rescan > %XBO_DP_SCRIPT%
::%XBO_DISKPART% /s %XBO_DP_SCRIPT%
:: Look for drive candidates
:: List will not include USB flash drives (according to Microsoft)
echo list disk > %XBO_DP_SCRIPT%
%XBO_DISKPART% /s %XBO_DP_SCRIPT%
echo.
%XBO_DISKPART% /s %XBO_DP_SCRIPT% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1


:: Ignore the header (Disk ###) and Disk 0 lines
::%XBO_DISKPART% /s %XBO_DP_SCRIPT% | findstr /b /r /c:" *Disk [^#0]" | find /c "Disk"
:: CHANGEME: The word "Disk" in English may be a different for your language
:: For example: Portuguese and Spanish users must change " *Disk [^#0]" ^| find /c "Disk"') with " *Disco [^#0]" ^| find /c "Disco"')
for /f "tokens=*" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:" *Disk [^#0]" ^| find /c "Disk"') do (set XBO_DRIVE_COUNT=%%A)
set XBO_CNT=0
set XBO_CHOICE=
::echo * Testing: Valid drive count: '%XBO_DRIVE_COUNT%'                                    *
if %XBO_DRIVE_COUNT% EQU 0 goto ndrive

:lchoice
set /a XBO_CNT+=1
set XBO_CHOICE=%XBO_CHOICE%%XBO_CNT%
::echo * Testing: Valid drive list: '%XBO_CNT%'                                     *
if %XBO_CNT% EQU %XBO_DRIVE_COUNT% goto rchoice
goto lchoice


:rchoice
::echo * Testing: Choice list: %XBO_CHOICE% *
echo * Select disk to format as an Xbox One Drive . . .                   *
choice.exe /C 0%XBO_CHOICE% /D 0 /T %XBO_TIMEOUT% /M "Press 0 to CANCEL or use a Disk Number from the list above (default 0 in %XBO_TIMEOUT% seconds)"
set /a XBO_FORMAT_DRIVE=%ERRORLEVEL%-1
:: CHANGEME: Comment out the line below with "::" if you want to allow disk 0 selection
if %XBO_FORMAT_DRIVE% EQU 0 goto edrive


CALL :GetSect
CALL :GetBlock
echo Selected drive: %XBO_FORMAT_DRIVE% >> %XBO_LOG% 2>&1
echo Sectors: %XBO_DISK_SECTORS% >> %XBO_LOG% 2>&1
echo Logical block size: %DEV_LOGICAL_BLOCK_SIZE_IN_BYTES% >> %XBO_LOG% 2>&1
CALL :ListPart


choice.exe /M "WARNING: This will erase all data on this disk. Continue "
if ERRORLEVEL 2 goto edrive

echo.
set XBO_MESSAGE=* Disk %XBO_FORMAT_DRIVE% will be formatted as an Xbox One . . .                      *
echo %XBO_MESSAGE%
echo %XBO_MESSAGE% >> %XBO_LOG% 2>&1
:rpart


:: Start of diskpart remove existing partitions (works but clunky since partitions have to be removed individually)
:: Replaced with gdisk (remove existing partitions)
::echo select disk %XBO_FORMAT_DRIVE% > %XBO_DP_SCRIPT%
::echo list partition >> %XBO_DP_SCRIPT%
:: Determine the number of partitions to delete
::for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:" *Partition [^#]" ^| sort /r') do (
    :: When the first partition is removed all other partitions cascade down
    ::echo select partition %%A >> !XBO_DP_SCRIPT!
    ::echo delete partition override >> !XBO_DP_SCRIPT!
::)

::echo p > %XBO_GD_SCRIPT%
::for /f "tokens=*" %%A in ('%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% ^< %XBO_GD_SCRIPT% ^| find /c "GPT: present"') do (set XBO_IS_GPT=%%A)
:: If already a GPT disk skip "convert gpt"
::if %XBO_IS_GPT% EQU 1 goto sgpt
::echo convert gpt >> %XBO_DP_SCRIPT%
:sgpt

:: Make destructive drive changes
::%XBO_DISKPART% /s %XBO_DP_SCRIPT%
:: End of diskpart remove existing partitions (works but clunky since partitions have to be removed individually)


:: Calculate partition sizes, creation moved to gdisk below
:: Partition 1: Temp Content
CALL :Calc %XBOX_TEMP_SIZE_IN_BYTES%/1024/1024
echo * Temp Content: MByte Size: '%XBO_CALC_RESULT%'                                  * >> %XBO_LOG% 2>&1
set /a XBOX_TEMP_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_TEMP_SIZE_IN_MBYTES% offset=1024 >> %XBO_DP_SCRIPT%

:selsize
echo.
echo Select partition layout:
set XBO_SIZE=
echo (a) Autosize Non-Standard
echo (b) 500GB Standard
echo (c) 1TB Standard
echo (d) 2TB Standard
echo.
set /p XBO_SIZE=?
echo.
if not '%XBO_SIZE%'=='' set choice=%choice:~0,1%
if '%XBO_SIZE%'=='a' goto sizea
if '%XBO_SIZE%'=='b' goto sizeb
if '%XBO_SIZE%'=='c' goto sizec
if '%XBO_SIZE%'=='d' goto sized
echo "%XBO_SIZE%" is not valid please try again
echo.
goto selsize

:: Partition 2: User Content

:sizea
:: Treat all Non-Standard size drives as 500GB drives but add the spare space to 'User Content'
set DISK_GUID=%DISK_GUID_500GB%
set DISK_NAME=(Auto)
:: Size of the device in bytes
CALL :Calc %XBO_DISK_SECTORS%*%DEV_LOGICAL_BLOCK_SIZE_IN_BYTES%
:: New user content partition size (eg. Using a 500G drive it's rougly 392733679616 bytes = 365G )
CALL :Calc %XBO_CALC_RESULT%-%XBOX_TEMP_SIZE_IN_BYTES%-%XBOX_SUPPORT_SIZE_IN_BYTES%-%XBOX_UPDATE_SIZE_IN_BYTES%-%XBOX_UPDATE_SIZE2_IN_BYTES%
echo * User Content: Byte Size:  '%XBO_CALC_RESULT%'                           * >> %XBO_LOG% 2>&1
:: Align the data to the nearest gig
CALL :Calc %XBO_CALC_RESULT%/1024/1024/1024
echo * User Content: GByte Size: '%XBO_CALC_RESULT%'                                    * >> %XBO_LOG% 2>&1
CALL :Calc %XBO_CALC_RESULT%*1024
goto finsize

:sizeb
:: Could force all drives >500GB to be 500GB equivalent
set DISK_GUID=%DISK_GUID_500GB%
set DISK_NAME=(500GB)
:: Xbox One Standard 500GB User Partion
CALL :Calc 391915765760/1024/1024
:: CHANGEME: Xbox One Large 500GB User Partion
::CALL :Calc 392732606464/1024/1024
goto finsize

:sizec
:: Could force all drives >1TB to be 1TB equivalent
set DISK_GUID=%DISK_GUID_1TB%
set DISK_NAME=(1TB)
:: Xbox One Standard 1TB User Partion
CALL :Calc 838592364544/1024/1024
:: CHANGEME: Xbox One Large 1TB User Partion
::CALL :Calc 892828909568/1024/1024
goto finsize

:sized
:: Could force all drives >2TB to be 2TB equivalent
set DISK_GUID=%DISK_GUID_2TB%
set DISK_NAME=(2TB)
:: Xbox One Standard 2TB User Partion
CALL :Calc 1784558911488/1024/1024
:: CHANGEME: Xbox One Large 2TB User Partion
::CALL :Calc 1893023612928/1024/1024
goto finsize

:finsize
echo * User Content: MByte Size: '%XBO_CALC_RESULT%'                                 * >> %XBO_LOG% 2>&1
set /a XBOX_USER_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_USER_SIZE_IN_MBYTES% >> %XBO_DP_SCRIPT%

:: Partition 3: System Support
CALL :Calc %XBOX_SUPPORT_SIZE_IN_BYTES%/1024/1024
echo * System Support: MByte Size: '%XBO_CALC_RESULT%'                                * >> %XBO_LOG% 2>&1
set /a XBOX_SUPPORT_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_SUPPORT_SIZE_IN_MBYTES% >> %XBO_DP_SCRIPT%

:: Partition 4: System Update
CALL :Calc %XBOX_UPDATE_SIZE_IN_BYTES%/1024/1024
echo * System Update: MByte Size: '%XBO_CALC_RESULT%'                                 * >> %XBO_LOG% 2>&1
set /a XBOX_UPDATE_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_UPDATE_SIZE_IN_MBYTES% >> %XBO_DP_SCRIPT%

:: Partition 5: System Update 2
CALL :Calc %XBOX_UPDATE_SIZE2_IN_BYTES%/1024/1024
echo * System Update 2: MByte Size: '%XBO_CALC_RESULT%'                                * >> %XBO_LOG% 2>&1
set /a XBOX_UPDATE_SIZE2_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_UPDATE_SIZE2_IN_MBYTES% >> %XBO_DP_SCRIPT%


:: Start of gdisk remove existing partitions (destroys all with one option)
:: Replaced with diskpart (remove existing partitions)
echo * Removing existing partitions with %XBO_GDISK% . . .                    *
echo o > %XBO_GD_SCRIPT%
echo y >> %XBO_GD_SCRIPT%
echo w >> %XBO_GD_SCRIPT%
echo y >> %XBO_GD_SCRIPT%
:: Make destructive GUID drive changes
echo. >> %XBO_LOG% 2>&1
%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% < %XBO_GD_SCRIPT% >> %XBO_LOG% 2>&1
:: End of gdisk remove existing partitions (destroys all with one option)


:: Create paritions and set GUID values
:: Windows doesn't like this much, works fine but Windows loses drive letters and things
echo * Creating new partitions with %XBO_GDISK% . . .                         *
echo x > %XBO_GD_SCRIPT%
echo g >> %XBO_GD_SCRIPT%
echo %DISK_GUID% >> %XBO_GD_SCRIPT%

echo m >> %XBO_GD_SCRIPT%
echo n >> %XBO_GD_SCRIPT%
echo 1 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +%XBOX_TEMP_SIZE_IN_MBYTES%M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%
echo x >> %XBO_GD_SCRIPT%
echo c >> %XBO_GD_SCRIPT%
:: Not needed when only one partition exists
::echo 1 >> %XBO_GD_SCRIPT%
echo %TEMP_CONTENT_GUID% >> %XBO_GD_SCRIPT%

echo m >> %XBO_GD_SCRIPT%
echo n >> %XBO_GD_SCRIPT%
echo 2 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +%XBOX_USER_SIZE_IN_MBYTES%M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%
echo x >> %XBO_GD_SCRIPT%
echo c >> %XBO_GD_SCRIPT%
echo 2 >> %XBO_GD_SCRIPT%
echo %USER_CONTENT_GUID% >> %XBO_GD_SCRIPT%

echo m >> %XBO_GD_SCRIPT%
echo n >> %XBO_GD_SCRIPT%
echo 3 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +%XBOX_SUPPORT_SIZE_IN_MBYTES%M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%
echo x >> %XBO_GD_SCRIPT%
echo c >> %XBO_GD_SCRIPT%
echo 3 >> %XBO_GD_SCRIPT%
echo %SYSTEM_SUPPORT_GUID% >> %XBO_GD_SCRIPT%

echo m >> %XBO_GD_SCRIPT%
echo n >> %XBO_GD_SCRIPT%
echo 4 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +%XBOX_UPDATE_SIZE_IN_MBYTES%M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%
echo x >> %XBO_GD_SCRIPT%
echo c >> %XBO_GD_SCRIPT%
echo 4 >> %XBO_GD_SCRIPT%
echo %SYSTEM_UPDATE_GUID% >> %XBO_GD_SCRIPT%

echo m >> %XBO_GD_SCRIPT%
echo n >> %XBO_GD_SCRIPT%
echo 5 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +%XBOX_UPDATE_SIZE2_IN_MBYTES%M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%
echo x >> %XBO_GD_SCRIPT%
echo c >> %XBO_GD_SCRIPT%
echo 5 >> %XBO_GD_SCRIPT%
echo %SYSTEM_UPDATE2_GUID% >> %XBO_GD_SCRIPT%

echo w >> %XBO_GD_SCRIPT%
echo y >> %XBO_GD_SCRIPT%

:: Make destructive GUID drive changes
%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% < %XBO_GD_SCRIPT% >> %XBO_LOG% 2>&1


:: CHANGEME: Comment out the line below with "::" if you want the option to
:: reset the disk after gdisk and before diskpart. Gdisk can take time to
:: apply requested changes thus the 30 second "time to settle" bit below.
goto nreset
echo.
echo.
echo If the drive is connected by USB you may want to choose "Y" here
echo This is equivalent to physically disconnecting and reconnecting the cable
choice.exe /M "Reset USB mass storage devices "
if ERRORLEVEL 2 goto nreset
echo. >> %XBO_LOG% 2>&1
%XBO_DEVCON% restart USB\ROOT_HUB20 >> %XBO_LOG% 2>&1
:nreset

echo.
echo.
:: gdisk creates partitions very quickly, perhaps too quickly?
:: diskpart will not see the newly created volumes correctly without pausing
start /wait choice.exe /N /C C /T %XBO_TIMEOUT% /D C /M "Giving USB/SATA devices time to settle, please wait . . ."

:: Check volume status
echo list volume > %XBO_DP_SCRIPT%
%XBO_DISKPART% /s %XBO_DP_SCRIPT%
echo.
%XBO_DISKPART% /s %XBO_DP_SCRIPT% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1


:: Use format instead of diskpart to add a volume label
:: format doesn't support spaces in volume labels, fix with diskpart in next step
echo * Formatting new partitions with %XBO_FORMAT% . . .    *
%XBO_FORMAT% \\?\Volume{%TEMP_CONTENT_GUID%} /FS:NTFS /V:Temp_Content /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{%USER_CONTENT_GUID%} /FS:NTFS /V:User_Content /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{%SYSTEM_SUPPORT_GUID%} /FS:NTFS /V:System_Support /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{%SYSTEM_UPDATE_GUID%} /FS:NTFS /V:System_Update /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{%SYSTEM_UPDATE2_GUID%} /FS:NTFS /V:System_Update_2 /Q /Y >> %XBO_LOG% 2>&1


:: Finally use diskpart to format and assign drive letters so that we can copy files
echo * Formatting and assigning drive letters with %XBO_DISKPART% . . .
:: Rescan for newly added devices
echo rescan > %XBO_DP_SCRIPT%
echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*Temp_Conten"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="Temp Content" QUICK NOERR >> !XBO_DP_SCRIPT!
    echo assign letter=!TEMP_CONTENT_LETTER! NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)


echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*User_Conten"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="User Content" QUICK NOERR >> !XBO_DP_SCRIPT!
    echo assign letter=!USER_CONTENT_LETTER! NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*System_Supp"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="System Support" QUICK NOERR >> !XBO_DP_SCRIPT!
    echo assign letter=!SYSTEM_SUPPORT_LETTER! NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*System_Upda.*12"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="System Update" QUICK NOERR >> !XBO_DP_SCRIPT!
    echo assign letter=!SYSTEM_UPDATE_LETTER! NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*System_Upda.*7168"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="System Update 2" QUICK NOERR >> !XBO_DP_SCRIPT!
    echo assign letter=!SYSTEM_UPDATE2_LETTER! NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

:: Check volume status
echo list volume > %XBO_DP_SCRIPT%
%XBO_DISKPART% /s %XBO_DP_SCRIPT%
echo.
%XBO_DISKPART% /s %XBO_DP_SCRIPT% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1

if exist %SYSTEM_UPDATE_LETTER%\ goto dexists
goto ndrive

:ndrive
set XBO_MESSAGE=* No USB/SATA drives found                                           *
goto endbat

:edrive
set XBO_MESSAGE=* Xbox One Drive Selection Cancelled                                 *
goto endbat

:dexists
set XBO_MESSAGE=* Found the %SYSTEM_UPDATE_LETTER% drive.                                                *
echo.

CALL :ListPart
goto endbat



:: FUNCTIONS

:Calc
:: Round down all sizes
for /f "tokens=1" %%A in ('%XBO_CALC% Floor^(%1^)') do (
    set XBO_CALC_RESULT=%%A
)
GOTO:EOF


:GetSect
echo p > %XBO_GD_SCRIPT%
for /f "tokens=7" %%A in ('%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% ^< %XBO_GD_SCRIPT% ^| findstr /b /r /c:".*Disk \\\\.\\physicaldrive.:"') do (
    set XBO_DISK_SECTORS=%%A
)
GOTO:EOF


:GetBlock
echo p > %XBO_GD_SCRIPT%
for /f "tokens=4" %%A in ('%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% ^< %XBO_GD_SCRIPT% ^| findstr /b /r /c:".*Logical sector size:"') do (
    set DEV_LOGICAL_BLOCK_SIZE_IN_BYTES=%%A
)
GOTO:EOF


:ListPart
:: start of list_part_info.sh equivalent
echo select disk %XBO_FORMAT_DRIVE% > %XBO_DP_SCRIPT%
echo detail disk >> %XBO_DP_SCRIPT%
:: Get Disk GUID
for /f "tokens=2* delims={}" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:"Disk ID"') do (
    set XBO_DISK_GUID=%%A
)

echo.
echo GUID                                 Dev Size    Name
echo %XBO_DISK_GUID%             %DISK_NAME%

echo. >> %XBO_LOG% 2>&1
echo GUID                                 Dev Size    Name >> %XBO_LOG% 2>&1
echo %XBO_DISK_GUID%             %DISK_NAME% >> %XBO_LOG% 2>&1

set /a XBO_PART_CNT=0
:: Get Volume GUID(s)- 1st get drive letters
for /f "tokens=3,4,5,8,9" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:" *Volume [^#0]"') do (
    set /a XBO_PART_CNT+=1
    set XBO_PART!XBO_PART_CNT!_LETTER=%%A:
    set XBO_PART!XBO_PART_CNT!_SIZE=%%D %%E
    CALL :StrLen LEN XBO_PART!XBO_PART_CNT!_SIZE
    CALL :Calc 7-!LEN!
    CALL :GetSpaces SPC XBO_CALC_RESULT
    set XBO_PART!XBO_PART_CNT!_SIZEP=!SPC!%%D %%E
    :: 2nd get GUID(s)
    for /f "tokens=2 delims={}" %%G in ('%XBO_MOUNTVOL% %%A:\ /L ^| findstr /b /r /c:" *\\\\?\\Volume"') do (
        set XBO_PART!XBO_PART_CNT!_GUID=%%G
        CALL :UpCase XBO_PART!XBO_PART_CNT!_GUID
    )
    :: 3rd get volume labels
    for /f "tokens=6*" %%V in ('vol %%A: ^| findstr /b /r /c:" *Volume in drive"') do (
        set XBO_PART!XBO_PART_CNT!_NAME=%%V %%W
    )
    CALL :PrtPart XBO_PART!XBO_PART_CNT!_GUID XBO_PART!XBO_PART_CNT!_LETTER XBO_PART!XBO_PART_CNT!_SIZEP XBO_PART!XBO_PART_CNT!_NAME
)
echo.
echo. >> %XBO_LOG% 2>&1
GOTO:EOF
:: end of list_part_info.sh equivalent


:PrtPart
echo !%1! !%2!  !%3! '!%4!'
echo !%1! !%2!  !%3! '!%4!' >> %XBO_LOG% 2>&1
GOTO:EOF


:UpCase
:: Subroutine to convert a variable VALUE to all UPPER CASE.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF


:StrLen <resultVar> <stringVar>
(
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" (
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
(
    endlocal
    set "%~1=%len%"
    GOTO:EOF
)


:GetSpaces <resultVar> <numericVar>
(
    setlocal EnableDelayedExpansion
    set "s=!%~2!"
    set "spc="
    for /l %%I IN (1,1,!s!) do (
        set "spc=!spc! "
    )
)
(
    endlocal
    set "%~1=%spc%"
    GOTO:EOF
)


:endbat
echo.
echo %XBO_MESSAGE%

echo. >> %XBO_LOG% 2>&1
echo %XBO_MESSAGE% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1
date /T >> %XBO_LOG% 2>&1
time /T >> %XBO_LOG% 2>&1

echo.
echo * Script execution complete.                                         *
echo.
echo * This script will now change the command line interface back to the *
echo * default language.                                                  *
echo.
pause


:: Attempt to restore everything back to original language
cd %~dp0\Englishize_Cmd
call restore_xfix.bat
cd ..

ENDLOCAL
