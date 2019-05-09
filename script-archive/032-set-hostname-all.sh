#! /bin/bash

#set -o errexit
#set -o nounset
#set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"    )" >/dev/null 2>&1 && pwd    )"
cd $DIR

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

