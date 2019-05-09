#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"    )" >/dev/null 2>&1 && pwd    )"
cd $DIR

kubectl apply -f dashboard/kubernetes-dashboard.yaml
kubectl apply -f dashboard/admin-user.yaml

echo ""
echo $'kubectl -n kube-system describe secret $(kubectl -n kube-system describe serviceaccount admin | grep -i tokens | awk \'{print $2}\') | grep token: | awk \'{print $2}\''
echo ""

kubectl -n kube-system describe secret $(kubectl -n kube-system describe serviceaccount admin | grep -i tokens | awk '{print $2}') | grep token: | awk '{print $2}'
