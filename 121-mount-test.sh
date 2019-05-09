#! /bin/bash

#set -o errexit
set -o nounset
#set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

mkdir /mnt/disks
for vol in vol1; do
    mkdir /mnt/disks/$vol
    mount -t tmpfs $vol /mnt/disks/$vol
done

