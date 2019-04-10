#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"    )" >/dev/null 2>&1 && pwd    )"
cd $DIR

rm /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
systemctl daemon-reload && systemctl restart kubelet
sleep 5
kubeadm init --config kubeadm-config.yaml --experimental-upload-certs --ignore-preflight-errors="FileAvailable--etc-kubernetes-manifests-etcd.yaml" > admin-init.log
sleep 10
./083_enable_kubectl_on_master.sh


export HOST0=192.168.28.90
export HOST1=192.168.28.91
export HOST2=192.168.28.92
export HOST3=192.168.28.93
export HOST4=192.168.28.94

ansible ${HOST1} -m shell -a "workspace/081_join_master.sh $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $2}') $(grep 'experimental-control-plane' admin-init.log | head -1 | awk '{print $3}')"
sleep 10

ansible ${HOST2} -m shell -a "workspace/081_join_master.sh $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $2}') $(grep 'experimental-control-plane' admin-init.log | head -1 | awk '{print $3}')"
sleep 10

ansible ${HOST3} -m shell -a "workspace/082_join_worker.sh $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $2}')"
sleep 5

ansible ${HOST4} -m shell -a "workspace/082_join_worker.sh $(grep '6443 --token' admin-init.log | head -1 | awk '{print $5}') $(grep 'discovery-token-ca-cert-hash' admin-init.log | head -1 | awk '{print $2}')"
sleep 5
