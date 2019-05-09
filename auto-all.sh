#! /bin/bash

# set -o errexit
# set -o nounset
# set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	  echo "please run as root!"
fi

# pre check
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

# install docker
rpm -iUv pre_docker/*.rpm
rpm -iUv docker/*.rpm

systemctl enable docker

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
      "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
            "max-size": "100m"

    },
      "storage-driver": "overlay2",
      "storage-opts": [
          "overlay2.override_kernel_check=true"

      ]

}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl restart docker

# install kubeadm
# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
rpm -iUv kubeadm/*.rpm
systemctl enable --now kubelet

# load images
gunzip -c docker-images/kubeadm-image.tar.gz | docker load
gunzip -c docker-images/calico-image.tar.gz | docker load
gunzip -c docker-images/dashboard-image.tar.gz | docker load
gunzip -c docker-images/local-storage-image.tar.gz | docker load
gunzip -c docker-images/prometheus-image.tar.gz | docker load

# mount test disk for local volume
mkdir /mnt/disks
for vol in vol1; do
    mkdir /mnt/disks/$vol
    mount -t tmpfs $vol /mnt/disks/$vol
done

# todo
