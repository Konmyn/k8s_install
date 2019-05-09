#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

setenforce 0 && sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config

systemctl stop firewalld
systemctl disable firewalld

sysctl vm.swappiness=0
grep vm.swappiness /etc/sysctl.conf || echo "vm.swappiness = 0" >> /etc/sysctl.conf
grep net.bridge.bridge-nf-call-ip6tables /etc/sysctl.conf || echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
grep net.bridge.bridge-nf-call-iptables /etc/sysctl.conf || echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
grep net.ipv4.ip_forward /etc/sysctl.conf || echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

swapoff -a
grep 'swap' /etc/fstab | grep '#' || sed -i '/swap/s/^/#/' /etc/fstab

sysctl --system

