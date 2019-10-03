Creates a properly partitioned Xbox One hard drive. You'll want to source the entire original drive files or use the latest OSUDT2 or OSUDT3 files.
Don't use a drive smaller than 500GB or larger than 2TB or you'll see E200 errors.
This script is a direct replacement to create_xbox_drive.sh for Linux and tested on Windows 7 and 10.
You'll need some sort of SATA to USB device or have the ability to connect a SATA drive directly to your Windows PC.
NOTE: Click "Cancel" or "X" on any "You need to format the disk in drive X: before you can use it." messages.

Partition layout explained.
There are 5 partitions on an Xbox One drive. The 2nd partition 'User Content' is what this selection refers to. The other 4 partitions are always the same size regardless of the drive size.
All partitions are rounded to the nearest gigabyte (normally). So option (a) will always do the right thing. Options (b) through (g) are for wanting to force a particular size on a drive at or larger than the size selected.
"Large" means to not round 'User Content' to the nearest gigabyte and make use of the left over megabytes. "Standard" uses the original sizes and leaves some space unused.
Most people should choose (a). If you have a 3TB or 4TB drive for example you should select (f) or (g).

(a) Autosize - will create an appropriate 'User Content' partition size regardless of the drive size
(b) 500GB Standard - Microsoft standard size
(c) 500GB Large - 365 GB + 779 MB
(d) 1TB Standard - Microsoft standard size
(e) 1TB Large - 831 GB + 524 MB
(f) 2TB Standard - Microsoft standard size
(g) 2TB Large - 1863 GB + 16 MB

 1. Unzip xboxonehdd-master-2.zip to the Desktop which will create an xboxonehdd-master directory
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
    * Last Updated 2016.06.30                                            *
    **********************************************************************

    Press any key to continue . . .
    "This is a 64 Bit Operating System"
    * Scanning for connected USB/SATA drives . . .                       *

    Microsoft DiskPart version 6.1.7601
    Copyright (C) 1999-2008 Microsoft Corporation.
    On computer: XFIX-1

      Disk ###  Status         Size     Free     Dyn  Gpt
      --------  -------------  -------  -------  ---  ---
      Disk 0    Online          447 GB      0 B
      Disk 1    Online         3726 GB      0 B        *
      Disk 2    Online         3726 GB      0 B        *
      Disk 3    Online          465 GB   779 MB        *

    * Select disk to format as an Xbox One Drive . . .                   *
    Press 0 to CANCEL or use a Disk Number from the list above (default 0 in 30 seco
    nds) [0,1,2,3]?3

    GUID                                 Device Name
    A2344BDB-D6DE-4766-9EB5-4109A12228E5
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B U:     'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 V:     'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 W:     'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC X:     'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 Y:     'System Update 2'

    WARNING: This will erase all data on this disk. Continue [Y,N]?Y

    * Disk 3 will be formatted as an Xbox One . . .                      *

    Select partition layout:
    (a) Autosize
    (b) 500GB Standard
    (c) 500GB Large
    (d) 1TB Standard
    (e) 1TB Large
    (f) 2TB Standard
    (g) 2TB Large

    ?a

    * Removing existing partitions with gdisk64 . . .                    *
    * Creating new partitions with gdisk64 . . .                         *


    Giving USB/SATA devices time to settle . . . C

    Microsoft DiskPart version 6.1.7601
    Copyright (C) 1999-2008 Microsoft Corporation.
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
      Volume 7     H   User Conten  NTFS   Partition    365 GB  Healthy
      Volume 8     I   System Supp  NTFS   Partition     40 GB  Healthy
      Volume 9     F   System Upda  NTFS   Partition     12 GB  Healthy
      Volume 10    G   System Upda  NTFS   Partition   7168 MB  Healthy

    * Formatting new partitions with C:\Windows\system32\format . . .    *
    * Formatting and assigning drive letters with C:\Windows\system32\diskpart . . .


    Microsoft DiskPart version 6.1.7601
    Copyright (C) 1999-2008 Microsoft Corporation.
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
      Volume 7     V   User Conten  NTFS   Partition    365 GB  Healthy
      Volume 8     W   System Supp  NTFS   Partition     40 GB  Healthy
      Volume 9     X   System Upda  NTFS   Partition     12 GB  Healthy
      Volume 10    Y   System Upda  NTFS   Partition   7168 MB  Healthy



    GUID                                 Device Name
    A2344BDB-D6DE-4766-9EB5-4109A12228E5
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B U:     'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 V:     'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 W:     'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC X:     'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 Y:     'System Update 2'


    * Found the X: drive.                                                *

 6. The last bit of output should look like the following, if not run the script again:

    GUID                                 Device Name
    A2344BDB-D6DE-4766-9EB5-4109A12228E5
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B U:     'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 V:     'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 W:     'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC X:     'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 Y:     'System Update 2'

 7. To view the log file paste this:
    notepad %TEMP%\create_xbox_drive.log
