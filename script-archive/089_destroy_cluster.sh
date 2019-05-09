#! /bin/bash

export HOST0=192.168.28.90
export HOST1=192.168.28.91
export HOST2=192.168.28.92
export HOST3=192.168.28.93
export HOST4=192.168.28.94

ansible ${HOST4} -m shell -a "kubeadm reset -f"
sleep 1
ansible ${HOST4} -m shell -a "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
ansible ${HOST4} -m file -a "dest=/var/lib/etcd state=absent"
ansible ${HOST4} -m shell -a "reboot"

ansible ${HOST3} -m shell -a "kubeadm reset -f"
sleep 1
ansible ${HOST3} -m shell -a "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
ansible ${HOST3} -m file -a "dest=/var/lib/etcd state=absent"
ansible ${HOST3} -m shell -a "reboot"

ansible ${HOST2} -m shell -a "kubeadm reset -f"
sleep 1
ansible ${HOST2} -m shell -a "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
ansible ${HOST2} -m file -a "dest=/var/lib/etcd state=absent"
ansible ${HOST2} -m shell -a "reboot"

ansible ${HOST1} -m shell -a "kubeadm reset -f"
sleep 1
ansible ${HOST1} -m shell -a "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
ansible ${HOST1} -m file -a "dest=/var/lib/etcd state=absent"
ansible ${HOST1} -m shell -a "reboot"

ansible ${HOST0} -m shell -a "kubeadm reset -f"
sleep 1
ansible ${HOST0} -m shell -a "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
ansible ${HOST0} -m file -a "dest=/var/lib/etcd state=absent"
ansible ${HOST0} -m shell -a "reboot"
