#! /bin/bash

#set -o errexit
#set -o nounset
#set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

## install ansible
rpm -iUv ansible/*.rpm
ls -alh /etc/ansible/

# init ansible
echo -e "[cluster]\n192.168.28.[90:94]" >> /etc/ansible/hosts
echo -e "[self]\n192.168.28.90" >> /etc/ansible/hosts
echo -e "[worker]\n192.168.28.[91:94]" >> /etc/ansible/hosts
echo -e "[master]\n192.168.28.90" >> /etc/ansible/hosts

# ssh key-gen
yes n | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

for i in 9{0..4}; do
    ip=192.168.28.$i
    echo $ip
    ssh-keyscan $ip | grep ecdsa-sha2-nistp256 >> ~/.ssh/known_hosts
    sshpass -f password.txt ssh-copy-id root@$ip
done

# sync files
rsync -avzp /root/k8s_install root@192.168.28.91:/root
rsync -avzp /root/k8s_install root@192.168.28.92:/root
rsync -avzp /root/k8s_install root@192.168.28.93:/root
rsync -avzp /root/k8s_install root@192.168.28.94:/root

# change hostname
export HOST0=192.168.28.90
export HOST1=192.168.28.91
export HOST2=192.168.28.92
export HOST3=192.168.28.93
export HOST4=192.168.28.94

export HOSTNAME0=n00
export HOSTNAME1=n01
export HOSTNAME2=n02
export HOSTNAME3=n03
export HOSTNAME4=n04

ansible ${HOST0} -m shell -a "k8s_install/001_set_hostname.sh ${HOSTNAME0}"
ansible ${HOST1} -m shell -a "k8s_install/001_set_hostname.sh ${HOSTNAME1}"
ansible ${HOST2} -m shell -a "k8s_install/001_set_hostname.sh ${HOSTNAME2}"
ansible ${HOST3} -m shell -a "k8s_install/001_set_hostname.sh ${HOSTNAME3}"
ansible ${HOST4} -m shell -a "k8s_install/001_set_hostname.sh ${HOSTNAME4}"

# install staff on all nodes
ansible cluster -m shell -a 'k8s_install/auto-all.sh'

# kubeadm init
kubeadm init > admin-init.log
sleep 10

export HOST0=192.168.28.90
export HOST1=192.168.28.91
export HOST2=192.168.28.92
export HOST3=192.168.28.93
export HOST4=192.168.28.94

ansible ${HOST1} -m shell -a "kubeadm join 192.168.28.90:6443 --token $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') --discovery-token-ca-cert-hash $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $7}')"
ansible ${HOST2} -m shell -a "kubeadm join 192.168.28.90:6443 --token $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') --discovery-token-ca-cert-hash $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $7}')"
ansible ${HOST3} -m shell -a "kubeadm join 192.168.28.90:6443 --token $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') --discovery-token-ca-cert-hash $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $7}')"
ansible ${HOST4} -m shell -a "kubeadm join 192.168.28.90:6443 --token $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') --discovery-token-ca-cert-hash $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $7}')"

# enable kubectl on master
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install calico network
kubectl apply -f calico/calico.yaml

# install dashboard
kubectl apply -f dashboard/kubernetes-dashboard.yaml
kubectl apply -f dashboard/admin-user.yaml

echo ""
echo $'kubectl -n kube-system describe secret $(kubectl -n kube-system describe serviceaccount admin | grep -i tokens | awk \'{print $2}\') | grep token: | awk \'{print $2}\''
echo ""

kubectl -n kube-system describe secret $(kubectl -n kube-system describe serviceaccount admin | grep -i tokens | awk '{print $2}') | grep token: | awk '{print $2}'

# install local storage volume
kubectl apply -f local-storage/storageclass.yaml
kubectl apply -f local-storage/provisioner-generated.yaml

# todo























