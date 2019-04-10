#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
cd $DIR

# Update HOST0, HOST1, and HOST2 with the IPs or resolvable names of your hosts
export HOST0=192.168.28.90
export HOST1=192.168.28.91
export HOST2=192.168.28.92

# Create temp directories to store files that will end up on other hosts.
mkdir -p /tmp/${HOST0}/ /tmp/${HOST1}/ /tmp/${HOST2}/

ETCDHOSTS=(${HOST0} ${HOST1} ${HOST2})
NAMES=("infra0" "infra1" "infra2")

for i in "${!ETCDHOSTS[@]}"; do
HOST=${ETCDHOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > /tmp/${HOST}/kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${NAMES[0]}=https://${ETCDHOSTS[0]}:2380,${NAMES[1]}=https://${ETCDHOSTS[1]}:2380,${NAMES[2]}=https://${ETCDHOSTS[2]}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF
done

rm -rf /etc/kubernetes/*

kubeadm init phase certs etcd-ca

kubeadm init phase certs etcd-server --config=/tmp/${HOST2}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/tmp/${HOST2}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/tmp/${HOST2}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/tmp/${HOST2}/kubeadmcfg.yaml
cp -R /etc/kubernetes/pki /tmp/${HOST2}/
# cleanup non-reusable certificates
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm init phase certs etcd-server --config=/tmp/${HOST1}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/tmp/${HOST1}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/tmp/${HOST1}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/tmp/${HOST1}/kubeadmcfg.yaml
cp -R /etc/kubernetes/pki /tmp/${HOST1}/
find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

kubeadm init phase certs etcd-server --config=/tmp/${HOST0}/kubeadmcfg.yaml
kubeadm init phase certs etcd-peer --config=/tmp/${HOST0}/kubeadmcfg.yaml
kubeadm init phase certs etcd-healthcheck-client --config=/tmp/${HOST0}/kubeadmcfg.yaml
kubeadm init phase certs apiserver-etcd-client --config=/tmp/${HOST0}/kubeadmcfg.yaml
# No need to move the certs because they are for HOST0

# clean up certs that should not be copied off this host
find /tmp/${HOST2} -name ca.key -type f -delete
find /tmp/${HOST1} -name ca.key -type f -delete

# mkdir -p /etc/systemd/system/kubelet.service.d/
# systemctl daemon-reload
# systemctl restart kubelet

ansible ${HOST0} -m file -a "dest=/etc/systemd/system/kubelet.service.d state=directory"
ansible ${HOST1} -m file -a "dest=/etc/systemd/system/kubelet.service.d state=directory"
ansible ${HOST2} -m file -a "dest=/etc/systemd/system/kubelet.service.d state=directory"

ansible ${HOST0} -m shell -a 'cp workspace/20-etcd-service-manager.conf /etc/systemd/system/kubelet.service.d'
ansible ${HOST1} -m shell -a 'cp workspace/20-etcd-service-manager.conf /etc/systemd/system/kubelet.service.d'
ansible ${HOST2} -m shell -a 'cp workspace/20-etcd-service-manager.conf /etc/systemd/system/kubelet.service.d'

ansible ${HOST0} -m shell -a 'systemctl daemon-reload && systemctl restart kubelet'
ansible ${HOST1} -m shell -a 'systemctl daemon-reload && systemctl restart kubelet'
ansible ${HOST2} -m shell -a 'systemctl daemon-reload && systemctl restart kubelet'

ansible ${HOST1} -m copy -a "src=/tmp/${HOST1}/ dest=/root"
ansible ${HOST1} -m file -a "dest=/etc/kubernetes/ state=directory"
ansible ${HOST1} -m shell -a 'cp -r pki /etc/kubernetes/'
ansible ${HOST1} -m file -a "dest=/root/pki state=absent"

ansible ${HOST2} -m copy -a "src=/tmp/${HOST2}/ dest=/root"
ansible ${HOST2} -m file -a "dest=/etc/kubernetes/ state=directory"
ansible ${HOST2} -m shell -a 'cp -r pki /etc/kubernetes/'
ansible ${HOST2} -m file -a "dest=/root/pki state=absent"

ansible ${HOST0} -m shell -a "kubeadm init phase etcd local --config=/tmp/${HOST0}/kubeadmcfg.yaml"
ansible ${HOST1} -m shell -a "kubeadm init phase etcd local --config=/root/kubeadmcfg.yaml"
ansible ${HOST2} -m shell -a "kubeadm init phase etcd local --config=/root/kubeadmcfg.yaml"

