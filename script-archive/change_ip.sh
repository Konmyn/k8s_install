#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

suffix=$1

if [ "$suffix" == "" ]; then
    echo "usage: $0 IPv4_last_digits"
    echo "please input the ip suffix"
    exit 10
fi

echo "host ip is $(grep IPADDR /etc/sysconfig/network-scripts/ifcfg-ens33 | cut -d= -f2)"
echo "will change this host ip to 192.168.28.$suffix"

#sed -i "/IPADDR/c\IPADDR=192.168.28.$suffix"  /etc/sysconfig/network-scripts/ifcfg-ens33

#systemctl restart network

