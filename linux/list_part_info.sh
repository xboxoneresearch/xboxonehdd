#!/bin/bash
################################################################################
#
#  Name: Ludvik Jerabek
#  Date: 07/09/2014
#  Version: 1.0
#
#  Summary:
#
#  Create a true Xbox One 500GB, 1TB, or 2TB filesystem
#  This process is not a hack anymore
#  Past methods stretched a 500GB's filesystem
#  Now we create a resettable 500GB/1TB/2TB drive on ANY Xbox One OG/S console
#  Use at your own risk
#
#  Change History:
#
#  07/09/2014 - Initial Release - Ludvik Jerabek
#  05/13/2016 - Added Original XBox User Content size --mirror option
#  05/17/2016 - Fixed disk size calculation physical vs logical blocks
#  01/07/2016 - Removed MBR Patching and added --stage 0 - XFiX
#  05/24/2017 - Original 1TB and 2TB GUID Support with --mirror [0|1|2] - XFiX
#  05/31/2017 - Improved list_part_info.sh to help find the proper disk - XFiX
#
#  Credits:
#  Juvenal of Team Xecuter for creating the first working Python script
#  http://team-xecuter.com/forums/threads/141568-XBOX-ONE-How-To-Install-A-Bigger-Hard-Drive-%21
#
#  Ludvik Jerabek for creating this original bash script
#  http://www.ludvikjerabek.com/2014/07/14/xbox-one-fun-with-gpt-disk/
#
#  A1DR1K for being the first to discover the secret behind what differentiates
#  500GB, 1TB, and 2TB Xbox One system hard drives
#  https://plus.google.com/+ShawnSkellett
#
#  XFiX for creating the Windows batch script based on the bash script
#  https://www.youtube.com/playlist?list=PLURaLwRqr6g14Pl8qLO0E4ELBBCHfFh1V
#
################################################################################
if [ $UID -ne 0 ]
then
	echo "Program must be run as root" 1>&2
	exit 1
fi

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
DEVNAME=$1
if [[ ! -z $DEVNAME ]]
then
	printf "%-36s %-9s %-11s %s\n" "GUID" "Dev" "Size" "Name"
        printf "%-36s %-9s\n" $(sgdisk -p ${DEVNAME} | grep "Disk identifier (GUID):" | cut -d' ' -f4) "${DEVNAME}"
        for p in `sgdisk --print ${DEVNAME} | tail -n +10 | awk '{print $1}'`
        do
                printf "%-36s %-9s %6s %4s %s %s %s\n" $(sgdisk -i ${p} ${DEVNAME} | grep "Partition unique GUID:" | cut -d' ' -f4) "${DEVNAME}${p}" $(sgdisk -i ${p} ${DEVNAME} | grep "Partition size:" | cut -d' ' -f5,6) $(sgdisk -i ${p} ${DEVNAME} | grep "Partition name:" | cut -d' ' -f3-)
        done
else
        echo "Current Drive List:"
        parted -l | grep ' /dev/'
        usage
fi
