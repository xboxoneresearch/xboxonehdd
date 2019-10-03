@Echo Off
SETLOCAL EnableDelayedExpansion

::  Author:  XFiX
::  Date:    2016/10/18
::
::  Summary:
::
::  Reset USB Devices when you are having trouble ejecting through Windows
::  Use at your own risk
::
::  Change History:
::
::  2016/10/18 - Initial Release - XFiX

title Reset USB Devices
set XBO_VER=2016.10.18

echo.
echo **********************************************************************
echo * reset_usb_devices.bat:                                             *
echo * Reset USB Devices when you are having trouble ejecting through     *
echo * Windows.                                                           *
echo * USE AT YOUR OWN RISK                                               *
echo *                                                                    *
echo * Created      2016.10.18                                            *
echo * Last Updated %XBO_VER%                                            *
echo **********************************************************************
echo.

pause

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


echo.
echo.
echo If the drive is connected by USB you may want to choose "Y" here
echo This is equivalent to physically disconnecting and reconnecting the cable
choice.exe /M "Reset USB mass storage devices "
if ERRORLEVEL 2 goto nreset
%XBO_DEVCON% restart USB\ROOT_HUB20
:nreset

echo.
echo * Script execution complete.                                         *
echo.
pause

ENDLOCAL