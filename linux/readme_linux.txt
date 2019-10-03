Last Updated: 2018/11/16
Author: XFiX
https://gbatemp.net/threads/xbox-one-internal-hard-drive-upgrade-or-repair-build-any-size-drive-that-works-on-any-console.496212/
https://www.youtube.com/playlist?list=PLURaLwRqr6g14Pl8qLO0E4ELBBCHfFh1V

Creates a properly partitioned Xbox One hard drive. You'll want to source the
entire original drive files or use the latest OSU1 files.

FEATURES:
1. Wipe drive of all partitions and GUID values
2. Create a Standard Xbox One 500GB, 1TB, or 2TB internal hard drive
3. Upgrade a Standard Xbox One drive to non-standard sizes including
   as small as 138GB, as large as 1947GB, and other non-standard sizes
4. Set Standard Xbox One GUID values w/o formatting the drive

Make an "UBUNTU FAT32" flash drive with ubuntu-17.10.1-desktop-amd64.iso or
newer created with LinuxLive USB Creator 2.9.4.exe

Download Linux Live USB Creator:
http://www.linuxliveusb.com/en/download

Download Ubuntu Desktop:
https://www.ubuntu.com/download/desktop

You'll need some sort of USB to SATA device or have the ability to connect a
SATA drive directly to your PC. I recommend the USB3S2SAT3CB USB 3.0 to SATA
adapter cable.


NOTES AND WARNINGS:
NOTE 1: Xbox One internal drives have a 2TB limit that you cannot get around.
        This is a bug or feature by Microsoft's design.
        This is the video I made trying to fill a 5TB internal drive.
        https://www.youtube.com/watch?v=tcoa8Xx_6oU
        Version 7.0 and above max the "User Content" partition out at 1947GB.
        Theoretically you can created a larger partition than this but you
        cannot use the additional space.

WARNING 1: E100 is bad. It is possible to do an offline update to resolve it
           but this mostly isn't the case. E100 is the only know error that
           actually refers to the Blu-ray drive. Under certain circumstances
           during an Xbox One update the Blu-ray drive firmware can become
           permanently corrupted. Any sort of Blu-ray drive failure involving
           the daughterboard will brick your system since only the original
           factory matching Xbox One motherboard and Blu-ray daughterboard can
           be used together.
           YOU CANNOT REPLACE A BLU-RAY DAUGHTERBOARD FROM ANOTHER SYSTEM!


REPAIR AND UPGRADE PATHS:
Xbox One Internal Hard Drive Direct Copy Upgrade
https://www.youtube.com/watch?v=iZiUyx7oH_E

Xbox One Internal Hard Drive Repair or Replace
https://www.youtube.com/watch?v=CTLOhi3tbEs


EXAMPLE SCRIPT USAGE AND OUTPUT:
 1. Unzip xboxonehdd-master-7.zip to the root of the "UBUNTU FAT32" flash drive which will create an xboxonehdd-master directory
 2. Boot the "UBUNTU FAT32" flash drive and choose "Try Ubuntu"
 3. Right click the desktop and select "Open Terminal"
 4. cd /media/cdrom/xboxonehdd-master/linux
 5. Use the following command to find the drive you wish to partition, /dev/sdb in my case but your case may be different:
    sudo ./list_part_info.sh

    Current Drive List:
    Disk /dev/sda: 480GB
    Disk /dev/sdb: 2000GB
    Disk /dev/sdc: 16.0GB

    Usage: list_part_info.sh /dev/sd*

    Examples:
    list_part_info.sh /dev/sdb (List Disk Partition Information)

 6. sudo ./create_xbox_drive.sh

    Last Updated: 2018.05.10.7.0
    Usage: create_xbox_drive.sh [options]

    Options:
    -c|--source      Source drive to copy data to target drive -d with -s 2
    -d|--drive       Target drive to install Xbox filesystem
    -s|--stage       Install stage [0|1|2|3]
                     0 - will fully erase drive -d
                     1 - will erase and partition drive -d
                     2 - will copy source drive -c data to target drive -d
                     3 - will rewrite drive -d GUIDs
    -t|--disktype    Disk GUID to set [0|1|2]
                     0 - 500GB
                     1 - 1TB
                     2 - 2TB
    -m|--mirror      Mirror standard partition sizes specified with -t on drive -d
                     Not using this option will autosize 'User Content'
    -h|--help        Display help

    Examples:
    create_xbox_drive.sh -d /dev/sdb -s 0 (Erase a drive)
    create_xbox_drive.sh -d /dev/sdb -s 1 -t 2 -m (Partition standard 2TB drive)
    create_xbox_drive.sh -d /dev/sdb -s 3 -t 2 -m (Rewrite 2TB GUIDs)

 7. First erase and partition the specified drive:

    NOTE: Replace /dev/sdb with your drive, change -t 2 to -t 0 for
    500GB drives and -t 1 for 1TB drives, and optionally use -m to force
    standard Xbox One Partition sizes

    sudo ./create_xbox_drive.sh -d /dev/sdb -s 1 -t 2 -m
 8. OPTIONAL (skip if you don't have a working standard Xbox One drive):
    Second if you have a working standard Xbox One drive you can copy the data
    from that drive to the new drive with:

    NOTE: Replace /dev/sda with your source drive, /dev/sdb with your target
    drive, change -t 2 to -t 0 for 500GB drives and -t 1 for 1TB drives, and
    optionally use -m to force standard Xbox One Partition sizes

    sudo ./create_xbox_drive.sh -c /dev/sda -d /dev/sdb -s 2 -t 2 -m
 9. Third rewrite the drive GUID values to Xbox One compatible ones:

    NOTE: Again replace /dev/sdb with your drive, change -t 2 to -t 0 for
    500GB drives and -t 1 for 1TB drives, and optionally use -m to force
    standard Xbox One Partition sizes

    sudo ./create_xbox_drive.sh -d /dev/sdb -s 3 -t 2 -m
10. Check to see that your newly created drive matches the output below:
    5B114955-4A1C-45C4-86DC-D95070008139 /dev/sd*  (2TB)
    25E8A1B2-0B2A-4474-93FA-35B847D97EE5 /dev/sd*  (1TB)
    A2344BDB-D6DE-4766-9EB5-4109A12228E5 /dev/sd*  (500GB)

    sudo ./list_part_info.sh /dev/sdb
    GUID                                 Dev       Size        Name
    5B114955-4A1C-45C4-86DC-D95070008139 /dev/sdb              (2TB)
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B /dev/sdb1  (41.0 GiB) 'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 /dev/sdb2   (1.6 TiB) 'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 /dev/sdb3  (40.0 GiB) 'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC /dev/sdb4  (12.0 GiB) 'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 /dev/sdb5   (7.0 GiB) 'System Update 2'

11. OPTIONAL (skip if you are able to do step 8, also skip if OSU1 doesn't
    match the last successful update):
    Mount /media/ubuntu/System\ Update/ by right clicking the proper drive in
    the left hand menu and select Open
12. OPTIONAL (skip if you are able to do step 8, also skip if OSU1 doesn't
    match the last successful update):
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
