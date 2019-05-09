#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
cd $DIR

rsync -avzp /root/k8s_install root@192.168.28.91:/root
rsync -avzp /root/k8s_install root@192.168.28.92:/root
rsync -avzp /root/k8s_install root@192.168.28.93:/root
rsync -avzp /root/k8s_install root@192.168.28.94:/root
