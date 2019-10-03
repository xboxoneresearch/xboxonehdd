Creates a properly partitioned Xbox One hard drive. You'll want to source the entire original drive files or use the latest OSUDT2 or OSUDT3 files.
Don't use a drive smaller than 500GB or larger than 2TB or you'll see E200 errors.
Make an "UBUNTU FAT32" flash drive with ubuntu-16.04-desktop-amd64.iso or newer created with LinuxLive USB Creator 2.9.4.exe
You'll need some sort of SATA to USB device or have the ability to connect a SATA drive directly to your PC.

 1. Unzip xboxonehdd-master-2.zip to the root of the "UBUNTU FAT32" flash drive which will create an xboxonehdd-master directory
 2. Boot the "UBUNTU FAT32" flash drive
 3. Open Terminal
 4. Use the following command to find the drive you wish to parition, sdb in my case but your case may be different:
    dmesg | less
 5. cd /media/cdrom/xboxonehdd-master
 6. sudo ./create_xbox_drive.sh

    Usage: create_xbox_drive.sh [options]

    Options:
    -d|--drive    Drive to install XBox filesystem
    -s|--stage    Install stage [0|1|2]
                  0 - will only erase a drive
                  1 - will erase and partition a drive
                  2 - will rewrite the drive GUIDs
    -h|--help     Display help

    Examples:
    create_xbox_drive.sh --drive /dev/sdb --stage 0 (Erase a drive)
    create_xbox_drive.sh --drive /dev/sdb --stage 1 (Partition new drive)
    create_xbox_drive.sh --drive /dev/sdb --stage 2 (Rewrite GUIDs)

 7. sudo ./create_xbox_drive.sh -d /dev/sdb -s 1
 8. sudo ./create_xbox_drive.sh -d /dev/sdb -s 2
 9. Check to see that your newly created drive matches the output below:

    sudo ./list_part_info.sh sdb
    GUID                                 Device    Name
    A2344BDB-D6DE-4766-9EB5-4109A12228E5 /dev/sdb
    B3727DA5-A3AC-4B3D-9FD6-2EA54441011B /dev/sdb1 'Temp Content'
    869BB5E0-3356-4BE6-85F7-29323A675CC7 /dev/sdb2 'User Content'
    C90D7A47-CCB9-4CBA-8C66-0459F6B85724 /dev/sdb3 'System Support'
    9A056AD7-32ED-4141-AEB1-AFB9BD5565DC /dev/sdb4 'System Update'
    24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 /dev/sdb5 'System Update 2'

10. Mount /media/ubuntu/System\ Update/ by right clicking the proper drive in the left hand menu and select Open
11. Download the latest OSUDT2.zip or OSUDT3.zip which contains the files:

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
