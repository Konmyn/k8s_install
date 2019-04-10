#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"    )" >/dev/null 2>&1 && pwd    )"
cd $DIR

kubeadm join 192.168.28.90:6443 --token $1 \
        --discovery-token-ca-cert-hash $2

