#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}"   )" >/dev/null 2>&1 && pwd   )"
cd $DIR

yes n | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# 下面这个循环不正常，尝试了很多次，并且需要先用root登入相应的系统才行
for i in 9{0..4}; do
    ip=192.168.28.$i
    echo $ip
    # 玄学，增加ssh尝试登陆，解决copy id失败的问题
    ssh -oBatchMode=yes root@$ip exit
    sshpass -f password.txt ssh-copy-id root@$ip
done
