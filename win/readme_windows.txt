Creates a properly partitioned Xbox One hard drive. You'll want to source the
entire original drive files or use the latest OSU1 or OSU2 files.

Don't use a drive smaller than 500GB or larger than 2TB or you'll see E200
errors.

This script is a direct replacement to create_xbox_drive.sh for Linux and
tested on Windows 7 and 10.

You'll need some sort of SATA to USB device or have the ability to connect a
SATA drive directly to your Windows PC.

NOTE: For this script to work on non-English Windows systems
      C:\Windows\System32\en-US needs to be present.
      Control Panel\All Control Panel Items\Language\Add languages
      English (United States)

NOTE: Click "Cancel" or "X" on any "You need to format the disk in drive X:
      before you can use it." messages.

WARNING 1: Only have one Xbox One or future Xbox One drive connected when
           running this script to ensure the right drive gets formatted and
           avoid Offline signature collisions!

WARNING 2: Alway use "Safely Remove Hardware and Eject Media" and "Eject" the
           newly created drive.
           If you receive the message: "Windows can't stop your
           'Generic volume' device because a program is still using it."
           Either shutdown your system and remove the drive or use
           diskmgmt.msc right click the disk, select "Offline", then "Online"
           and then "Safely Remove Hardware and Eject Media" and "Eject".

Partition layout explained.
There are 5 partitions on an Xbox One drive. The 2nd partition 'User Content'
is what this selection refers to. The other 4 partitions are always the same
size regardless of the drive size.

All partitions are rounded to the nearest gibibyte (normally). So option (a)
will mostly do the right thing. Options (b) through (d) are for wanting to
force a particular size on a drive at the size selected.

"Large" means to not round 'User Content' to the nearest gibibyte and make use
of the left over megabytes. "Standard" uses the original sizes and leaves some
space unused.

Most people should choose (b), (c), or (d). If you have a 3TB or 4TB drive for
example you should select (d).

(a) Autosize Non-Standard - will create an appropriate 'User Content' partition size regardless of the drive size
(b) 500GB Standard - 365 GB XB1 Standard Size (779 MB Unallocated)
(c) 1TB Standard - 781 GB XB1 Standard Size (50.51 GB Unallocated)
(d) 2TB Standard - 1662 GB XB1 Standard Size (101.02 GB Unallocated)

 1. Unzip xboxonehdd-master-5.zip to the Desktop which will create an xboxonehdd-master directory
 2. Open an Administrator Command Prompt:
    Windows 7: Click "Start Menu -> All Programs -> Accessories" right click "Command Prompt" select "Run as administrator"
    Windows 10: Right click "Start Menu" select "Command Prompt (Admin)"
 3. In the Command Prompt paste:
    cd %USERPROFILE%\Desktop\xboxonehdd-master\win
 4. Then paste:
    create_xbox_drive.bat
 5. Follow all the prompts and be sure to select the appropriate drive. Example below:

    **********************************************************************
    * create_xbox_drive.bat:                                             *
    * This script creates a correctly formated Xbox One HDD against the  *
    * drive YOU select.                                                  *
    * USE AT YOUR OWN RISK                                               *
    *                                                                    *
    * Created      2016.06.30                                            *
    * Last Updated 2017.05.24                                            *
    **********************************************************************

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
    * Scanning for connected USB/SATA drives . . .                       *

    Microsoft DiskPart version 10.0.14393.0
    Copyright (C) 1999-2013 Microsoft Corporation.
    On computer: XFIX-1

      Disk ###  Status         Size     Free     Dyn  Gpt
      --------  -------------  -------  -------  ---  ---
      Disk 0    Online          447 GB      0 B
      Disk 1    Online         3726 GB      0 B        *
      Disk 2    Online         3726 GB      0 B        *
      Disk 3    Online         1863 GB   101 GB        *

    * Select disk to format as an Xbox One Drive . . .                   *
    Press 0 to CANCEL or use a Disk Number from the list above (default 0 in 30 seco
    nds) [0,1,2,3]?3

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
    (a) Autosize Non-Standard
    (b) 500GB Standard
    (c) 1TB Standard
    (d) 2TB Standard

    ?d

    * Removing existing partitions with gdisk64 . . .                    *
    * Creating new partitions with gdisk64 . . .                         *


    Giving USB/SATA devices time to settle, please wait . . .

    Microsoft DiskPart version 10.0.14393.0
    Copyright (C) 1999-2013 Microsoft Corporation.
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

    * Formatting new partitions with C:\Windows\system32\format . . .    *
    * Formatting and assigning drive letters with C:\Windows\system32\diskpart . . .


    Microsoft DiskPart version 10.0.14393.0
    Copyright (C) 1999-2013 Microsoft Corporation.
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
    notepad %TEMP%\create_xbox_drive.log

 8. Download the latest OSU1.zip or OSU2.zip which contains the files:

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
