Last Updated: 2018/05/10
Author: XFiX
https://www.youtube.com/playlist?list=PLURaLwRqr6g14Pl8qLO0E4ELBBCHfFh1V

Creates a properly partitioned Xbox One hard drive. You'll want to source the
entire original drive files or use the latest OSU1 files.

Features:
1. Create a Standard Xbox One 500GB, 1TB, or 2TB internal hard drive
2. Upgrade a Standard Xbox One drive to non-standard sizes including
   as small as 138GB, as large as 1947GB, and other non-standard sizes
3. Set Standard Xbox One GUID values w/o formatting the drive
4. Backup "System Update" to current directory System_Update and more
5. Restore "System Update" from current directory System_Update and more
6. Check all partitions for file system errors using chkdsk
7. Wipe drive of all partitions and GUID values

This script is a direct replacement to create_xbox_drive.sh for Linux and
tested on Windows 7 and 10.

You'll need some sort of USB to SATA device or have the ability to connect a
SATA drive directly to your PC. I recommend the USB3S2SAT3CB USB 3.0 to SATA
adapter cable.

NOTE 1: You need to run this script from an Administrator Command Prompt
        using the "Run as administrator" feature.

NOTE 2: For this script to work on non-English Windows systems
        C:\Windows\System32\en-US needs to be present.
        Control Panel\All Control Panel Items\Language\Add languages
        English (United States)

NOTE 3: Click "Cancel" or "X" on any "You need to format the disk in drive ?:
        before you can use it." messages.

NOTE 4: diskmgmt.msc is your friend. Keep it open while running this script
        to check progress and verify proper partitioning and formatting.

WARNING 1: Only have one Xbox One or future Xbox One drive connected when
           running this script to ensure the right drive gets formatted and
           avoid Offline signature collisions!

           This means disconnecting the SOURCE drive after:
           (b) Replace/Upgrade keeping original drive data
           but before:
           (c) Fix GUID values w/o formatting the drive
           When redoing the entire process run this step on the TARGET with
           the SOURCE disconnected:
           (g) Wipe drive of all partitions and GUID values

WARNING 2: Always use "Safely Remove Hardware and Eject Media" and "Eject" the
           newly created drive.
           If you receive the message: "Windows can't stop your
           'Generic volume' device because a program is still using it."
           Either shutdown your system and remove the drive or use
           diskmgmt.msc right click the disk, select "Offline", then "Online"
           and then "Safely Remove Hardware and Eject Media" and "Eject".

Primary script functions explained:
(a) Replace/Upgrade w/o a working original drive   (Standard Only)    - used to fix systems when the original drive has failed
(b) Replace/Upgrade keeping original drive data    (Standard and Non) - used to swap to a smaller or larger standard or non-standard drive
(c) Fix GUID values w/o formatting the drive       (Standard and Non) - should be used after step (b) and after disconnecting the SOURCE drive
(d) Backup "System Update" to current directory    (Standard and Non) - use before doing a Reset or Upgrade, better safe than sorry
(e) Restore "System Update" from current directory (Standard and Non) - use after doing a Reset or Upgrade, told you so
(f) Check all partitions for file system errors    (Standard and Non) - optionally check for filesystem corruption or prepare for Clonezilla
(g) Wipe drive of all partitions and GUID values   (Standard and Non) - used to blank a drive before rerunning step (b)
(h) CANCEL                                                            - skip making any drive modifications

Partition layout explained:
There are 5 partitions on an Xbox One drive. The 2nd partition 'User Content'
is what this selection refers to. The other 4 partitions are always the same
size regardless of the drive size.

All partitions are rounded to the nearest gibibyte (normally and not to be
confused with gigabyte). So options (d) through (g) will mostly do the right
thing. Options (a) through (c) are for wanting to force a particular size on
the target drive.

Most people should choose (a), (b), or (c). If you have a 256GB or 750GB you
should select (d). For 3TB, 4TB, or 5TB drives you should select (f).

(a) 500GB Standard (365GB)    (779MB Unallocated)
(b) 1TB Standard   (781GB)  (50.51GB Unallocated)
(c) 2TB Standard  (1662GB) (101.02GB Unallocated)
(d) Autosize Non-Standard w/ 500GB Disk GUID (1947GB MAX) - create an autosized 'User Content' resetting to 500GB
(e) Autosize Non-Standard w/ 1TB Disk GUID   (1947GB MAX) - create an autosized 'User Content' resetting to 1TB
(f) Autosize Non-Standard w/ 2TB Disk GUID   (1947GB MAX) - create an autosized 'User Content' resetting to 2TB


 1. Unzip xboxonehdd-master-7.zip to the Desktop which will create an xboxonehdd-master directory
 2. Open an Administrator Command Prompt:
    Windows 7: Click "Start Menu -> All Programs -> Accessories" right click "Command Prompt" select "Run as administrator"
    Windows 10 1607 and earlier: Right click "Start Menu" select "Command Prompt (Admin)"
    Windows 10 1703 and later: Right click "Start Menu" select "Windows PowerShell (Admin)"
 3. In the Command Prompt paste:
    Command Prompt:
    cd %USERPROFILE%\Desktop\xboxonehdd-master\win
    Windows PowerShell:
    cd $Env:USERPROFILE\Desktop\xboxonehdd-master\win
 4. Then paste:
    .\create_xbox_drive.bat
 5. Follow all the prompts and be sure to select the appropriate drive. Example below:

    **********************************************************************
    * create_xbox_drive.bat:                                             *
    * This script creates a correctly formatted Xbox One HDD against the *
    * drive YOU select.                                                  *
    * USE AT YOUR OWN RISK                                               *
    *                                                                    *
    * Created      2016.06.30.2.0                                        *
    * Last Updated 2018.05.10.7.0                                        *
    * Language ID  0409                                                  *
    **********************************************************************

    * Administrative permissions required. Detecting permissions...      *
    * Administrative permissions confirmed                               *

    * English language availability required. Checking...                *
    * English language availability confirmed                            *

    * Are required drive letters available? Checking...                  *
    * H: is free
    * I: is free
    * J: is free
    * K: is free
    * L: is free
    * Found U: - Local Fixed Disk  Temp Content
    * Found V: - Local Fixed Disk  User Content
    * Found W: - Local Fixed Disk  System Support
    * Found X: - Local Fixed Disk  System Update
    * Found Y: - Local Fixed Disk  System Update 2

    * WARNING: Any non-free drive letters above may interfere with this  *
    *          script. Adjust the letters used in the "Changeable drive  *
    *          letters" section near the top of this script.             *
    *          If you have an Xbox One drive attached non-free drive     *
    *          letters are expected.                                     *

    * This script will temporarily change the command line interface to  *
    * English and change it back when complete.                          *

    Press any key to continue . . .
        EnableLUA    REG_DWORD    0x1


                               [ Englishize Cmd v1.7a ]


    #  This script changes command line interface to English.

    #  Designed for localized non-English Windows Vista or above. Any languages.

    #  Note 1. A few programs without a .mui aren't affected, e.g. xcopy

            2. _files_to_process.txt can be customized to cover more/less commands

            3. English MUI can be installed through Windows Update or Vistalizator
               to support GUI programs such as Paint.

    . . .

    "This is a 64 Bit Operating System"

    Select Xbox One drive creation type:
    (a) Replace/Upgrade w/o a working original drive   (Standard Only)
    (b) Replace/Upgrade keeping original drive data    (Standard and Non)
    (c) Fix GUID values w/o formatting the drive       (Standard and Non)
    (d) Backup "System Update" to current directory    (Standard and Non)
    (e) Restore "System Update" from current directory (Standard and Non)
    (f) Check all partitions for file system errors    (Standard and Non)
    (g) Wipe drive of all partitions and GUID values   (Standard and Non)
    (h) CANCEL

    ?a

    * Scanning for connected USB/SATA drives . . .                       *

    Microsoft DiskPart version 10.0.16299.15

    Copyright (C) Microsoft Corporation.
    On computer: XFIX-1

      Disk ###  Status         Size     Free     Dyn  Gpt
      --------  -------------  -------  -------  ---  ---
      Disk 0    Online          447 GB      0 B
      Disk 1    Online         3726 GB      0 B        *
      Disk 2    Online         3726 GB      0 B        *
      Disk 3    Online         1863 GB   101 GB        *

    * Select TARGET Xbox One Drive . . .                   *
    Press 4 to CANCEL or use a Disk Number from the list above (default 4 in 30 seconds) [0,1,2,3,4]?3
    * Does selected disk contain C: Checking...                          *
    * Does not contain C: can continue                                   *

    GUID                                 Dev Size    Name
    5B114955-4A1C-45C4-86DC-D95070008139
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B U:    41 GB 'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 V:  1662 GB 'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 W:    40 GB 'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC X:    12 GB 'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 Y:  7168 MB 'System Update 2'

    WARNING: This will erase all data on this disk. Continue [Y,N]?Y

    * Disk 3 will be formatted as an Xbox One . . .                      *

    Select partition layout:
    (a) 500GB Standard
    (b) 1TB Standard
    (c) 2TB Standard
    (d) CANCEL

    ?c

    * Removing existing partitions with gdisk64 . . .                    *
    * Creating new partitions with gdisk64 . . .                         *
    * Updating GUID values with gdisk64 . . .                            *

    Giving USB/SATA devices time to settle, please wait . . .

    Microsoft DiskPart version 10.0.16299.15

    Copyright (C) Microsoft Corporation.
    On computer: XFIX-1

      Volume ###  Ltr  Label        Fs     Type        Size     Status     Info
      ----------  ---  -----------  -----  ----------  -------  ---------  --------
      Volume 0     D                       DVD-ROM         0 B  No Media
      Volume 1     E                       DVD-ROM         0 B  No Media
      Volume 2         System Rese  NTFS   Partition    100 MB  Healthy    System
      Volume 3     C                NTFS   Partition    447 GB  Healthy    Boot
      Volume 4     M   WD4TB        NTFS   Partition   3725 GB  Healthy
      Volume 5     N   WD4TB2       NTFS   Partition   3725 GB  Healthy
      Volume 6     J   Temp Conten  NTFS   Partition     41 GB  Healthy
      Volume 7     H   User Conten  NTFS   Partition   1662 GB  Healthy
      Volume 8     I   System Supp  NTFS   Partition     40 GB  Healthy
      Volume 9     F   System Upda  NTFS   Partition     12 GB  Healthy
      Volume 10    G   System Upda  NTFS   Partition   7168 MB  Healthy

    * Formatting new partitions with C:\WINDOWS\system32\format . . .    *
    * Formatting with C:\WINDOWS\system32\diskpart . . .                 *
    * Assigning drive letters with C:\WINDOWS\system32\diskpart . . .    *

    Microsoft DiskPart version 10.0.16299.15

    Copyright (C) Microsoft Corporation.
    On computer: XFIX-1

      Volume ###  Ltr  Label        Fs     Type        Size     Status     Info
      ----------  ---  -----------  -----  ----------  -------  ---------  --------
      Volume 0     D                       DVD-ROM         0 B  No Media
      Volume 1     E                       DVD-ROM         0 B  No Media
      Volume 2         System Rese  NTFS   Partition    100 MB  Healthy    System
      Volume 3     C                NTFS   Partition    447 GB  Healthy    Boot
      Volume 4     M   WD4TB        NTFS   Partition   3725 GB  Healthy
      Volume 5     N   WD4TB2       NTFS   Partition   3725 GB  Healthy
      Volume 6     U   Temp Conten  NTFS   Partition     41 GB  Healthy
      Volume 7     V   User Conten  NTFS   Partition   1662 GB  Healthy
      Volume 8     W   System Supp  NTFS   Partition     40 GB  Healthy
      Volume 9     X   System Upda  NTFS   Partition     12 GB  Healthy
      Volume 10    Y   System Upda  NTFS   Partition   7168 MB  Healthy



    GUID                                 Dev Size    Name
    5B114955-4A1C-45C4-86DC-D95070008139             (2TB)
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B U:    41 GB 'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 V:  1662 GB 'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 W:    40 GB 'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC X:    12 GB 'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 Y:  7168 MB 'System Update 2'


    * Found the X: drive.                                                *

    * Script execution complete.                                         *

    * This script will now change the command line interface back to the *
    * default language.                                                  *

    Press any key to continue . . .
        EnableLUA    REG_DWORD    0x1


                               [ Englishize Cmd v1.7a ]


    #  This script restores the command line interface back to original

    . . .

    #  Completed.

 6. The last bit of output should look like the following, except for the
    first line depending on the drive size, if not run the script again:
    A2344BDB-D6DE-4766-9EB5-4109A12228E5             (500GB)
    25E8A1B2-0B2A-4474-93FA-35B847D97EE5             (1TB)

    GUID                                 Dev Size    Name
    5B114955-4A1C-45C4-86DC-D95070008139             (2TB)
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B U:    41 GB 'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 V:   365 GB 'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 W:    40 GB 'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC X:    12 GB 'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 Y:  7168 MB 'System Update 2'

 7. To view the log file paste this:
    Command Prompt:
    notepad %TEMP%\create_xbox_drive.log
    notepad %TEMP%\RoboCopy-Temp_Content.log
    notepad %TEMP%\RoboCopy-User_Content.log
    notepad %TEMP%\RoboCopy-System_Support.log
    notepad %TEMP%\RoboCopy-System_Update.log
    notepad %TEMP%\RoboCopy-System_Update_2.log
    Windows PowerShell:
    notepad $Env:TEMP\create_xbox_drive.log
    notepad $Env:TEMP\RoboCopy-Temp_Content.log
    notepad $Env:TEMP\RoboCopy-User_Content.log
    notepad $Env:TEMP\RoboCopy-System_Support.log
    notepad $Env:TEMP\RoboCopy-System_Update.log
    notepad $Env:TEMP\RoboCopy-System_Update_2.log

 8. OPTIONAL (skip if OSU1 doesn't match the last successful update):
    Download the latest OSU1.zip which contains the files:

    $SystemUpdate/host.xvd
    $SystemUpdate/SettingsTemplate.xvd
    $SystemUpdate/system.xvd
    $SystemUpdate/systemaux.xvd
    $SystemUpdate/systemmisc.xvd
    $SystemUpdate/systemtools.xvd
    $SystemUpdate/updater.xvd

    Place them in the 'System Update' partition as:

    A/host.xvd
    A/SettingsTemplate.xvd
    A/system.xvd
    A/systemaux.xvd
    A/systemmisc.xvd
    A/systemtools.xvd
    B/host.xvd
    B/SettingsTemplate.xvd
    B/system.xvd
    B/systemaux.xvd
    B/systemmisc.xvd
    B/systemtools.xvd
    updater.xvd
