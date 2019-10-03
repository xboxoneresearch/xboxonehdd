Creates a properly partitioned Xbox One hard drive. You'll want to source the
entire original drive files or use the latest OSU1 or OSU2 files.

Don't use a drive smaller than 500GB or larger than 2TB or you'll see E200
errors.

Make an "UBUNTU FAT32" flash drive with ubuntu-16.10-desktop-amd64.iso or
newer created with LinuxLive USB Creator 2.9.4.exe

You'll need some sort of SATA to USB device or have the ability to connect a
SATA drive directly to your PC.

 1. Unzip xboxonehdd-master-5.zip to the root of the "UBUNTU FAT32" flash drive which will create an xboxonehdd-master directory
 2. Boot the "UBUNTU FAT32" flash drive and choose "Try Ubuntu"
 3. Right click the desktop and select "Open Terminal"
 4. cd /media/cdrom/xboxonehdd-master/linux
 5. Use the following command to find the drive you wish to parition, /dev/sdb in my case but your case may be different:
    sudo ./list_part_info.sh

    Current Drive List:
    Disk /dev/sda: 480GB
    Disk /dev/sdb: 2000GB
    Disk /dev/sdc: 16.0GB

    Usage: list_part_info.sh /dev/sd*

    Examples:
    list_part_info.sh /dev/sdb (List Disk Partition Information)

 6. sudo ./create_xbox_drive.sh

    Usage: create_xbox_drive.sh [options]

    Options:
    -d|--drive     Drive to install XBox filesystem
    -s|--stage     Install stage [0|1|2]
                   0 - will only erase a drive
                   1 - will erase and partition a drive
                   2 - will rewrite the drive GUIDs
    -m|--mirror    Mirror partition table to original [0|1|2]
                   0 - 500GB
                   1 - 1TB
                   2 - 2TB
    -h|--help      Display help

    Examples:
    create_xbox_drive.sh -d /dev/sdb -s 0 (Erase a drive)
    create_xbox_drive.sh -d /dev/sdb -s 1 -m 2 (Partition new 2TB drive)
    create_xbox_drive.sh -d /dev/sdb -s 2 -m 2 (Rewrite 2TB GUIDs)

 7. First erase and partition the specified drive:
    NOTE: Replace /dev/sdb with your drive and change -m 2 to
    -m 0 for 500GB drives and -m 1 for 1TB drives
    sudo ./create_xbox_drive.sh -d /dev/sdb -s 1 -m 2
 8. Second rewrite the drive GUID values to Xbox One compatible ones:
    NOTE: Again replace /dev/sdb with your drive and change -m 2 to
    -m 0 for 500GB drives and -m 1 for 1TB drives
    sudo ./create_xbox_drive.sh -d /dev/sdb -s 2 -m 2
 9. Check to see that your newly created drive matches the output below:
    5B114955-4A1C-45C4-86DC-D95070008139 /dev/sd*  (2TB)
    25E8A1B2-0B2A-4474-93FA-35B847D97EE5 /dev/sd*  (1TB)
    A2344BDB-D6DE-4766-9EB5-4109A12228E5 /dev/sd*  (500GB)

    sudo ./list_part_info.sh /dev/sdb
    GUID                                 Dev       Size        Name
    5B114955-4A1C-45C4-86DC-D95070008139 /dev/sdb
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B /dev/sdb1  (41.0 GiB) 'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 /dev/sdb2   (1.6 TiB) 'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 /dev/sdb3  (40.0 GiB) 'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC /dev/sdb4  (12.0 GiB) 'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 /dev/sdb5   (7.0 GiB) 'System Update 2'

10. Mount /media/ubuntu/System\ Update/ by right clicking the proper drive in the left hand menu and select Open
11. Download the latest OSU1.zip or OSU2.zip which contains the files:

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
