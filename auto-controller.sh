#! /bin/bash

# set -o errexit
# set -o nounset
# set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

if [ `id -u` -ne 0 ]; then
	echo "please run as root!"
fi

HOSTIP=(
    "192.168.1.37"
)
HOSTNAME=(
    "kuberdap01"
)

## install ansible
rpm -iUvh --force ansible/*.rpm
ls -alh /etc/ansible/

# init ansible
echo -e "[all]" >> /etc/ansible/hosts
for HOST in ${HOSTIP[@]}; do
    echo $HOST >> /etc/ansible/hosts
done

# ssh key-gen
yes n | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
for HOST in ${HOSTIP[@]}; do
    ssh-keyscan $HOST | grep ecdsa-sha2-nistp256 >> ~/.ssh/known_hosts
    sshpass -f password.txt ssh-copy-id root@$HOST
done

# sync files
for HOST in ${HOSTIP[@]:1}; do
    rsync -avzp /root/k8s_install root@$HOST:/root
done

# change hostname
for ((i=0;i<${#HOSTIP[@]};++i)); do
    ansible ${HOSTIP[i]} -m shell -a "k8s_install/set-hostname.sh ${HOSTNAME[i]}"
done

# install staff on all nodes
ansible all -m shell -a 'k8s_install/auto-all.sh'

# kubeadm init
kubeadm init > admin-init.log
sleep 10

for HOST in ${HOSTIP[@]:1}; do
    ansible ${HOST} -m shell -a "kubeadm join ${HOSTIP[0]}:6443 --token $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') --discovery-token-ca-cert-hash $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $7}')"
done

# enable kubectl on master
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install calico network
kubectl apply -f calico/calico.yaml

# coredns bugfix
kubectl apply -f bugfix/coredns-configmap.yaml

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

# install prometheus
kubectl create -f prometheus/manifests/
# It can take a few seconds for the above 'create manifests' command to fully create the following resources, so verify the resources are ready before proceeding.
until kubectl get customresourcedefinitions servicemonitors.monitoring.coreos.com ; do date; sleep 1; echo ""; done
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f prometheus/manifests/ # This command sometimes may need to be done twice (to workaround a race condition).

