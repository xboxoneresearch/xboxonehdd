#!/bin/bash
################################################################################
#
#  Summary:
#
#  In theory this would make Xbox One External drives readable on Windows
#  In practice, not so much
#  Use at your own risk
#
################################################################################
if [ $UID -ne 0 ]
then
	echo "Program must be run as root" 1>&2
	exit 1
fi

function usage() {
cat << EOF
Usage: $(basename $0) /dev/sd* [unlock|lock]

Examples:
$(basename $0) /dev/sdb unlock (Make Windows MBR Compatible)
$(basename $0) /dev/sdb lock   (Make Xbox One External MBR Compatible)

Current Drive List:
EOF

parted -l | grep ' /dev/'
echo
} # function usage()

if [ $# -eq 2 ]; then
	DEVNAME=$1
	ACTION=$2
	if [ "$ACTION" = "unlock" ]; then
		echo -en '\x55\xAA' | dd conv=notrunc of=${DEVNAME} bs=1 seek=510 2>/dev/null 1>&2
		if [ $? -eq 0 ]; then
			echo "MBR Unlock ${DEVNAME} Complete"
		else
			echo "MBR Unlock ${DEVNAME} Failed" 1>&2
		fi
        elif [ "$ACTION" = "lock" ]; then
                echo -en '\x99\xCC' | dd conv=notrunc of=${DEVNAME} bs=1 seek=510 2>/dev/null 1>&2
                if [ $? -eq 0 ]; then
                        echo "MBR Lock ${DEVNAME} Complete"
                else
                        echo "MBR Lock ${DEVNAME} Failed" 1>&2
                fi
	else
		usage
	fi
else
	usage
fi
