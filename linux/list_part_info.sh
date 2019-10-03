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

function usage() {
cat << EOF

Usage: $(basename $0) /dev/sd*

Examples:
$(basename $0) /dev/sdb (List Disk Partition Information)

EOF
} # function usage()

################################################################################
#
# Show disk/partition information
#
################################################################################

echo Last Updated: ${XBOX_VER}
echo

DEVNAME=$1
if [[ ! -z $DEVNAME ]]
then
        DISK_GUID=`sgdisk -p ${DEVNAME} | grep "Disk identifier (GUID):" | cut -d' ' -f4`
        case $DISK_GUID in
        $DISK_GUID_2TB)
            DISK_NAME='(2TB)'
        ;;
        $DISK_GUID_1TB)
            DISK_NAME='(1TB)'
        ;;
        $DISK_GUID_500GB)
            DISK_NAME='(500GB)'
        ;;
        *)
            DISK_NAME=''
        ;;
        esac
	printf "%-36s %-9s %-11s %s\n" "GUID" "Dev" "Size" "Name"
        printf "%-36s %-9s %-11s %s\n" $(sgdisk -p ${DEVNAME} | grep "Disk identifier (GUID):" | cut -d' ' -f4) "${DEVNAME}" "" "${DISK_NAME}"
        for p in `sgdisk --print ${DEVNAME} | tail -n 5 | awk '{print $1}'`
        do
                printf "%-36s %-9s %6s %4s %s %s %s\n" $(sgdisk -i ${p} ${DEVNAME} | grep "Partition unique GUID:" | cut -d' ' -f4) "${DEVNAME}${p}" $(sgdisk -i ${p} ${DEVNAME} | grep "Partition size:" | cut -d' ' -f5,6) $(sgdisk -i ${p} ${DEVNAME} | grep "Partition name:" | cut -d' ' -f3-)
        done
else
        echo "Current Drive List:"
        parted -ls 2>/dev/null | grep ' /dev/'
        usage
fi
