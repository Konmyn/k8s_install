#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

echo -e "[cluster]\n192.168.28.[90:94]" >> /etc/ansible/hosts
echo -e "[self]\n192.168.28.90" >> /etc/ansible/hosts
echo -e "[worker]\n192.168.28.[91:94]" >> /etc/ansible/hosts
echo -e "[master]\n192.168.28.90" >> /etc/ansible/hosts
