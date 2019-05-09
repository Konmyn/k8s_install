#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

host=$1

if [ "$host" == "" ]; then
    echo "usage: $0 new_hostname"
    echo "please input the new hostname"
    exit 10
fi

hostnamectl set-hostname $host
sed -i -E "s/(127.0.0.1|::1).*$/& $host/" /etc/hosts
