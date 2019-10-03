#!/bin/bash
################################################################################
#
#  Authors: Ludvik Jerabek, XFiX
#  Date: 2018/05/10
#  Version: 7.0
#
#  Summary:
#  Create a true Xbox One 500GB, 1TB, or 2TB filesystem
#  This process is not a hack anymore
#  Past methods stretched a 500GB's filesystem
#  Now creates a resettable 500GB/1TB/2TB drive on ANY Xbox One OG/S/X Console
#  USE AT YOUR OWN RISK
#
#  Change History:
#  2014/07/09 - Initial Release - Ludvik Jerabek
#  2016/01/07 - Removed MBR Patching and added --stage 0 (1.0) - XFiX
#  2016/05/13 - Added Original Xbox User Content size --mirror option (3.0) - Ludvik Jerabek
#  2016/05/17 - Fixed disk size calculation physical vs logical blocks (3.0) - Ludvik Jerabek
#  2017/05/24 - Original 1TB and 2TB GUID Support with --disktype [0|1|2] (5.0) - XFiX
#  2017/05/31 - Improved list_part_info.sh to help find the proper disk (5.0) - XFiX
#  2018/01/10 - Non-Standard larger than 2TB Support (6.0) - XFiX
#  2018/01/10 - Added Source drive for data copy --source option (6.0) - XFiX
#  2018/01/10 - Copy source data to target drive with --stage 2 (6.0) - XFiX
#  2018/04/26 - Warn drive size limitations and limit to 2TB "User Content" (7.0) - XFiX
#  2018/06/19 - Preserve ACLs with rsync -A (7.0) - XFiX
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

XBOX_VER=2018.05.10.7.0

if [ $UID -ne 0 ]
then
	echo "Program must be run as root" 1>&2
	exit 1
fi

################################################################################
#
# Common GUIDs used by Xbox One
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
# Common partition sizes used by Xbox One
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
# Xbox Original 2TB User Partition
XBOX_USER_2TB_SIZE_IN_BYTES=1784558911488
# Xbox Original 1TB User Partition
XBOX_USER_1TB_SIZE_IN_BYTES=838592364544
# Xbox Original 500GB User Partition
XBOX_USER_500GB_SIZE_IN_BYTES=391915765760
# Xbox Max Size User Partition (1947GB)
XBOX_USER_MAX_SIZE_IN_BYTES=2090575331328

################################################################################
#
# Changeable variables
#
################################################################################
MOUNT_ROOT='/media'

function usage() {
cat << EOF
Last Updated: ${XBOX_VER}
Usage: $(basename $0) [options]

Options:
EOF

cat << EOF | column -s\& -t
-c|--source & Source drive to copy data to target drive -d with -s 2
-d|--drive & Target drive to install Xbox filesystem
-s|--stage & Install stage [0|1|2|3]
           & 0 - will fully erase drive -d
           & 1 - will erase and partition drive -d
           & 2 - will copy source drive -c data to target drive -d
           & 3 - will rewrite drive -d GUIDs
-t|--disktype & Disk GUID to set [0|1|2]
              & 0 - 500GB
              & 1 - 1TB
              & 2 - 2TB
-m|--mirror & Mirror standard partition sizes specified with -t on drive -d
            & Not using this option will autosize 'User Content'
-h|--help & Display help
EOF

cat << EOF

Examples:
$(basename $0) -d /dev/sdb -s 0 (Erase a drive)
$(basename $0) -d /dev/sdb -s 1 -t 2 -m (Partition standard 2TB drive)
$(basename $0) -d /dev/sdb -s 3 -t 2 -m (Rewrite 2TB GUIDs)
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

    echo "Partitioning device ${DEV} please be patient . . ."

    # New user content partition size (eg. Using a 500GB drive it's roughly 392733679616 bytes = 365G )
    local XBOX_USER_PARTITION_IN_BYTES=0

    # XFiX - Mirror option forces all drives to be 500GB/1TB/2TB equivalent
    NEXT_MSG=" --disktype ${OPT_DISKTYPE}"
    if [ ! -z $OPT_MIRROR ]
    then
        # Force 500GB/1TB/2TB User Partition
        NEXT_MSG="${NEXT_MSG} --mirror"
        case $OPT_DISKTYPE in
        0)
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_500GB_SIZE_IN_BYTES}
            echo "Forcing User Content partition to original Xbox One 500GB size: ${XBOX_USER_PARTITION_IN_BYTES}"
        ;;
        1)
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_1TB_SIZE_IN_BYTES}
            echo "Forcing User Content partition to original Xbox One 1TB size: ${XBOX_USER_PARTITION_IN_BYTES}"
        ;;
        2)
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_2TB_SIZE_IN_BYTES}
            echo "Forcing User Content partition to original Xbox One 2TB size: ${XBOX_USER_PARTITION_IN_BYTES}"
        ;;
        esac
    else
	XBOX_USER_PARTITION_IN_BYTES=$((DEV_SIZE_IN_BYTES - XBOX_TEMP_SIZE_IN_BYTES - XBOX_SUPPORT_SIZE_IN_BYTES - XBOX_UPDATE_SIZE_IN_BYTES - XBOX_UPDATE_SIZE2_IN_BYTES))
	# Align the data to the nearest GB
	XBOX_USER_PARTITION_IN_BYTES=$(((XBOX_USER_PARTITION_IN_BYTES/1073741824)*1073741824))
        if [ $XBOX_USER_PARTITION_IN_BYTES -gt $XBOX_USER_MAX_SIZE_IN_BYTES ]
        then
            XBOX_USER_PARTITION_IN_BYTES=${XBOX_USER_MAX_SIZE_IN_BYTES}
        fi
	echo "Dynamic sizing User Content partition: ${XBOX_USER_PARTITION_IN_BYTES}"
    fi

    # Mirror 'User Content' = partition 2
    # Non-standard 'User Content' = partition 5
    # 7.0: Changed all to 2nd partition since 'User Content' over 2048GB is useless
    PARTITION_1_IN_BYTES=${XBOX_TEMP_SIZE_IN_BYTES}
    PARTITION_2_IN_BYTES=${XBOX_USER_PARTITION_IN_BYTES}
    PARTITION_3_IN_BYTES=${XBOX_SUPPORT_SIZE_IN_BYTES}
    PARTITION_4_IN_BYTES=${XBOX_UPDATE_SIZE_IN_BYTES}
    PARTITION_5_IN_BYTES=${XBOX_UPDATE_SIZE2_IN_BYTES}

    PARTITION_1_NAME='Temp Content'
    PARTITION_2_NAME='User Content'
    PARTITION_3_NAME='System Support'
    PARTITION_4_NAME='System Update'
    PARTITION_5_NAME='System Update 2'

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
    local END_SECTOR=$(((PARTITION_1_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 1 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=1:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=1:0700 ${DEV}
    sgdisk --change-name="1:${PARTITION_1_NAME}" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((PARTITION_2_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 2 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=2:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=2:0700 ${DEV}
    sgdisk --change-name="2:${PARTITION_2_NAME}" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((PARTITION_3_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 3 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=3:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=3:0700 ${DEV}
    sgdisk --change-name="3:${PARTITION_3_NAME}" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((PARTITION_4_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 4 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=4:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=4:0700 ${DEV}
    sgdisk --change-name="4:${PARTITION_4_NAME}" ${DEV}

    START_SECTOR=$((END_SECTOR+1))
    END_SECTOR=$(((PARTITION_5_IN_BYTES/DEV_LOGICAL_BLOCK_SIZE_IN_BYTES)-1+START_SECTOR))
    echo "Creating Partition 5 ${START_SECTOR} --> ${END_SECTOR}"
    sgdisk --new=5:$START_SECTOR:$END_SECTOR ${DEV}
    sgdisk --typecode=5:0700 ${DEV}
    sgdisk --change-name="5:${PARTITION_5_NAME}" ${DEV}


    # Make sure the partitions are not mounted some systems will automount and break the mkntfs commands below
    umount ${DEV}* 2>/dev/null

    # Name the NTFS partition accordingly
    mkntfs -q "${DEV}${TEMP_CONTENT_PART}" -f -L "Temp Content"
    mkntfs -q "${DEV}${USER_CONTENT_PART}" -f -L "User Content"
    mkntfs -q "${DEV}${SYSTEM_SUPPORT_PART}" -f -L "System Support"
    mkntfs -q "${DEV}${SYSTEM_UPDATE_PART}" -f -L "System Update"
    mkntfs -q "${DEV}${SYSTEM_UPDATE2_PART}" -f -L "System Update 2"

    echo
    echo "Disk Partitioning Complete"
    echo "Copy the folder contents from the original drive with:"
    echo "'$(basename $0) --source /dev/sd? --drive ${DEV} --stage 2${NEXT_MSG}'"
    echo "Or set proper GUID values with:"
    echo "'$(basename $0) --drive ${DEV} --stage 3${NEXT_MSG}'"
} # function create_xbox_parts()


function copy_xbox_data() {
    local DEV=$1
    local SRC=$2

    [ ! -z $OPT_DEBUG ] && echo "DEBUG Device: ${DEV}"
    [ ! -z $OPT_DEBUG ] && echo "DEBUG Source: ${SRC}"

    # Make sure the partitions are not mounted some systems will automount and break the mkntfs commands below
    umount ${DEV}* 2>/dev/null
    umount ${SRC}* 2>/dev/null

    # XFiX - since udisksctl automounts to /media/ubuntu/LABEL and
    # /media/ubuntu/LABEL1 we don't need to check partition 2 e.g.
    # udisksctl mount --block-device ${DEV}1
    # udisksctl mount --block-device ${SRC}1
    # rsync -rlAtgoDzv --size-only /media/ubuntu/LABEL1/ /media/ubuntu/LABEL/
    # Unfortunately udisksctl isn't available on older distributions
    # so we use a more universal approach e.g.
    # mkdir -p ${MOUNT_ROOT}/LABEL; mount ${DEV}${USER_CONTENT_PART} ${MOUNT_ROOT}/LABEL
    # mkdir -p ${MOUNT_ROOT}/LABEL1; mount ${SRC}${USER_CONTENT_SRC} ${MOUNT_ROOT}/LABEL1
    # rsync -rlAtgoDzv --size-only ${MOUNT_ROOT}/LABEL1/ ${MOUNT_ROOT}/LABEL/

    # Check the source drive label name for partition 2
    sgdisk --print --info=2 ${SRC} | grep 'User Content' 2>/dev/null 1>&2
    # Mirror 'User Content' = partition 2
    # Non-standard 'User Content' = partition 5
    # 7.0: Changed all to 2nd partition since 'User Content' over 2048GB is useless
    TEMP_CONTENT_SRC=1
    USER_CONTENT_SRC=2
    SYSTEM_SUPPORT_SRC=3
    SYSTEM_UPDATE_SRC=4
    SYSTEM_UPDATE2_SRC=5

    NEXT_MSG=" --disktype ${OPT_DISKTYPE}"
    if [ ! -z $OPT_MIRROR ]
    then
        NEXT_MSG="${NEXT_MSG} --mirror"
    fi

    COPY_RESULT=0
    copy_xbox_part "TEMP CONTENT" ${DEV}${TEMP_CONTENT_PART} ${SRC}${TEMP_CONTENT_SRC}
    COPY_RESULT=$((COPY_RESULT+$?))
    copy_xbox_part "USER CONTENT" ${DEV}${USER_CONTENT_PART} ${SRC}${USER_CONTENT_SRC}
    COPY_RESULT=$((COPY_RESULT+$?))
    copy_xbox_part "SYSTEM SUPPORT" ${DEV}${SYSTEM_SUPPORT_PART} ${SRC}${SYSTEM_SUPPORT_SRC}
    COPY_RESULT=$((COPY_RESULT+$?))
    copy_xbox_part "SYSTEM UPDATE" ${DEV}${SYSTEM_UPDATE_PART} ${SRC}${SYSTEM_UPDATE_SRC}
    COPY_RESULT=$((COPY_RESULT+$?))
    copy_xbox_part "SYSTEM UPDATE 2" ${DEV}${SYSTEM_UPDATE2_PART} ${SRC}${SYSTEM_UPDATE2_SRC}
    COPY_RESULT=$((COPY_RESULT+$?))

    echo
    if [ $COPY_RESULT -eq 0 ]
    then
        echo "Data Copy Complete"
        echo "Now set proper GUID values with:"
        echo "'$(basename $0) --drive ${DEV} --stage 3${NEXT_MSG}'"
    else
        echo "Data Copy Failed"
        echo "Should probably repartition the TARGET drive with:"
        echo "'$(basename $0) --drive ${DEV} --stage 1${NEXT_MSG}'"
    fi
} # function copy_xbox_data()


function copy_xbox_part() {
    local LABEL="$1"
    local PARTDEV="$2"
    local PARTSRC="$3"

    # Test Parts
    if [ ! -b $PARTDEV ]
    then
        echo "Skipping '${LABEL}' missing TARGET ${PARTDEV}"
        return 2
    fi

    if [ ! -b $PARTSRC ]
    then
        echo "Skipping '${LABEL}1' missing SOURCE ${PARTSRC}"
        return 1
    fi

    # Mount
    mkdir -p "${MOUNT_ROOT}/${LABEL}"
    mount ${PARTDEV} "${MOUNT_ROOT}/${LABEL}"

    mkdir -p "${MOUNT_ROOT}/${LABEL}1"
    mount ${PARTSRC} "${MOUNT_ROOT}/${LABEL}1"

    # Copy
    echo
    echo "Copying '${LABEL}' from ${PARTSRC} to ${PARTDEV} please be patient . . ."
    #rsync -rlAtgoDzv --size-only "${MOUNT_ROOT}/${LABEL}1/" "${MOUNT_ROOT}/${LABEL}/"
    rsync -rltgoDzv --size-only "${MOUNT_ROOT}/${LABEL}1/" "${MOUNT_ROOT}/${LABEL}/"

    # Cleanup
    umount ${PARTDEV}
    rmdir "${MOUNT_ROOT}/${LABEL}"

    umount ${PARTSRC}
    rmdir "${MOUNT_ROOT}/${LABEL}1"

    return 0
} # function copy_xbox_part()


function write_xbox_guids() {
    local DEV=$1

    # Make sure the partitions are not mounted some systems will automount and break the mkntfs commands below
    umount ${DEV}* 2>/dev/null

    # Force 500GB/1TB/2TB User Partition
    # XFiX Mirror option forces all drives to be 500GB/1TB/2TB equivalent
    if [ ! -z $OPT_DISKTYPE ]
    then
        case $OPT_DISKTYPE in
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

    echo "Setting GUID values on ${DEV} please be patient . . ."
    # Disk GUID
    sgdisk --disk-guid=${DISK_GUID} ${DEV}
    # Partition 1 GUID
    sgdisk --partition-guid=${TEMP_CONTENT_PART}:${TEMP_CONTENT_GUID} ${DEV}
    # Partition 2 GUID
    sgdisk --partition-guid=${USER_CONTENT_PART}:${USER_CONTENT_GUID} ${DEV}
    # Partition 3 GUID
    sgdisk --partition-guid=${SYSTEM_SUPPORT_PART}:${SYSTEM_SUPPORT_GUID} ${DEV}
    # Partition 4 GUID
    sgdisk --partition-guid=${SYSTEM_UPDATE_PART}:${SYSTEM_UPDATE_GUID} ${DEV}
    # Partition 5 GUID
    sgdisk --partition-guid=${SYSTEM_UPDATE2_PART}:${SYSTEM_UPDATE2_GUID} ${DEV}
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


SHORTOPTS="c:d:s:t:mh"
LONGOPTS="source:,drive:,stage:,disktype:,mirror,help,debug"
ARGS=$(getopt -s bash --options $SHORTOPTS --longoptions $LONGOPTS --name $(basename $0) -- "$@")
eval set -- "$ARGS"

# Default to --disktype 0 - 500GB if not specified
OPT_DISKTYPE=0

while true
do
    case $1 in
    -c|--source)
	if [[ $2 =~ ^$ || ! -e $2 ]]
	then
	    echo "Option $1 must be a valid device" 1>&2
	else
	    OPT_SOURCE=$2
	fi
	shift
    ;;
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
	if [[ $2 =~ ^$ || ! $2 =~ ^[0123]$ ]]
	then
	    echo "Option $1 must be a valid number 0, 1, 2, or 3" 1>&2
	else
	    OPT_STAGE=$2
	fi
	shift
    ;;
    -t|--disktype)
	if [[ $2 =~ ^$ || ! $2 =~ ^[012]$ ]]
	then
	    echo "Option $1 must be a valid number 0, 1, or 2" 1>&2
	    usage
	    exit 0
	else
	    OPT_DISKTYPE=$2
	fi
	shift
    ;;
    -m|--mirror)
	OPT_MIRROR=1
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
    # XFiX - Partition order now differs depending on $OPT_MIRROR
    # Mirror 'User Content' = partition 2
    # Non-standard 'User Content' = partition 5
    # 7.0: Changed all to 2nd partition since 'User Content' over 2048GB is useless
    TEMP_CONTENT_PART=1
    USER_CONTENT_PART=2
    SYSTEM_SUPPORT_PART=3
    SYSTEM_UPDATE_PART=4
    SYSTEM_UPDATE2_PART=5

    case $OPT_STAGE in
    0)
        erase_parts $OPT_DRIVE
    ;;
    1)
	create_xbox_parts $OPT_DRIVE
    ;;
    2)
        if [[ ! -z $OPT_SOURCE ]]
        then
	    copy_xbox_data $OPT_DRIVE $OPT_SOURCE
        else
            echo "Option -c is required with -s 2" 1>&2
            usage
        fi
    ;;
    3)
	write_xbox_guids $OPT_DRIVE
    ;;
    esac
else
    usage
fi
