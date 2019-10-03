#!/bin/bash
################################################################################
#
#  Author: Ludvik Jerabek
#  Date: 2014/07/09
#  Version: 5.0
#
#  Summary:
#  Create a true Xbox One 500GB, 1TB, or 2TB filesystem
#  This process is not a hack anymore
#  Past methods stretched a 500GB's filesystem
#  Now we create a resettable 500GB/1TB/2TB drive on ANY Xbox One OG/S console
#  Use at your own risk
#
#  Change History:
#  2014/07/09 - Initial Release - Ludvik Jerabek
#  2016/05/13 - Added Original XBox User Content size --mirror option
#  2016/05/17 - Fixed disk size calculation physical vs logical blocks
#  2016/01/07 - Removed MBR Patching and added --stage 0 - XFiX
#  2017/05/24 - Original 1TB and 2TB GUID Support with --mirror [0|1|2] - XFiX
#  2017/05/31 - Improved list_part_info.sh to help find the proper disk - XFiX
#
#  Credit History:
#  2013/11 - Juvenal of Team Xecuter created the first working Python script
#  http://team-xecuter.com/forums/threads/141568-XBOX-ONE-How-To-Install-A-Bigger-Hard-Drive-%21
#
#  2014/07 - Ludvik Jerabek created the first bash script
#  http://www.ludvikjerabek.com/2014/07/14/xbox-one-fun-with-gpt-disk/
#
#  2016/06 - XFiX created a Windows batch script based on the bash script
#  https://www.youtube.com/playlist?list=PLURaLwRqr6g14Pl8qLO0E4ELBBCHfFh1V
#
#  2017/05 - A1DR1K discovered the secret behind what differentiates
#  500GB, 1TB, and 2TB Xbox One system hard drives
#  https://www.reddit.com/user/A1DR1K
#
################################################################################
if [ $UID -ne 0 ]
then
	echo "Program must be run as root" 1>&2
	exit 1
fi
################################################################################
#
# Common GUIDs used by XBox One
#
################################################################################
DISK_GUID_2TB='5B114955-4A1C-45C4-86DC-D95070008139'
DISK_GUID_1TB='25E8A1B2-0B2A-4474-93FA-35B847D97EE5'
DISK_GUID_500GB='A2344BDB-D6DE-4766-9EB5-4109A12228E5'
TEMP_CONTENT_GUID='B3727DA5-A3AC-4B3D-9FD6-2EA54441011B'
USER_CONTENT_GUID='869BB5E0-3356-4BE6-85F7-29323A675CC7'
SYSTEM_SUPPORT_GUID='C90D7A47-CCB9-4CBA-8C66-0459F6B85724'
SYSTEM_UPDATE_GUID='9A056AD7-32ED-4141-AEB1-AFB9BD5565DC'
SYSTEM_UPDATE2_GUID='24B2197C-9D01-45F9-A8E1-DBBCFA161EB2'

################################################################################
#
# Common partition sizes used by XBox One (500GB drive)
#
################################################################################
# Xbox temp partition size (41G)
XBOX_TEMP_SIZE_IN_BYTES=44023414784
# Xbox support partition size (40G)
XBOX_SUPPORT_SIZE_IN_BYTES=42949672960
# Xbox update partition size (12G)
XBOX_UPDATE_SIZE_IN_BYTES=12884901888
# Xbox update 2 partition size (7G)
XBOX_UPDATE_SIZE2_IN_BYTES=7516192768
# XBox Original 2TB User Partion
XBOX_USER_2TB_SIZE_IN_BYTES=1784558911488
# XBox Original 1TB User Partion
XBOX_USER_1TB_SIZE_IN_BYTES=838592364544
# XBox Original 500GB User Partion
XBOX_USER_500GB_SIZE_IN_BYTES=391915765760


function usage() {
cat << EOF
Usage: $(basename $0) [options]

Options:
EOF

cat << EOF | column -s\& -t
-d|--drive & Drive to install XBox filesystem
-s|--stage & Install stage [0|1|2]
           & 0 - will only erase a drive
           & 1 - will erase and partition a drive
           & 2 - will rewrite the drive GUIDs
-m|--mirror & Mirror partition table to original [0|1|2]
            & 0 - 500GB
            & 1 - 1TB
            & 2 - 2TB
-h|--help & Display help

EOF

cat << EOF

Examples:
$(basename $0) -d /dev/sdb -s 0 (Erase a drive)
$(basename $0) -d /dev/sdb -s 1 -m 2 (Partition new 2TB drive)
$(basename $0) -d /dev/sdb -s 2 -m 2 (Rewrite 2TB GUIDs)

EOF
} # function usage()


function create_xbox_parts() {
    local DEV=$1

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Device: ${DEV}"

    # Get the device id from /dev/sdX (eg. sda, sdb)
    local DEV_ID=${DEV##*/}

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Device Id: ${DEV_ID}"

    # In theory partitions should be aligned to physical blocks for optimum performance.
    # Physical block size in bytes (eg. 512, 1024, 2048, 4096)
    # XFiX Ubuntu 15.04 always 512?
    local DEV_PHYSICAL_BLOCK_SIZE_IN_BYTES=$(cat /sys/block/${DEV_ID}/queue/physical_block_size)

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Physical Block Size: ${DEV_PHYSICAL_BLOCK_SIZE_IN_BYTES}"

    # Logical block size in bytes (eg. 512, 1024, 2048, 4096)
    # XFiX Ubuntu 15.04 always 512 (Have not seen a different Physical vs Logical yet)?
    local DEV_LOGICAL_BLOCK_SIZE_IN_BYTES=$(cat /sys/block/${DEV_ID}/queue/logical_block_size)

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Logical Block Size: ${DEV_LOGICAL_BLOCK_SIZE_IN_BYTES}"

    # Size of the device in blocks
    # XFiX: 3907029168
    local DEV_SIZE_IN_LOGICAL_BLOCKS=$(cat /sys/class/block/${DEV_ID}/size)

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Size In Logical Blocks: ${DEV_SIZE_IN_LOGICAL_BLOCKS}"

    # Size of the device in bytes
    # XFiX: 16003191472128
    local DEV_SIZE_IN_BYTES=$((DEV_SIZE_IN_LOGICAL_BLOCKS*DEV_LOGICAL_BLOCK_SIZE_IN_BYTES))

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Size In Bytes: ${DEV_SIZE_IN_BYTES}"

    # Size of the device in physical blocks
    local DEV_SIZE_IN_PHYSICAL_BLOCKS=$((DEV_SIZE_IN_BYTES/DEV_PHYSICAL_BLOCK_SIZE_IN_BYTES))

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Size In Physical Blocks: ${DEV_SIZE_IN_PHYSICAL_BLOCKS}"


    # New user content partition size (eg. Using a 500GB drive it's rougly 392733679616 bytes = 365G )
    local XBOX_USER_PARTITION_IN_BYTES=0

    # Force 500GB/1TB/2TB User Partition
    # XFiX Mirror option forces all drives to be 500GB/1TB/2TB equivalent
    NEXT_MSG=""
    if [ ! -z $OPT_MIRROR ]
    then
        NEXT_MSG=" --mirror ${OPT_MIRROR}"
        case $OPT_MIRROR in
        0)
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_500GB_SIZE_IN_BYTES}
            echo "Forcing User Content partition to original XBox One 500GB size: ${XBOX_USER_PARTITION_IN_BYTES}"
        ;;
        1)
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_1TB_SIZE_IN_BYTES}
            echo "Forcing User Content partition to original XBox One 1TB size: ${XBOX_USER_PARTITION_IN_BYTES}"
        ;;
        2)
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_2TB_SIZE_IN_BYTES}
            echo "Forcing User Content partition to original XBox One 2TB size: ${XBOX_USER_PARTITION_IN_BYTES}"
        ;;
        esac
    else
	XBOX_USER_PARTITION_IN_BYTES=$((DEV_SIZE_IN_BYTES - XBOX_TEMP_SIZE_IN_BYTES - XBOX_SUPPORT_SIZE_IN_BYTES - XBOX_UPDATE_SIZE_IN_BYTES - XBOX_UPDATE_SIZE2_IN_BYTES))
	# Align the data to the nearest GB
	XBOX_USER_PARTITION_IN_BYTES=$(((XBOX_USER_PARTITION_IN_BYTES/1073741824)*1073741824))
	echo "Dynamic sizing User Content partiton: ${XBOX_USER_PARTITION_IN_BYTES}"
    fi

    # Make sure all partitions are not mounted
    umount ${DEV}* 2>/dev/null

    # Remove all existing partitions
    sgdisk --zap-all ${DEV} 2>/dev/null 1>&2
    if [ $? -eq 0 ]
    then
        echo "${DEV} has been successfully wiped"
    else
        echo "${DEV} wipe failed" 1>&2
        exit 2
    fi

    # Initialize to 2048
    local START_SECTOR=2048
    local END_SECTOR=$(((XBOX_TEMP_SIZE_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 1 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=1:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=1:0700 ${DEV}
    sgdisk --change-name="1:Temp Content" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((XBOX_USER_PARTITION_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 2 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=2:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=2:0700 ${DEV}
    sgdisk --change-name="2:User Content" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((XBOX_SUPPORT_SIZE_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 3 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=3:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=3:0700 ${DEV}
    sgdisk --change-name="3:System Support" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((XBOX_UPDATE_SIZE_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 4 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=4:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=4:0700 ${DEV}
    sgdisk --change-name="4:System Update" ${DEV}


    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((XBOX_UPDATE_SIZE2_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 5 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=5:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=5:0700 ${DEV}
    sgdisk --change-name="5:System Update 2" ${DEV}


    # Make sure the partitions are not mounted some systems will automount and break the mkntfs commands below
    umount ${DEV}* 2>/dev/null

    # Name the NTFS partition accordingly
    mkntfs -q "${DEV}1" -f -L "Temp Content"
    mkntfs -q "${DEV}2" -f -L "User Content"
    mkntfs -q "${DEV}3" -f -L "System Support"
    mkntfs -q "${DEV}4" -f -L "System Update"
    mkntfs -q "${DEV}5" -f -L "System Update 2"

    echo "Disk Partitioning Complete"
    echo "Copy the folder contents from the original drive once complete run:"
    echo "'$(basename $0) --drive ${DEV} --stage 2${NEXT_MSG}'"
} # function create_xbox_parts()


function write_xbox_guids() {
    local DEV=$1

    # Make sure the partitions are not mounted some systems will automount and break the mkntfs commands below
    umount ${DEV}* 2>/dev/null

    # Force 500GB/1TB/2TB User Partition
    # XFiX Mirror option forces all drives to be 500GB/1TB/2TB equivalent
    if [ ! -z $OPT_MIRROR ]
    then
        case $OPT_MIRROR in
        0)
            DISK_GUID=${DISK_GUID_500GB}
        ;;
        1)
            DISK_GUID=${DISK_GUID_1TB}
        ;;
        2)
            DISK_GUID=${DISK_GUID_2TB}
        ;;
        esac
    else
        DISK_GUID=${DISK_GUID_500GB}
    fi

    # Disk GUID
    sgdisk --disk-guid=${DISK_GUID} ${DEV}
    # Partition 1 Guid
    sgdisk --partition-guid=1:${TEMP_CONTENT_GUID} ${DEV}
    # Partition 2 Guid
    sgdisk --partition-guid=2:${USER_CONTENT_GUID} ${DEV}
    # Partition 3 Guid
    sgdisk --partition-guid=3:${SYSTEM_SUPPORT_GUID} ${DEV}
    # Partition 4 Guid
    sgdisk --partition-guid=4:${SYSTEM_UPDATE_GUID} ${DEV}
    # Partition 5 Guid
    sgdisk --partition-guid=5:${SYSTEM_UPDATE2_GUID} ${DEV}
    echo "GUID Rewrite Complete"
    echo

    # XFiX: This is only for external drives?
    # Patching MBR from 55AA to 99CC
    ##echo -en '\x99\xCC' | dd conv=notrunc of=${DEV} bs=1 seek=510 2>/dev/null 1>&2
    ##if [ $? -eq 0 ]
    ##then
    ##	echo "MBR Patch Complete"
    ##else
    ##	echo "MBR Patch Failed" 1>&2
    ##fi

    $(dirname $0)/list_part_info.sh ${DEV}
} # function write_xbox_guids()


function erase_parts() {
    local DEV=$1

    # Make sure all partitions are not mounted
    umount ${DEV}* 2>/dev/null

    # Remove all existing partitions
    sgdisk --zap-all ${DEV} 2>/dev/null 1>&2
    if [ $? -eq 0 ]
    then
	echo "${DEV} has been successfully wiped"
    else
	echo "${DEV} wipe failed" 1>&2
	exit 2
    fi


    echo "Disk Erase Complete"
    echo "To create a new Xbox One drive run:"
    echo "'$(basename $0) --drive ${DEV} --stage 1'"
} # function erase_parts()


SHORTOPTS="d:s:m:h"
LONGOPTS="drive:,stage:,mirror:,help,debug"
ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $(basename $0) -- "$@")
eval set -- "$ARGS"

while true
do
	case $1 in
	-d|--drive)
		if [[ $2 =~ ^$ || ! -e $2 ]]
		then
			echo "Option $1 must be a valid device" 1>&2
		else
			OPT_DRIVE=$2
		fi
		shift
	;;
	-s|--stage)
		if [[ $2 =~ ^$ || ! $2 =~ ^[012]$ ]]
		then
			echo "Option $1 must be a valid number 0, 1, or 2" 1>&2
		else
			OPT_STAGE=$2
		fi
		shift
	;;
	-m|--mirror)
		if [[ $2 =~ ^$ || ! $2 =~ ^[012]$ ]]
		then
			echo "Option $1 must be a valid number 0, 1, or 2" 1>&2
			usage
			exit 0
		else
			OPT_MIRROR=$2
		fi
		shift
	;;
	--debug)
		OPT_DEBUG=1
	;;
	-h|--help)
		usage
		exit 0
	;;
	--)
		shift
		break
	;;
	*)
		shift
		break
	;;
esac
shift
done

if [[ ! -z $OPT_DRIVE && ! -z $OPT_STAGE ]]
then
	case $OPT_STAGE in
	0)
		erase_parts $OPT_DRIVE
	;;
	1)
		create_xbox_parts $OPT_DRIVE
	;;
	2)
		write_xbox_guids $OPT_DRIVE
	;;
	esac
else
	usage
fi
