#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
cd $DIR

cp sendfile.sh workspace
cp change_ip.sh workspace

tar -cvf install.tar workspace

if [[ -z "${1:-}" ]]
then
ansible others -m copy -a "src=/root/install.tar dest=/root"
ansible others -m shell -a 'tar xvf install.tar'
ansible others -m file -a "dest=/root/install.tar state=absent"
fi
