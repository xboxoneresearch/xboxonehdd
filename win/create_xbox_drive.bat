@Echo Off
SETLOCAL EnableDelayedExpansion
::  Author:  XFiX
::  Date:    2018/11/13
::  Version: 8.0
::
::  Summary:
::  Create a true Xbox One 500GB, 1TB, or 2TB filesystem
::  This process is not a hack anymore
::  Past methods stretched a 500GB's filesystem
::  Now creates a resettable 500GB/1TB/2TB drive on ANY Xbox One OG/S/X Console
::  USE AT YOUR OWN RISK
::
::  TODO: Add true multilingual support
::
::  Change History:
::  2016/06/30 - Initial Release (2.0) - XFiX
::  2016/07/20 - Added Partition Size Selection (3.0) - XFiX
::  2016/08/10 - Use devcon to reset USB drives (4.0 Removed 5.0) - XFiX
::  2016/10/18 - List Partition Sizes (4.0) - XFiX
::  2017/05/12 - Added Englishize Cmd v1.7a Support (5.0 Removed 8.0) - XFiX
::  2017/05/24 - Official 1TB and 2TB GUID Support (5.0) - XFiX
::  2017/12/11 - Added "Run as administrator" check (6.0) - XFiX
::  2017/12/11 - Non-Standard larger than 2TB Support (6.0) - XFiX
::  2017/12/11 - Robocopy Standard to Non-Standard (6.0) - XFiX
::  2018/01/03 - Added \Windows\System32\en-US check (6.0) - XFiX
::  2018/01/31 - Allow selection of disk 0 (6.1) - XFiX
::  2018/01/31 - Only Backup "System Update" (6.1) - XFiX
::  2018/02/01 - Added :ChkForC to avoid destroying C: (6.1) - JCRocky5, XFiX
::  2018/03/12 - Better check for drive letter availability (7.0) - XFiX
::  2018/03/12 - Copy data to a local drive when only one SATA adapter is available (7.0) - XFiX
::  2018/04/26 - Find and log the current system language code (7.0) - XFiX
::  2018/04/26 - Warn drive size limitations and limit to 2TB "User Content" (7.0) - XFiX
::  2018/05/29 - Logging and path improvements (7.0) - XFiX
::  2018/06/19 - Preserve ACLs with robocopy /COPYALL (7.0 Removed 8.0) - XFiX
::  2018/11/13 - Removed Englishize Cmd v1.7a Usage (8.0) - XFiX
::  2018/11/13 - Support systems with 10 or more attached drives (8.0) - XFiX
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


:: CHANGEME: Changeable drive letters
:: I've used higher letters to avoid conflicts
:: A B C D E F G (H I J K L) M N O P Q R S T (U V W X Y) Z
:: DUPlicatE aka TARGET letters
set TEMP_CONTENT_LDUPE=H:
set USER_CONTENT_LDUPE=I:
set SYSTEM_SUPPORT_LDUPE=J:
set SYSTEM_UPDATE_LDUPE=K:
set SYSTEM_UPDATE2_LDUPE=L:
:: Xbox One aka SOURCE letters
set TEMP_CONTENT_LETTER=U:
set USER_CONTENT_LETTER=V:
set SYSTEM_SUPPORT_LETTER=W:
set SYSTEM_UPDATE_LETTER=X:
set SYSTEM_UPDATE2_LETTER=Y:

:: Specify locations of the tools below
:: Avoid: Invalid number. Numbers are limited to 32-bits of precision.
:: A super-duper simple command line calculator that is fast and easy to use:
:: https://sourceforge.net/projects/cmdlinecalc/
set XBO_CALC=calc
:: Check for the presence of a drive other than C:
:: diskpart.exe http://support.microsoft.com/kb/300415/
set XBO_ATTRIB=%SystemRoot%\system32\attrib
set XBO_CHKDSK=%SystemRoot%\system32\chkdsk
set XBO_DISKPART=%SystemRoot%\system32\diskpart
set XBO_EN_US=%SystemRoot%\system32\en-US\diskpart.exe.mui
set XBO_FORMAT=%SystemRoot%\system32\format
set XBO_LABEL=%SystemRoot%\system32\label
set XBO_MOUNTVOL=%SystemRoot%\system32\mountvol
set XBO_ROBOCOPY=%SystemRoot%\system32\robocopy
set XBO_WMIC=%SystemRoot%\system32\wbem\wmic

set XBO_CANCEL=0
set XBO_LOG=%TEMP%\create_xbox_drive.log
set XBO_VER=2018.11.13.8.0
title Create Xbox One Drive %XBO_VER%

echo Ver: %XBO_VER% > %XBO_LOG% 2>&1
date /T >> %XBO_LOG% 2>&1
time /T >> %XBO_LOG% 2>&1

for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language" /v InstallLanguage ^| findstr /b /r /c:" *InstallLanguage"') do (set LANGID=%%A)
echo Language ID: %LANGID% >> %XBO_LOG% 2>&1
for /f "tokens=3" %%A in ('reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages ^| findstr /b /r /c:" *PreferredUILanguages"') do (set LANGUI=%%A)
echo Language UI: %LANGUI% >> %XBO_LOG% 2>&1
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\LanguageOverlay\OverlayPackages\%LANGUI%" /v Latest ^| findstr /b /r /c:" *Latest"') do (set LANGPATH=%%A)
echo Language Path: %LANGPATH% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1
echo Current Directory Start: >> %XBO_LOG% 2>&1
cd >> %XBO_LOG% 2>&1

cls
echo.
echo **********************************************************************
echo * create_xbox_drive.bat:                                             *
echo * This script creates a correctly formatted Xbox One HDD against the *
echo * drive YOU select.                                                  *
echo * USE AT YOUR OWN RISK                                               *
echo *                                                                    *
echo * Created      2016.06.30.2.0                                        *
echo * Last Updated %XBO_VER%                                        *
echo * Language ID  %LANGID%                                                  *
echo * Language UI  %LANGUI%                                                 *
echo **********************************************************************
echo.
CALL :ChkPerms
if %XBO_PERMS% EQU 0 goto endall
::CALL :ChkEng
::if %XBO_PERMS% EQU 0 goto endall
CALL :ChkForLetters

::echo * This script will temporarily change the command line interface to  *
::echo * English and change it back when complete.                          *
echo.

pause

cd /D %~dp0
:: 2018/11/13 - Removed Englishize requirement
:: Attempt to force English so that diskpart.exe output can be parsed correctly
::cd /D %~dp0\Englishize_Cmd
::call englishize_xfix.bat
::cd ..
echo Current Directory Adjusted: >> %XBO_LOG% 2>&1
cd >> %XBO_LOG% 2>&1


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

set XBO_DP_SCRIPT=%TEMP%\dps.txt
set XBO_GD_SCRIPT=%TEMP%\gds.txt
set XBO_TIMEOUT=30
set XBO_LABEL_PREFIX=

:: Fake (DUPlicatE) GUIDs used to avoid drive conflicts on Windows (Offline signature collisions)
:: These need to be changed before Xbox One installation
set DISK_GDUPE=C2D8931D-F53C-4057-B8C0-945B128D7866
set TEMP_CONTENT_GDUPE=81002B01-E45E-4B55-A87B-6E3FC679856D
set USER_CONTENT_GDUPE=3AF0ED71-7DAE-4105-9ABB-46D6A4F35751
set SYSTEM_SUPPORT_GDUPE=F9C3D4AF-0F6A-4878-A702-6AB67E599979
set SYSTEM_UPDATE_GDUPE=E3833609-D4FC-4CF1-BCB6-7B8CDC46A44F
set SYSTEM_UPDATE2_GDUPE=7FCF2B0F-B6A0-42DA-9BF9-F3B26E70F2FC

:: Common GUIDs used by Xbox One
set DISK_GUID_2TB=5B114955-4A1C-45C4-86DC-D95070008139
set DISK_GUID_1TB=25E8A1B2-0B2A-4474-93FA-35B847D97EE5
set DISK_GUID_500GB=A2344BDB-D6DE-4766-9EB5-4109A12228E5
set TEMP_CONTENT_GUID=B3727DA5-A3AC-4B3D-9FD6-2EA54441011B
set USER_CONTENT_GUID=869BB5E0-3356-4BE6-85F7-29323A675CC7
set SYSTEM_SUPPORT_GUID=C90D7A47-CCB9-4CBA-8C66-0459F6B85724
set SYSTEM_UPDATE_GUID=9A056AD7-32ED-4141-AEB1-AFB9BD5565DC
set SYSTEM_UPDATE2_GUID=24B2197C-9D01-45F9-A8E1-DBBCFA161EB2

:: Common Xbox One Partition Labels
set TEMP_CONTENT_LABEL=Temp Content
set USER_CONTENT_LABEL=User Content
set SYSTEM_SUPPORT_LABEL=System Support
set SYSTEM_UPDATE_LABEL=System Update
set SYSTEM_UPDATE2_LABEL=System Update 2

:: Common partition sizes used by Xbox One
:: wmic partition get name,bootable,size,type
:: Xbox temp partition size (41G)
set XBOX_TEMP_SIZE_IN_BYTES=44023414784
:: Xbox support partition size (40G)
set XBOX_SUPPORT_SIZE_IN_BYTES=42949672960
:: Xbox update partition size (12G)
set XBOX_UPDATE_SIZE_IN_BYTES=12884901888
:: Xbox update 2 partition size (7G)
set XBOX_UPDATE_SIZE2_IN_BYTES=7516192768


:seltype
:: New main menu defining the script path
echo.
echo Select Xbox One drive creation type:
set XBO_TYPE=
echo (a) Replace/Upgrade w/o a working original drive   (Standard Only)
echo (b) Replace/Upgrade keeping original drive data    (Standard and Non)
echo (c) Fix GUID values w/o formatting the drive       (Standard and Non)
echo (d) Backup "System Update" to current directory    (Standard and Non)
echo (e) Restore "System Update" from current directory (Standard and Non)
echo (f) Check all partitions for file system errors    (Standard and Non)
echo (g) Wipe drive of all partitions and GUID values   (Standard and Non)
echo (h) CANCEL
echo.
set /p XBO_TYPE=?
echo.
if not '%XBO_TYPE%'=='' set choice=%choice:~0,1%
if '%XBO_TYPE%'=='a' goto typea
if '%XBO_TYPE%'=='b' goto typeb
if '%XBO_TYPE%'=='c' goto typec
if '%XBO_TYPE%'=='d' goto typed
if '%XBO_TYPE%'=='e' goto typee
if '%XBO_TYPE%'=='f' goto typef
if '%XBO_TYPE%'=='g' goto typeg
if '%XBO_TYPE%'=='h' goto MsgEdrive
echo "%XBO_TYPE%" is not valid please try again
echo.
goto seltype

:typea
set XBO_DISK_TYPE=a
goto scan

:typeb
set XBO_DISK_TYPE=b
goto scan

:typec
set XBO_DISK_TYPE=c
goto scan

:typed
set XBO_DISK_TYPE=d
goto scan

:typee
set XBO_DISK_TYPE=e
goto scan

:typef
set XBO_DISK_TYPE=f
goto scan

:typeg
set XBO_DISK_TYPE=g
goto scan


:scan
echo.

:: '%XBO_DISK_TYPE%' == 'b'
:: All new, select a SOURCE and use RoboCopy to sync the data from
IF '%XBO_DISK_TYPE%' == 'b' (
    :: All options require a TARGET disk
    CALL :GetDisk SOURCE

    set XBO_SOURCE_DRIVE=!XBO_FORMAT_DRIVE!
    :: CHANGEME: Comment out the line below with "::" if you want to allow disk # SOURCE selection
    if !XBO_SOURCE_DRIVE! EQU !XBO_CNT! goto MsgEdrive
    :: Try to avoid destroying C:
    CALL :ChkForC XBO_SOURCE_DRIVE
    if !XBO_PERMS! EQU 0 goto MsgEdrive
    CALL :DskPrtLett TEMP_CONTENT_LETTER USER_CONTENT_LETTER SYSTEM_SUPPORT_LETTER SYSTEM_UPDATE_LETTER SYSTEM_UPDATE2_LETTER XBO_LABEL_PREFIX
)


:: All options require a TARGET disk
CALL :GetDisk TARGET

:: CHANGEME: Comment out the line below with "::" if you want to allow disk # TARGET selection
if %XBO_FORMAT_DRIVE% EQU %XBO_CNT% goto MsgEdrive
:: Try to avoid destroying C:
CALL :ChkForC XBO_FORMAT_DRIVE
if %XBO_PERMS% EQU 0 goto MsgEdrive


CALL :GetSect
CALL :GetBlock
echo Selected drive: %XBO_FORMAT_DRIVE% >> %XBO_LOG% 2>&1
echo Sectors: %XBO_DISK_SECTORS% >> %XBO_LOG% 2>&1
echo Logical block size: %DEV_LOGICAL_BLOCK_SIZE_IN_BYTES% >> %XBO_LOG% 2>&1
CALL :ListPart


:: Here is our first major split depending on %XBO_DISK_TYPE%
IF '%XBO_DISK_TYPE%' == 'c' goto nowarn
IF '%XBO_DISK_TYPE%' == 'd' goto nowarn
IF '%XBO_DISK_TYPE%' == 'f' goto nowarn
:: '%XBO_DISK_TYPE%' == 'a', 'b', 'e' or 'g'
choice.exe /M "WARNING: This will erase all data on this disk. Continue "
if ERRORLEVEL 2 goto MsgEdrive

IF '%XBO_DISK_TYPE%' == 'g' goto nowarn
:: '%XBO_DISK_TYPE%' == 'a' or 'b'
echo.
set XBO_MESSAGE=* Disk %XBO_FORMAT_DRIVE% will be formatted as an Xbox One . . .                      *
echo %XBO_MESSAGE%
echo %XBO_MESSAGE% >> %XBO_LOG% 2>&1
:nowarn


:: '%XBO_DISK_TYPE%' == 'd'
IF '%XBO_DISK_TYPE%' == 'd' (
    :: Make sure we are using known drive letters
    CALL :DskPrtLett TEMP_CONTENT_LETTER USER_CONTENT_LETTER SYSTEM_SUPPORT_LETTER SYSTEM_UPDATE_LETTER SYSTEM_UPDATE2_LETTER XBO_LABEL_PREFIX
    CALL :RoboBackUpd
    if !XBO_CANCEL! EQU 1 goto MsgEdrive
    :: Copies what it finds with "CALL :GetDisk TARGET", "CALL :GdStruct" not needed
    goto finlist
)


:: '%XBO_DISK_TYPE%' == 'e'
IF '%XBO_DISK_TYPE%' == 'e' (
    :: Make sure we are using known drive letters
    CALL :DskPrtLett TEMP_CONTENT_LETTER USER_CONTENT_LETTER SYSTEM_SUPPORT_LETTER SYSTEM_UPDATE_LETTER SYSTEM_UPDATE2_LETTER XBO_LABEL_PREFIX
    CALL :RoboRestUpd
    if !XBO_CANCEL! EQU 1 goto MsgEdrive
    :: Restores what it finds with "CALL :GetDisk TARGET", "CALL :GdStruct" not needed
    goto finlist
)


:: '%XBO_DISK_TYPE%' == 'f'
IF '%XBO_DISK_TYPE%' == 'f' (
    CALL :ChkDskAll TEMP_CONTENT_GUID USER_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID
    :: Scans what it finds with "CALL :GetDisk TARGET", "CALL :GdStruct" not needed
    goto finlist
)


:: '%XBO_DISK_TYPE%' == 'g'
IF '%XBO_DISK_TYPE%' == 'g' (
    CALL :GdWipe
    :: Deletes what it finds with "CALL :GetDisk TARGET", "CALL :GdStruct" not needed
    goto finlist
)


:: We should have at least the TARGET disk selected
:: Get SOURCE/TARGET structure
CALL :GdStruct
if %XBO_CANCEL% EQU 1 goto MsgEdrive


:: '%XBO_DISK_TYPE%' == 'c'
IF '%XBO_DISK_TYPE%' == 'c' (
    IF !DISK_USER_PN! EQU 5 (
        CALL :GdGuid DISK_GUID TEMP_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID USER_CONTENT_GUID
    ) ELSE (
        CALL :GdGuid DISK_GUID TEMP_CONTENT_GUID USER_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID
    )
    :: gdisk creates partitions very quickly, perhaps too quickly?
    CALL :SettleDown

    CALL :LabelVol TEMP_CONTENT_GUID USER_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID XBO_LABEL_PREFIX
    CALL :DskPrtLett TEMP_CONTENT_LETTER USER_CONTENT_LETTER SYSTEM_SUPPORT_LETTER SYSTEM_UPDATE_LETTER SYSTEM_UPDATE2_LETTER XBO_LABEL_PREFIX
    goto finlist
)


:: Remove all existing partitions
CALL :GdWipe
:: Create partitions
:: This call need to create proper sizes with 'User Content' as 2 or 5 part
IF %DISK_USER_PN% EQU 5 (
    CALL :GdPart XBOX_TEMP_SIZE_IN_MBYTES XBOX_SUPPORT_SIZE_IN_MBYTES XBOX_UPDATE_SIZE_IN_MBYTES XBOX_UPDATE_SIZE2_IN_MBYTES XBOX_USER_SIZE_IN_MBYTES
    CALL :GdName TEMP_CONTENT_LABEL SYSTEM_SUPPORT_LABEL SYSTEM_UPDATE_LABEL SYSTEM_UPDATE2_LABEL USER_CONTENT_LABEL
) ELSE (
    CALL :GdPart XBOX_TEMP_SIZE_IN_MBYTES XBOX_USER_SIZE_IN_MBYTES XBOX_SUPPORT_SIZE_IN_MBYTES XBOX_UPDATE_SIZE_IN_MBYTES XBOX_UPDATE_SIZE2_IN_MBYTES
    CALL :GdName TEMP_CONTENT_LABEL USER_CONTENT_LABEL SYSTEM_SUPPORT_LABEL SYSTEM_UPDATE_LABEL SYSTEM_UPDATE2_LABEL
)
:: Set GUID values
IF '%XBO_DISK_TYPE%' == 'a' (
    IF !DISK_USER_PN! EQU 5 (
        CALL :GdGuid DISK_GUID TEMP_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID USER_CONTENT_GUID
    ) ELSE (
        CALL :GdGuid DISK_GUID TEMP_CONTENT_GUID USER_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID
    )
)
IF '%XBO_DISK_TYPE%' == 'b' (
    IF !DISK_USER_PN! EQU 5 (
        CALL :GdGuid DISK_GDUPE TEMP_CONTENT_GDUPE SYSTEM_SUPPORT_GDUPE SYSTEM_UPDATE_GDUPE SYSTEM_UPDATE2_GDUPE USER_CONTENT_GDUPE
    ) ELSE (
        CALL :GdGuid DISK_GDUPE TEMP_CONTENT_GDUPE USER_CONTENT_GDUPE SYSTEM_SUPPORT_GDUPE SYSTEM_UPDATE_GDUPE SYSTEM_UPDATE2_GDUPE
    )
)

:: CHANGEME: Uncomment the line below if you want the option to reset USB
::           devices, not really necessary
::CALL :ResetUSB

:: gdisk creates partitions very quickly, perhaps too quickly?
CALL :SettleDown

:: Check volume status
echo list volume > %XBO_DP_SCRIPT%
%XBO_DISKPART% /s %XBO_DP_SCRIPT%
echo.
%XBO_DISKPART% /s %XBO_DP_SCRIPT% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1


IF '%XBO_DISK_TYPE%' == 'a' (
    CALL :FormatVol TEMP_CONTENT_GUID USER_CONTENT_GUID SYSTEM_SUPPORT_GUID SYSTEM_UPDATE_GUID SYSTEM_UPDATE2_GUID XBO_LABEL_PREFIX
    CALL :DskPrtForm XBO_LABEL_PREFIX
    CALL :DskPrtLett TEMP_CONTENT_LETTER USER_CONTENT_LETTER SYSTEM_SUPPORT_LETTER SYSTEM_UPDATE_LETTER SYSTEM_UPDATE2_LETTER XBO_LABEL_PREFIX
)
IF '%XBO_DISK_TYPE%' == 'b' (
    set XBO_LABEL_PREFIX=D
    CALL :FormatVol TEMP_CONTENT_GDUPE USER_CONTENT_GDUPE SYSTEM_SUPPORT_GDUPE SYSTEM_UPDATE_GDUPE SYSTEM_UPDATE2_GDUPE XBO_LABEL_PREFIX
    CALL :DskPrtForm XBO_LABEL_PREFIX
    CALL :DskPrtLett TEMP_CONTENT_LDUPE USER_CONTENT_LDUPE SYSTEM_SUPPORT_LDUPE SYSTEM_UPDATE_LDUPE SYSTEM_UPDATE2_LDUPE XBO_LABEL_PREFIX

    :: All new, now that we have a completed TARGET, copy from SOURCE
    echo.
    choice.exe /M "WARNING: About to copy to the TARGET disk. Continue "
    if ERRORLEVEL 2 goto MsgCdrive

    CALL :RoboCopyAll
)


:: Check volume status
:finlist
echo list volume > %XBO_DP_SCRIPT%
%XBO_DISKPART% /s %XBO_DP_SCRIPT%
echo.
%XBO_DISKPART% /s %XBO_DP_SCRIPT% >> %XBO_LOG% 2>&1
echo. >> %XBO_LOG% 2>&1

if exist %SYSTEM_UPDATE_LETTER%\ goto MsgDexists
goto MsgMexists


:: Final messages
:MsgNdrive
set XBO_MESSAGE=* No USB/SATA drives found                                           *
goto endbat

:MsgCdrive
set XBO_MESSAGE=* Xbox One Drive Copy Cancelled                                 *
goto endbat

:MsgEdrive
set XBO_MESSAGE=* Xbox One Drive Selection Cancelled                                 *
goto endbat

:MsgMexists
set XBO_MESSAGE=* Missing Drive %SYSTEM_UPDATE_LETTER% '%SYSTEM_UPDATE_LABEL%'.                                  *
goto endbat

:MsgDexists
set XBO_MESSAGE=* Found Drive %SYSTEM_UPDATE_LETTER% '%SYSTEM_UPDATE_LABEL%'.                                    *
echo.

CALL :ListPart
goto endbat



:: FUNCTIONS
:: https://www.dostips.com/DtTutoFunctions.php
:: Notation - :FunctionName <>                 - no arguments passed
::                          <resultVarName>    - function result value stored in variable name
::                          <datatypeVarName>  - type of data stored passed as a variable name
::                          <datatypeVarValue> - type of data stored passed as a value


:: Ask for the desired disk structure
:GdStruct <>
:: Get SOURCE/TARGET structure
:: Calculate partition sizes, creation moved to gdisk below
:: Partition 1: Temp Content
CALL :Calc %XBOX_TEMP_SIZE_IN_BYTES%/1024/1024
echo * %TEMP_CONTENT_LABEL%: MByte Size: '%XBO_CALC_RESULT%' >> %XBO_LOG% 2>&1
set /a XBOX_TEMP_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_TEMP_SIZE_IN_MBYTES% offset=1024 >> %XBO_DP_SCRIPT%

if '%XBO_DISK_TYPE%'=='a' goto selsize
goto selsizeall

:selsize
echo.
echo Select partition layout:
set XBO_SIZE=
echo (a) 500GB Standard (365GB)
echo (b) 1TB Standard   (781GB)
echo (c) 2TB Standard  (1662GB)
echo (d) CANCEL
echo.
set /p XBO_SIZE=?
echo.
if not '%XBO_SIZE%'=='' set choice=%choice:~0,1%
if '%XBO_SIZE%'=='a' goto sizea
if '%XBO_SIZE%'=='b' goto sizeb
if '%XBO_SIZE%'=='c' goto sizec
if '%XBO_SIZE%'=='d' (
    set XBO_CANCEL=1
    goto endsize
)
echo "%XBO_SIZE%" is not valid please try again
echo.
goto selsize

:selsizeall
echo.
echo Select partition layout:
set XBO_SIZE=
echo (a) 500GB Standard (365GB)
echo (b) 1TB Standard   (781GB)
echo (c) 2TB Standard  (1662GB)
echo (d) Autosize Non-Standard w/ 500GB Disk GUID (1947GB MAX)
echo (e) Autosize Non-Standard w/ 1TB Disk GUID   (1947GB MAX)
echo (f) Autosize Non-Standard w/ 2TB Disk GUID   (1947GB MAX)
echo (g) CANCEL
echo.
set /p XBO_SIZE=?
echo.
if not '%XBO_SIZE%'=='' set choice=%choice:~0,1%
if '%XBO_SIZE%'=='a' goto sizea
if '%XBO_SIZE%'=='b' goto sizeb
if '%XBO_SIZE%'=='c' goto sizec
if '%XBO_SIZE%'=='d' goto sized
if '%XBO_SIZE%'=='e' goto sizee
if '%XBO_SIZE%'=='f' goto sizef
if '%XBO_SIZE%'=='g' (
    set XBO_CANCEL=1
    goto endsize
)
echo "%XBO_SIZE%" is not valid please try again
echo.
goto selsizeall

:: Partition 2: User Content

:sizea
:: Could force all drives >500GB to be 500GB equivalent
set DISK_GUID=%DISK_GUID_500GB%
set DISK_NAME=(500GB)
:: Xbox One Standard 500GB User Partition
CALL :Calc 391915765760/1024/1024
:: CHANGEME: Xbox One Large 500GB User Partition
::CALL :Calc 392732606464/1024/1024
goto sizestat

:sizeb
:: Could force all drives >1TB to be 1TB equivalent
set DISK_GUID=%DISK_GUID_1TB%
set DISK_NAME=(1TB)
:: Xbox One Standard 1TB User Partition
CALL :Calc 838592364544/1024/1024
:: CHANGEME: Xbox One Large 1TB User Partition
::CALL :Calc 892828909568/1024/1024
goto sizestat

:sizec
:: Could force all drives >2TB to be 2TB equivalent
set DISK_GUID=%DISK_GUID_2TB%
set DISK_NAME=(2TB)
:: Xbox One Standard 2TB User Partition
CALL :Calc 1784558911488/1024/1024
:: CHANGEME: Xbox One Large 2TB User Partition
::CALL :Calc 1893023612928/1024/1024
goto sizestat

:sizestat
:: Standard 'User Content' is the 2nd partition
set DISK_USER_PN=2
goto finsize

:sized
:: Treat Non-Standard size drives as 500GB drives but add the spare space to 'User Content'
set DISK_GUID=%DISK_GUID_500GB%
set DISK_NAME=(Autosize 500GB)
goto sizeauto

:sizee
:: Treat Non-Standard size drives as 1TB drives but add the spare space to 'User Content'
set DISK_GUID=%DISK_GUID_1TB%
set DISK_NAME=(Autosize 1TB)
goto sizeauto

:sizef
:: Treat Non-Standard size drives as 2TB drives but add the spare space to 'User Content'
set DISK_GUID=%DISK_GUID_2TB%
set DISK_NAME=(Autosize 2TB)
goto sizeauto

:sizeauto
:: Windows 10 Disk 1 GPT 2TB/2048GB
:: 2199023255552=2048GB
:: Windows 10 Autosize Comparisons
:: Windows 10 Disk 0 BIOS + MBR (Autosize Install)
:: 524288000 (System Reserved) + 2198497918976 (C:) = 2199022206976 (1048576=1MB less than 2199023255552)
:: Windows 10 Disk 1 MBR (Max Size)
:: 2199021158400 (2097152=2MB less than 2199023255552)
:: Round to the nearest GB at 2047GB
:: 2197949513728=2047GB (1073741824=1024MB less than 2199023255552)
:: Subtract 100GB to make room for the other 4 partitions at 1947GB to avoid E106
:: 2090575331328=1947GB (108447924224=101GB less than 2199023255552)
CALL :Calc 2090575331328/1024/1024
set /a XBOX_MAX_SIZE_IN_MBYTES=%XBO_CALC_RESULT%

:: Non-Standard 'User Content' is the 5th partition to avoid E106
:: 7.0: Changed all to 2nd partition since 'User Content' over 2048GB is useless
::      However, now 1948GB is the largest in this position?
set DISK_USER_PN=2
:: CHANGEME: Uncomment below to create 'User Content' as the 5th partition again
::set DISK_USER_PN=5
:: Size of the device in bytes
CALL :Calc %XBO_DISK_SECTORS%*%DEV_LOGICAL_BLOCK_SIZE_IN_BYTES%
:: New user content partition size (eg. Using a 500G drive it's roughly 392733679616 bytes = 365G )
CALL :Calc %XBO_CALC_RESULT%-%XBOX_TEMP_SIZE_IN_BYTES%-%XBOX_SUPPORT_SIZE_IN_BYTES%-%XBOX_UPDATE_SIZE_IN_BYTES%-%XBOX_UPDATE_SIZE2_IN_BYTES%
echo * User Content: Byte Size:  '%XBO_CALC_RESULT%'                           * >> %XBO_LOG% 2>&1
:: Align the data to the nearest GB
CALL :Calc %XBO_CALC_RESULT%/1024/1024/1024
echo * User Content: GByte Size: '%XBO_CALC_RESULT%'                                    * >> %XBO_LOG% 2>&1
CALL :Calc %XBO_CALC_RESULT%*1024

if %XBO_CALC_RESULT% LEQ %XBOX_MAX_SIZE_IN_MBYTES% goto finsize
set XBO_MESSAGE=* Disk larger than 2TB, Limiting User Content to 1.9TB               *
echo %XBO_MESSAGE%
echo %XBO_MESSAGE% >> %XBO_LOG% 2>&1
set XBO_CALC_RESULT=%XBOX_MAX_SIZE_IN_MBYTES%
goto finsize

:finsize
echo * %USER_CONTENT_LABEL%: MByte Size: '%XBO_CALC_RESULT%' >> %XBO_LOG% 2>&1
set /a XBOX_USER_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_USER_SIZE_IN_MBYTES% >> %XBO_DP_SCRIPT%

:: Partition 3: System Support
CALL :Calc %XBOX_SUPPORT_SIZE_IN_BYTES%/1024/1024
echo * %SYSTEM_SUPPORT_LABEL%: MByte Size: '%XBO_CALC_RESULT%' >> %XBO_LOG% 2>&1
set /a XBOX_SUPPORT_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_SUPPORT_SIZE_IN_MBYTES% >> %XBO_DP_SCRIPT%

:: Partition 4: System Update
CALL :Calc %XBOX_UPDATE_SIZE_IN_BYTES%/1024/1024
echo * %SYSTEM_UPDATE_LABEL%: MByte Size: '%XBO_CALC_RESULT%' >> %XBO_LOG% 2>&1
set /a XBOX_UPDATE_SIZE_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_UPDATE_SIZE_IN_MBYTES% >> %XBO_DP_SCRIPT%

:: Partition 5: System Update 2
CALL :Calc %XBOX_UPDATE_SIZE2_IN_BYTES%/1024/1024
echo * %SYSTEM_UPDATE2_LABEL%: MByte Size: '%XBO_CALC_RESULT%' >> %XBO_LOG% 2>&1
set /a XBOX_UPDATE_SIZE2_IN_MBYTES=%XBO_CALC_RESULT%
::echo create partition primary size=%XBOX_UPDATE_SIZE2_IN_MBYTES% >> %XBO_DP_SCRIPT%
:endsize
GOTO:EOF


:: Remove all existing partitions
:GdWipe <>
:: "Partition Order Safe"
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
:::sgpt

:: Make destructive drive changes
::%XBO_DISKPART% /s %XBO_DP_SCRIPT%
:: End of diskpart remove existing partitions (works but clunky since partitions have to be removed individually)

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
GOTO:EOF


:: Create partitions with 'User Content' as the 2nd partition
:: Create partitions with 'User Content' as the 5th partition
:GdPart <size1VarName> <size2VarName> <size3VarName> <size4VarName> <size5VarName>
:: "Partition Order Safe"
:: Windows doesn't like this much, works fine but Windows loses drive letters and things
echo * Creating new partitions with %XBO_GDISK% . . .                         *
echo n > %XBO_GD_SCRIPT%
echo 1 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +!%1!M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%

echo n >> %XBO_GD_SCRIPT%
echo 2 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +!%2!M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%

echo n >> %XBO_GD_SCRIPT%
echo 3 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +!%3!M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%

echo n >> %XBO_GD_SCRIPT%
echo 4 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +!%4!M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%

echo n >> %XBO_GD_SCRIPT%
echo 5 >> %XBO_GD_SCRIPT%
echo. >> %XBO_GD_SCRIPT%
echo +!%5!M >> %XBO_GD_SCRIPT%
echo 700 >> %XBO_GD_SCRIPT%
GOTO:EOF


:: 7.0: Change partition's name for Linux sgdisk compatibility
:: :GdName is called right after :GdPart since "write table to disk and exit"
:: was moved to :GdName
:GdName <name1VarName> <name2VarName> <name3VarName> <name4VarName> <name5VarName>
:: "Partition Order Safe"
echo c >> %XBO_GD_SCRIPT%
echo 1 >> %XBO_GD_SCRIPT%
echo !%1!>> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 2 >> %XBO_GD_SCRIPT%
echo !%2!>> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 3 >> %XBO_GD_SCRIPT%
echo !%3!>> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 4 >> %XBO_GD_SCRIPT%
echo !%4!>> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 5 >> %XBO_GD_SCRIPT%
echo !%5!>> %XBO_GD_SCRIPT%

echo w >> %XBO_GD_SCRIPT%
echo y >> %XBO_GD_SCRIPT%

:: Make destructive GUID drive changes
echo. >> %XBO_LOG% 2>&1
%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% < %XBO_GD_SCRIPT% >> %XBO_LOG% 2>&1
GOTO:EOF


:: Set disk and partition GUID values
:GdGuid <diskVarName> <part1VarName> <part2VarName> <part3VarName> <part4VarName> <part5VarName>
:: "Not Partition Order Safe"
:: echo !%1! !%2! !%3! !%4! !%5! !%6!
:: Windows doesn't like this much, works fine but Windows loses drive letters and things
echo * Updating GUID values with %XBO_GDISK% . . .                            *
echo x > %XBO_GD_SCRIPT%
echo g >> %XBO_GD_SCRIPT%
echo !%1! >> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
:: Not needed when only one partition exists
echo 1 >> %XBO_GD_SCRIPT%
echo !%2! >> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 2 >> %XBO_GD_SCRIPT%
echo !%3! >> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 3 >> %XBO_GD_SCRIPT%
echo !%4! >> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 4 >> %XBO_GD_SCRIPT%
echo !%5! >> %XBO_GD_SCRIPT%

echo c >> %XBO_GD_SCRIPT%
echo 5 >> %XBO_GD_SCRIPT%
echo !%6! >> %XBO_GD_SCRIPT%

echo w >> %XBO_GD_SCRIPT%
echo y >> %XBO_GD_SCRIPT%

:: Make destructive GUID drive changes
echo. >> %XBO_LOG% 2>&1
%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% < %XBO_GD_SCRIPT% >> %XBO_LOG% 2>&1
GOTO:EOF


:: Use format instead of diskpart to add a volume label
:FormatVol <part1VarName> <part2VarName> <part3VarName> <part4VarName> <part5VarName> <labelprefixVarName>
:: "Partition Order Safe"
:: format doesn't support spaces in volume labels, fix with diskpart in next step
echo * Formatting new partitions with %XBO_FORMAT% . . .    *
%XBO_FORMAT% \\?\Volume{!%1!} /FS:NTFS /V:!%6!Temp_Content /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{!%2!} /FS:NTFS /V:!%6!User_Content /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{!%3!} /FS:NTFS /V:!%6!System_Support /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{!%4!} /FS:NTFS /V:!%6!System_Update /Q /Y >> %XBO_LOG% 2>&1
%XBO_FORMAT% \\?\Volume{!%5!} /FS:NTFS /V:!%6!System_Update_2 /Q /Y >> %XBO_LOG% 2>&1
GOTO:EOF


:: Use label instead of diskpart to add a volume label
:LabelVol <part1VarName> <part2VarName> <part3VarName> <part4VarName> <part5VarName> <labelprefixVarName>
:: "Partition Order Safe"
echo * Labelling new partitions with %XBO_LABEL% . . .      *
%XBO_LABEL% \\?\Volume{!%1!} !%6!%TEMP_CONTENT_LABEL% >> %XBO_LOG% 2>&1
%XBO_LABEL% \\?\Volume{!%2!} !%6!%USER_CONTENT_LABEL% >> %XBO_LOG% 2>&1
%XBO_LABEL% \\?\Volume{!%3!} !%6!%SYSTEM_SUPPORT_LABEL% >> %XBO_LOG% 2>&1
%XBO_LABEL% \\?\Volume{!%4!} !%6!%SYSTEM_UPDATE_LABEL% >> %XBO_LOG% 2>&1
%XBO_LABEL% \\?\Volume{!%5!} !%6!%SYSTEM_UPDATE2_LABEL% >> %XBO_LOG% 2>&1
GOTO:EOF


:: Use diskpart to format so that we can copy files
:DskPrtForm <labelprefixVarName>
IF '!%1!' == 'D' (
    set XBO_FINDSTR_TEMP=DTemp.Conte
    set XBO_FINDSTR_USER=DUser.Conte
    set XBO_FINDSTR_SUPPORT=DSystem.Sup
    set XBO_FINDSTR_UPDATE=DSystem.Upd.*12
    set XBO_FINDSTR_UPDATE2=DSystem.Upd.*7168
) else (
    set XBO_FINDSTR_TEMP=Temp.Conten
    set XBO_FINDSTR_USER=User.Conten
    set XBO_FINDSTR_SUPPORT=System.Supp
    set XBO_FINDSTR_UPDATE=System.Upda.*12
    set XBO_FINDSTR_UPDATE2=System.Upda.*7168
)

:: "Partition Order Safe"
echo * Formatting with %XBO_DISKPART% . . .                 *
:: Rescan for newly added devices
echo rescan > %XBO_DP_SCRIPT%
echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_TEMP!"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="!%1!!TEMP_CONTENT_LABEL!" QUICK NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_USER!"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="!%1!!USER_CONTENT_LABEL!" QUICK NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_SUPPORT!"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="!%1!!SYSTEM_SUPPORT_LABEL!" QUICK NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_UPDATE!"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="!%1!!SYSTEM_UPDATE_LABEL!" QUICK NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_UPDATE2!"') do (
    echo select volume %%A > !XBO_DP_SCRIPT!
    echo format FS=NTFS LABEL="!%1!!SYSTEM_UPDATE2_LABEL!" QUICK NOERR >> !XBO_DP_SCRIPT!
    !XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
)
GOTO:EOF


:: Use diskpart to assign drive letters so that we can copy files
:DskPrtLett <letter1VarName> <letter2VarName> <letter3VarName> <letter4VarName> <letter5VarName> <labelprefixVarName>
:: Formatting the same drive twice can produce this error
:: Virtual Disk Service error:
:: The specified drive letter is not free to be assigned.

IF '!%6!' == 'D' (
    set XBO_FINDSTR_TEMP=DTemp.Conte
    set XBO_FINDSTR_USER=DUser.Conte
    set XBO_FINDSTR_SUPPORT=DSystem.Sup
    set XBO_FINDSTR_UPDATE=DSystem.Upd.*12
    set XBO_FINDSTR_UPDATE2=DSystem.Upd.*7168
) else (
    set XBO_FINDSTR_TEMP=Temp.Conten
    set XBO_FINDSTR_USER=User.Conten
    set XBO_FINDSTR_SUPPORT=System.Supp
    set XBO_FINDSTR_UPDATE=System.Upda.*12
    set XBO_FINDSTR_UPDATE2=System.Upda.*7168
)

:: "Partition Order Safe"
echo * Assigning drive letters with %XBO_DISKPART% . . .    *

:: Rescan for newly added devices
echo rescan > %XBO_DP_SCRIPT%
:: Retrieve all volume numbers for assigning drive letters
echo list volume >> %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_TEMP!"') do (
    set XBO_VOL_TEMP=%%A
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_USER!"') do (
    set XBO_VOL_USER=%%A
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_SUPPORT!"') do (
    set XBO_VOL_SUPPORT=%%A
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_UPDATE!"') do (
    set XBO_VOL_UPDATE=%%A
)

echo list volume > %XBO_DP_SCRIPT%
for /f "tokens=2" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:".*!XBO_FINDSTR_UPDATE2!"') do (
    set XBO_VOL_UPDATE2=%%A
)

:: Remove all letters to prevent new partitions from holding ones we need
echo select volume !XBO_VOL_TEMP! > !XBO_DP_SCRIPT!
echo remove all NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_USER! >> !XBO_DP_SCRIPT!
echo remove all NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_SUPPORT! >> !XBO_DP_SCRIPT!
echo remove all NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_UPDATE! >> !XBO_DP_SCRIPT!
echo remove all NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_UPDATE2! >> !XBO_DP_SCRIPT!
echo remove all NOERR >> !XBO_DP_SCRIPT!

:: Add all drive letters
echo select volume !XBO_VOL_TEMP! >> !XBO_DP_SCRIPT!
echo assign letter=!%1! NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_USER! >> !XBO_DP_SCRIPT!
echo assign letter=!%2! NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_SUPPORT! >> !XBO_DP_SCRIPT!
echo assign letter=!%3! NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_UPDATE! >> !XBO_DP_SCRIPT!
echo assign letter=!%4! NOERR >> !XBO_DP_SCRIPT!
echo select volume !XBO_VOL_UPDATE2! >> !XBO_DP_SCRIPT!
echo assign letter=!%5! NOERR >> !XBO_DP_SCRIPT!

!XBO_DISKPART! /s !XBO_DP_SCRIPT! >> !XBO_LOG! 2>&1
GOTO:EOF


:: Use CHKDSK to scan all matching Xbox One partitions
:ChkDskAll <part1VarName> <part2VarName> <part3VarName> <part4VarName> <part5VarName>
:: "Partition Order Safe"
echo * Checking partitions with %XBO_CHKDSK% . . .
CALL :ChkDskPart %1
CALL :ChkDskPart %2
CALL :ChkDskPart %3
CALL :ChkDskPart %4
CALL :ChkDskPart %5
GOTO:EOF


:: Use CHKDSK to scan the given partition
:ChkDskPart <partVarName>
set XBO_RUN=%XBO_CHKDSK% \\?\Volume{!%1!} /f /x
echo.
echo * Running: %XBO_RUN%
echo * Running: %XBO_RUN% >> !XBO_LOG! 2>&1
%XBO_RUN%
GOTO:EOF


:: Use robocopy to copy one Xbox One disk to another but check for drive
:: letter existence first
:RoboCopyAll <>
:: "Partition Order Safe"
:: robocopy "C:\Users" "Q:\xfix-5\Users" /MIR /XJ /R:3 /W:3 /TS /FP /NP /ETA /LOG+:"%TEMP%/RoboCopy-xfix-5.log" /TEE
echo.
set ROBOCHK=0
if not exist %TEMP_CONTENT_LETTER%\ (
    set XBO_ERR=* Missing '!TEMP_CONTENT_LABEL!' !TEMP_CONTENT_LETTER!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %TEMP_CONTENT_LDUPE%\ (
    set XBO_ERR=* Missing '!TEMP_CONTENT_LABEL!' !TEMP_CONTENT_LDUPE!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %USER_CONTENT_LETTER%\ (
    set XBO_ERR=* Missing '!USER_CONTENT_LABEL!' !USER_CONTENT_LETTER!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %USER_CONTENT_LDUPE%\ (
    set XBO_ERR=* Missing '!USER_CONTENT_LABEL!' !USER_CONTENT_LDUPE!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %SYSTEM_SUPPORT_LETTER%\ (
    set XBO_ERR=* Missing '!SYSTEM_SUPPORT_LABEL!' !SYSTEM_SUPPORT_LETTER!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %SYSTEM_SUPPORT_LDUPE%\ (
    set XBO_ERR=* Missing '!SYSTEM_SUPPORT_LABEL!' !SYSTEM_SUPPORT_LDUPE!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %SYSTEM_UPDATE_LETTER%\ (
    set XBO_ERR=* Missing '!SYSTEM_UPDATE_LABEL!' !SYSTEM_UPDATE_LETTER!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %SYSTEM_UPDATE_LDUPE%\ (
    set XBO_ERR=* Missing '!SYSTEM_UPDATE_LABEL!' !SYSTEM_UPDATE_LDUPE!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %SYSTEM_UPDATE2_LETTER%\ (
    set XBO_ERR=* Missing '!SYSTEM_UPDATE2_LABEL!' !SYSTEM_UPDATE2_LETTER!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %SYSTEM_UPDATE2_LDUPE%\ (
    set XBO_ERR=* Missing '!SYSTEM_UPDATE2_LABEL!' !SYSTEM_UPDATE2_LDUPE!
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)

if !ROBOCHK! EQU 1 (
    set XBO_ERR=* Something is missing, cannot copy data
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    goto skiprobo
)

CALL :RoboCopyRun TEMP_CONTENT_LETTER TEMP_CONTENT_LDUPE Temp_Content
CALL :RoboCopyRun USER_CONTENT_LETTER USER_CONTENT_LDUPE User_Content
CALL :RoboCopyRun SYSTEM_SUPPORT_LETTER SYSTEM_SUPPORT_LDUPE System_Support
CALL :RoboCopyRun SYSTEM_UPDATE_LETTER SYSTEM_UPDATE_LDUPE System_Update
CALL :RoboCopyRun SYSTEM_UPDATE2_LETTER SYSTEM_UPDATE2_LDUPE System_Update_2
:skiprobo
GOTO:EOF


:: Use robocopy to copy a Xbox One partition to a local directory but check
:: for drive letter and directory existence first
:RoboBackChk <backupreqVarName> <backupdirVarName> <backupletterVarName> <backuplabelVarName>
:: "Partition Order Safe"
echo.
set ROBOCHK=0
set XBO_BACKUP_REQ=%1
set XBO_BACKUP_DIR=%2
set XBO_BACKUP_LETTER=%3
set XBO_BACKUP_LABEL=!%4!

if '%XBO_BACKUP_REQ%'=='Backup' (
    mkdir %XBO_BACKUP_DIR%
)

if not exist %XBO_BACKUP_LETTER%\ (
    set XBO_ERR=* Missing Drive %XBO_BACKUP_LETTER% '%XBO_BACKUP_LABEL%'
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)
if not exist %XBO_BACKUP_DIR% (
    set XBO_ERR=* Missing Directory '%XBO_BACKUP_DIR%'
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    set ROBOCHK=1
)

if !ROBOCHK! EQU 1 (
    set XBO_ERR=* Something is missing, cannot copy data
    echo !XBO_ERR!
    echo !XBO_ERR! >> !XBO_LOG! 2>&1
    goto skipupd
)

if '%XBO_BACKUP_REQ%'=='Backup' (
    del /F /Q %XBO_BACKUP_DIR%\* >> !XBO_LOG! 2>&1
    CALL :RoboCopyRun XBO_BACKUP_LETTER XBO_BACKUP_DIR %XBO_BACKUP_DIR%
    %XBO_ATTRIB% -S -H "%XBO_BACKUP_DIR%"
)
if '%XBO_BACKUP_REQ%'=='Restore' (
    del /F /Q %XBO_BACKUP_LETTER%\* >> !XBO_LOG! 2>&1
    CALL :RoboCopyRun XBO_BACKUP_DIR XBO_BACKUP_LETTER %XBO_BACKUP_DIR%
)
:skipupd
GOTO:EOF


:: Copy a Xbox One partition to a local directory
:RoboBackUpd <>
CALL :RoboPartSel Backup
if '%XBO_BACKUP_TYPE%'=='c' goto backend
if '%XBO_BACKUP_TYPE%'=='b' goto backall
CALL :RoboBackChk Backup System_Update %SYSTEM_UPDATE_LETTER% SYSTEM_UPDATE_LABEL
goto backend
:backall
CALL :RoboBackChk Backup Temp_Content %TEMP_CONTENT_LETTER% TEMP_CONTENT_LABEL
CALL :RoboBackChk Backup User_Content %USER_CONTENT_LETTER% USER_CONTENT_LABEL
CALL :RoboBackChk Backup System_Support %SYSTEM_SUPPORT_LETTER% SYSTEM_SUPPORT_LABEL
CALL :RoboBackChk Backup System_Update %SYSTEM_UPDATE_LETTER% SYSTEM_UPDATE_LABEL
CALL :RoboBackChk Backup System_Update_2 %SYSTEM_UPDATE2_LETTER% SYSTEM_UPDATE2_LABEL
:backend
GOTO:EOF


:: Copy a local directory to a Xbox One partition
:RoboRestUpd <>
CALL :RoboPartSel Restore
if '%XBO_BACKUP_TYPE%'=='c' goto restend
if '%XBO_BACKUP_TYPE%'=='b' goto restall
CALL :RoboBackChk Restore System_Update %SYSTEM_UPDATE_LETTER% SYSTEM_UPDATE_LABEL
goto restend
:restall
CALL :RoboBackChk Restore Temp_Content %TEMP_CONTENT_LETTER% TEMP_CONTENT_LABEL
CALL :RoboBackChk Restore User_Content %USER_CONTENT_LETTER% USER_CONTENT_LABEL
CALL :RoboBackChk Restore System_Support %SYSTEM_SUPPORT_LETTER% SYSTEM_SUPPORT_LABEL
CALL :RoboBackChk Restore System_Update %SYSTEM_UPDATE_LETTER% SYSTEM_UPDATE_LABEL
CALL :RoboBackChk Restore System_Update_2 %SYSTEM_UPDATE2_LETTER% SYSTEM_UPDATE2_LABEL
:restend
GOTO:EOF


:: Select which Xbox One partition(s) to backup
:RoboPartSel <backupreqVarName>
:selpart
echo.
echo Select partition %1 type:
set XBO_SIZE=
echo (a) "System Update" only (more important)
echo (b) "All Partitions"     (less important)
echo (c) CANCEL
echo.
set /p XBO_BACKUP_TYPE=?
echo.
if not '%XBO_BACKUP_TYPE%'=='' set choice=%choice:~0,1%
if '%XBO_BACKUP_TYPE%'=='a' goto selend
if '%XBO_BACKUP_TYPE%'=='b' goto selend
if '%XBO_BACKUP_TYPE%'=='c' (
    set XBO_CANCEL=1
    goto selend
)
echo "%XBO_BACKUP_TYPE%" is not valid please try again
echo.
goto selpart
:selend
GOTO:EOF


:: Run robocopy with common switches
:RoboCopyRun <sourceVarName> <targetVarName> <lognameVarValue>
:: 2018/06/19 - Preserve ACLs with robocopy /COPYALL - not really necessary and creates issues when removing files from Windows
::set XBO_RUN=%XBO_ROBOCOPY% "!%1!" "!%2!" /ZB /COPYALL /MIR /XJ /R:3 /W:3 /TS /FP /ETA /LOG:"%TEMP%/RoboCopy-%3.log" /TEE
set XBO_RUN=%XBO_ROBOCOPY% "!%1!" "!%2!" /ZB /MIR /XJ /R:3 /W:3 /TS /FP /ETA /LOG:"%TEMP%/RoboCopy-%3.log" /TEE
echo.
echo * Running: %XBO_RUN%
echo * Running: %XBO_RUN% >> !XBO_LOG! 2>&1
%XBO_RUN%
GOTO:EOF


:: Check if the script is currently running with Administrative permissions
:ChkPerms <>
echo * Administrative permissions required. Detecting permissions...      *

net session >nul 2>&1
IF %errorLevel% == 0 (
    echo * Administrative permissions confirmed                               *
    set XBO_PERMS=1
) ELSE (
    echo * Current permissions inadequate. Please run this script using:      *
    echo * "Run as administrator"                                             *
    set XBO_PERMS=0
)
echo.
GOTO:EOF


:: Check if "English (United States)" is installed
:ChkEng <>
echo * English language availability required. Checking...                *
echo. >> %XBO_LOG% 2>&1

IF EXIST %XBO_EN_US% (
    echo English language availability confirmed >> %XBO_LOG% 2>&1
    echo * English language availability confirmed                            *
    set XBO_PERMS=1
) ELSE (
    echo English language missing >> %XBO_LOG% 2>&1
    echo * English language missing. Please add English ^(United States^) using:*
    echo * Control Panel\All Control Panel Items\Language\Add languages       *
    set XBO_PERMS=0
)
echo.
echo. >> %XBO_LOG% 2>&1
GOTO:EOF


:: Check for C: on the given disk
:ChkForC <diskidVarName>
:: Try to avoid destroying C:
echo * Does selected disk contain C: Checking...                          *

set XBO_PERMS=1
echo rescan > %XBO_DP_SCRIPT%
echo select disk !%1! >> %XBO_DP_SCRIPT%
echo detail disk >> %XBO_DP_SCRIPT%
for /f "tokens=3" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:" *Volume [^#]"') do (
    IF '%%A'=='C' (
        echo * Found C: on the selected disk, cannot continue                     *
        set XBO_PERMS=0
    )
)
if !XBO_PERMS! EQU 1 (
    echo * Does not contain C: can continue                                   *
)
echo.
GOTO:EOF


:: Check if a list of drive letters are in use
:ChkForLetters <>
::wmic logicaldisk get Caption,Description,VolumeName
echo * Are required drive letters available? Checking...                  *
CALL :ChkLetter TEMP_CONTENT_LDUPE
CALL :ChkLetter USER_CONTENT_LDUPE
CALL :ChkLetter SYSTEM_SUPPORT_LDUPE
CALL :ChkLetter SYSTEM_UPDATE_LDUPE
CALL :ChkLetter SYSTEM_UPDATE2_LDUPE
CALL :ChkLetter TEMP_CONTENT_LETTER
CALL :ChkLetter USER_CONTENT_LETTER
CALL :ChkLetter SYSTEM_SUPPORT_LETTER
CALL :ChkLetter SYSTEM_UPDATE_LETTER
CALL :ChkLetter SYSTEM_UPDATE2_LETTER
echo.
echo * WARNING: Any non-free drive letters above may interfere with this  *
echo *          script. Adjust the letters used in the "Changeable drive  *
echo *          letters" section near the top of this script.             *
echo *          If you have an Xbox One drive attached non-free drive     *
echo *          letters are expected.                                     *
echo.
GOTO:EOF


:: See if the given drive letter is in use
:ChkLetter <drvletterVarName>
set XBO_AVAIL=1
for /f "tokens=1*" %%A in ('wmic logicaldisk get Caption^,Description^,VolumeName ^| findstr /b /r /c:"!%1!"') do (
    set MESG=%%A - %%B
    IF '%%A'=='!%1!' (
        echo ^* Found !MESG!
        set XBO_AVAIL=0
    )
)
if !XBO_AVAIL! EQU 1 (
    echo ^* !%1! is free
)
GOTO:EOF


:: Handle math expressions that Windows batch cannot
:Calc <expressionVarValue>
:: Round down all sizes
for /f "tokens=1" %%A in ('%XBO_CALC% Floor^(%1^)') do (
    set XBO_CALC_RESULT=%%A
)
GOTO:EOF


:: Create a disk selection menu
:GetDisk <disktypeVarValue>
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

:: Ignore the header (Disk ###) and --- lines
::%XBO_DISKPART% /s %XBO_DP_SCRIPT% | findstr /b /r /c:" *Disk [^#]" | find /c "Disk"
:: CHANGEME: The word "Disk" in English may be a different for your language
:: For example: Portuguese and Spanish users must change " *Disk [^#]" ^| find /c "Disk"') with " *Disco [^#]" ^| find /c "Disco"')
:: Instead of manually setting the proper word for disk depending on the language just isolate a word followed by a number
:: findstr doesn't support Unicode so we need to match the ? replacement as well
for /f "tokens=*" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:" *[a-z?]* *[0-9]" ^| find /c " "') do (set XBO_DRIVE_COUNT=%%A)
set XBO_CNT=0
set XBO_CHOICE=0
::echo * Testing: Valid drive count: '%XBO_DRIVE_COUNT%'                                    *
:: If we couldn't find any drives . . . "Run as administrator" or "non-English Windows"?
if %XBO_DRIVE_COUNT% EQU 0 goto MsgNdrive

:lchoice
:: Create a choice list
set /a XBO_CNT+=1
::echo * Testing: Valid drive list: '%XBO_CNT%'                                     *
if %XBO_CNT% EQU %XBO_DRIVE_COUNT% goto rchoice
set XBO_CHOICE=%XBO_CHOICE%%XBO_CNT%
goto lchoice

:rchoice
::echo * Testing: Choice list: %XBO_CHOICE% *
echo * Select %1 Xbox One Drive . . .                                 *
:: 2018/11/13 - Support systems with 10 or more attached drives
::choice.exe /C %XBO_CHOICE%%XBO_CNT% /D %XBO_CNT% /T %XBO_TIMEOUT% /M "Press %XBO_CNT% to CANCEL or use a Disk Number from the list above (default %XBO_CNT% in %XBO_TIMEOUT% seconds)"
::set /a XBO_FORMAT_DRIVE=%ERRORLEVEL%-1
echo Enter %XBO_CNT% to CANCEL or use a Disk Number from the list above
set /p XBO_FORMAT_DRIVE=?
echo.
if not '%XBO_FORMAT_DRIVE%'=='' set choice=%choice:~0,1%
:: First check if the answer is numeric
SET "CHKNUM="&for /f "delims=0123456789" %%i in ("%XBO_FORMAT_DRIVE%") do set CHKNUM=%%i
if defined CHKNUM goto rchoice
:: Second make sure the answer isn't bigger than cancel
if %XBO_FORMAT_DRIVE% GTR %XBO_CNT% goto rchoice
GOTO:EOF


:: Get the given disk sector count
:GetSect <>
echo p > %XBO_GD_SCRIPT%
for /f "tokens=7" %%A in ('%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% ^< %XBO_GD_SCRIPT% ^| findstr /b /r /c:".*Disk \\\\.\\physicaldrive.:"') do (
    set XBO_DISK_SECTORS=%%A
)
GOTO:EOF


:: Get the given disk block size in bytes
:GetBlock <>
echo p > %XBO_GD_SCRIPT%
for /f "tokens=4" %%A in ('%XBO_GDISK% \\.\physicaldrive%XBO_FORMAT_DRIVE% ^< %XBO_GD_SCRIPT% ^| findstr /b /r /c:".*Logical sector size:"') do (
    set DEV_LOGICAL_BLOCK_SIZE_IN_BYTES=%%A
)
GOTO:EOF


:: Start of list_part_info.sh equivalent
:ListPart <>
echo select disk %XBO_FORMAT_DRIVE% > %XBO_DP_SCRIPT%
echo detail disk >> %XBO_DP_SCRIPT%
:: Get Disk GUID
for /f "tokens=2* delims={}" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /r /c:"{[a-z0-9-]*}"') do (
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
for /f "tokens=3,4,5,8,9" %%A in ('%XBO_DISKPART% /s %XBO_DP_SCRIPT% ^| findstr /b /r /c:" *Volume [0-9]"') do (
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
    for /f "tokens=2,3*" %%V in ('wmic logicaldisk get Caption^,VolumeName ^| findstr /b /r /c:"%%A"') do (
        CALL :Trim XBO_ENDLABEL1 %%W
        CALL :Trim XBO_ENDLABEL2 %%X
        if not "!XBO_ENDLABEL2!"=="" (
            set XBO_ENDLABEL2= !XBO_ENDLABEL2!
        )
        set XBO_PART!XBO_PART_CNT!_NAME=%%V !XBO_ENDLABEL1!!XBO_ENDLABEL2!
    )
    CALL :PrtPart XBO_PART!XBO_PART_CNT!_GUID XBO_PART!XBO_PART_CNT!_LETTER XBO_PART!XBO_PART_CNT!_SIZEP XBO_PART!XBO_PART_CNT!_NAME
)
echo.
echo. >> %XBO_LOG% 2>&1
GOTO:EOF
:: end of list_part_info.sh equivalent


:: Print the Xbox One partition layout
:PrtPart <guidVarName> <devVarName> <sizeVarName> <nameVarName>
echo !%1! !%2!  !%3! '!%4!'
echo !%1! !%2!  !%3! '!%4!' >> %XBO_LOG% 2>&1
GOTO:EOF


:: Subroutine to remove leading and trailing spaces
:Trim <resultVarName> <stringVarValue>
SET %1=%2
GOTO :EOF


:: Subroutine to convert a variable VALUE to all UPPER CASE.
:: The argument for this subroutine is the variable NAME.
:UpCase <resultstringVarName>
FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF


:: Return the length of the given string
:StrLen <resultVarName> <stringVarName>
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


:: Get a string of spaces equal to the given size
:GetSpaces <resultVarName> <numericVarName>
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


:: Pause the script to allow things to complete
:SettleDown <>
echo.
echo.
:: diskpart will not see the newly created volumes correctly without pausing?
:: 2018/01/08 - Not sure this is really necessary
start /wait choice.exe /N /C C /T %XBO_TIMEOUT% /D C /M "Giving USB/SATA devices %XBO_TIMEOUT% seconds to settle, please wait . . ."
GOTO:EOF


:: Reset the disk after gdisk and before diskpart. Gdisk can take time to
:: apply requested changes thus the 30 second "time to settle" bit below
:ResetUSB <>
echo.
echo.
echo If the drive is connected by USB you may want to choose "Y" here
echo This is equivalent to physically disconnecting and reconnecting the cable
choice.exe /M "Reset USB mass storage devices "
if ERRORLEVEL 2 goto nreset
echo. >> %XBO_LOG% 2>&1
%XBO_DEVCON% restart USB\ROOT_HUB20 >> %XBO_LOG% 2>&1
GOTO:EOF


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
::echo * This script will now change the command line interface back to the *
::echo * default language.                                                  *
::echo.
pause


:: 2018/11/13 - Removed Englishize requirement
:: Attempt to restore everything back to original language
::cd /D %~dp0\Englishize_Cmd
::call restore_xfix.bat
::cd ..

:endall
ENDLOCAL
