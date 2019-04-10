#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"    )" >/dev/null 2>&1 && pwd    )"
cd $DIR

rm /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
systemctl daemon-reload && systemctl restart kubelet

sleep 5

kubeadm join 192.168.28.90:6443 --token $1 \
    --discovery-token-ca-cert-hash $2 \
    --experimental-control-plane --certificate-key $3 \
    --ignore-preflight-errors="DirAvailable--etc-kubernetes-manifests,FileAvailable--etc-kubernetes-manifests-etcd.yaml" > master-join.log

